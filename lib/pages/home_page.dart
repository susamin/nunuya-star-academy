import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/game_constants.dart';
import '../models/game_data.dart';
import '../providers/game_provider.dart';
import '../widgets/cat_widget.dart';
import '../widgets/fan_counter_widget.dart';
import '../widgets/floating_heart.dart';
import '../widgets/glass_card.dart';
import '../widgets/heart_bar_widget.dart';
import '../widgets/level_badge_widget.dart';
import '../widgets/level_up_overlay.dart';
import '../widgets/missions_card.dart';
import '../widgets/mood_bar_widget.dart';
import 'settings_page.dart';

// ── Floating heart entry ────────────────────────────────────────
class _HeartEntry {
  final int id;
  final OverlayEntry entry;
  _HeartEntry({required this.id, required this.entry});
}

// ────────────────────────────────────────────────────────────────
//  HomePage  (background owned by MainScaffold)
// ────────────────────────────────────────────────────────────────
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
  void dispose() {
    for (final h in _hearts) {
      h.entry.remove();
    }
    super.dispose();
  }

  void _spawnHeart(int multiplier) {
    final box = _catKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos  = box.localToGlobal(Offset.zero);
    final size = box.size;
    final dx   = (_random.nextDouble() - 0.5) * 80.0;

    final id = _nextHeartId++;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => FloatingHeartOverlay(
        multiplier: multiplier,
        startX: pos.dx + size.width / 2 + dx,
        startY: pos.dy + size.height * 0.25,
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

  void _onCatTap(int multiplier) {
    ref.read(gameProvider.notifier).addHeart(multiplier);
    _spawnHeart(multiplier);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(gameProvider);

    ref.listen<GameData>(gameProvider, (prev, next) {
      if (prev != null && next.level > prev.level) {
        HapticFeedback.heavyImpact();
        LevelUpOverlay.show(
          context,
          newLevel: next.level,
          newTitle: GameConstants.titleForLevel(next.level),
        );
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('✦', style: TextStyle(color: AppColors.starGold, fontSize: 14)),
            SizedBox(width: 6),
            Text(
              AppStrings.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
            SizedBox(width: 6),
            Text('✦', style: TextStyle(color: AppColors.starGold, fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
              PageRouteBuilder<void>(
                pageBuilder: (_, _, _) => const SettingsPage(),
                transitionsBuilder: (_, anim, _, child) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          child: Column(
            children: [
              const SizedBox(height: 4),
              LevelBadgeWidget(
                level: data.level,
                title: GameConstants.titleForLevel(data.level),
              ),
              const SizedBox(height: 16),
              FanCounterWidget(fans: data.fans),
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    HeartBarWidget(
                      current: data.currentHearts,
                      total: GameConstants.heartsNeeded(data.level),
                      level: data.level,
                      maxLevel: GameConstants.maxLevel,
                    ),
                    const SizedBox(height: 12),
                    MoodBarWidget(mood: data.nuNuMood),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              CatWidget(
                key: _catKey,
                mood: data.nuNuMood,
                level: data.level,
                onTap: _onCatTap,
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.tapHint,
                style: TextStyle(
                  color: AppColors.textOnDarkFaint,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('❤️', AppStrings.todayTaps, '${data.todayHeartsTapped}'),
                    _divider(),
                    _statItem('✨', AppStrings.totalHearts, '${data.totalHeartsTapped}'),
                    _divider(),
                    _statItem('🔥', AppStrings.loginStreakLabel,
                        '${data.loginStreak}${AppStrings.days}'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              MissionsCard(
                data: data,
                onClaim: (id) =>
                    ref.read(gameProvider.notifier).claimMission(id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textOnDarkFaint, fontSize: 11)),
      ],
    );
  }

  Widget _divider() =>
      Container(height: 40, width: 1, color: AppColors.glassBorder);
}
