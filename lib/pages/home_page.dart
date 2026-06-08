import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/game_constants.dart';
import '../models/game_data.dart';
import '../providers/game_provider.dart';
import '../widgets/cat_widget.dart';
import '../widgets/daily_login_dialog.dart';
import '../widgets/fan_counter_widget.dart';
import '../widgets/floating_heart.dart';
import '../widgets/heart_bar_widget.dart';
import '../widgets/level_badge_widget.dart';
import '../widgets/missions_card.dart';
import '../widgets/mood_bar_widget.dart';
import 'settings_page.dart';

// ── Floating heart data ─────────────────────────────────────────
class _HeartEntry {
  final int id;
  final OverlayEntry entry;
  _HeartEntry({required this.id, required this.entry});
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey _catKey = GlobalKey();
  final List<_HeartEntry> _hearts = [];
  int _nextHeartId = 0;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger mood decay & login check
      ref.read(gameProvider.notifier).processLogin();

      final data = ref.read(gameProvider);
      if (data.pendingLoginReward > 0) {
        _showLoginDialog(data.pendingLoginReward, data.loginCycleDay);
      }
    });
  }

  @override
  void dispose() {
    // Remove any lingering overlay entries
    for (final h in _hearts) {
      h.entry.remove();
    }
    super.dispose();
  }

  void _showLoginDialog(int reward, int cycleDay) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DailyLoginDialog(
        rewardHearts: reward,
        cycleDay: cycleDay,
        onClaim: () {
          ref.read(gameProvider.notifier).claimDailyReward();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // ── Floating heart ──────────────────────────────────────────
  void _spawnHeart(int multiplier) {
    final box = _catKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;

    final dx = (_random.nextDouble() - 0.5) * 80.0;
    final startX = pos.dx + size.width / 2 + dx;
    final startY = pos.dy + size.height * 0.3;

    final id = _nextHeartId++;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => FloatingHeartOverlay(
        multiplier: multiplier,
        startX: startX,
        startY: startY,
        onComplete: () => _removeHeart(id),
      ),
    );

    _hearts.add(_HeartEntry(id: id, entry: entry));
    Overlay.of(context).insert(entry);
  }

  void _removeHeart(int id) {
    final idx = _hearts.indexWhere((h) => h.id == id);
    if (idx != -1) {
      _hearts[idx].entry.remove();
      _hearts.removeAt(idx);
    }
  }

  // ── Tap handler ─────────────────────────────────────────────
  void _onCatTap(int multiplier) {
    ref.read(gameProvider.notifier).addHeart(multiplier);
    _spawnHeart(multiplier);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(gameProvider);

    ref.listen<GameData>(gameProvider, (prev, next) {
      if (prev != null && prev.level != next.level) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.levelUp} Lv.${next.level}  ${GameConstants.titleForLevel(next.level)} 🎉',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.levelPurple,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // ── Level + Fans ──────────────────────────────
              LevelBadgeWidget(
                level: data.level,
                title: GameConstants.titleForLevel(data.level),
              ),
              const SizedBox(height: 8),
              FanCounterWidget(fans: data.fans),
              const SizedBox(height: 14),

              // ── Heart progress bar ────────────────────────
              HeartBarWidget(
                current: data.currentHearts,
                total: GameConstants.heartsNeeded(data.level),
                level: data.level,
                maxLevel: GameConstants.maxLevel,
              ),
              const SizedBox(height: 10),

              // ── Mood / energy bar ─────────────────────────
              MoodBarWidget(mood: data.nuNuMood),
              const SizedBox(height: 28),

              // ── Cat (tap area) ────────────────────────────
              CatWidget(
                key: _catKey,
                mood: data.nuNuMood,
                level: data.level,
                onTap: _onCatTap,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.tapHint,
                style: const TextStyle(color: AppColors.textLight, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // ── Stats row ─────────────────────────────────
              _buildStatsCard(data),
              const SizedBox(height: 16),

              // ── Daily missions ────────────────────────────
              MissionsCard(
                data: data,
                onClaim: (id) =>
                    ref.read(gameProvider.notifier).claimMission(id),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(GameData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('❤️', AppStrings.todayTaps, '${data.todayHeartsTapped}'),
            _divider(),
            _statItem('✨', AppStrings.totalHearts, '${data.totalHeartsTapped}'),
            _divider(),
            _statItem(
              '🔥',
              AppStrings.loginStreakLabel,
              '${data.loginStreak}${AppStrings.days}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textLight, fontSize: 11),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(height: 40, width: 1, color: const Color(0xFFEEEEEE));
  }
}
