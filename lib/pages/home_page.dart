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
import '../widgets/daily_login_dialog.dart';
import '../widgets/fan_counter_widget.dart';
import '../widgets/floating_heart.dart';
import '../widgets/glass_card.dart';
import '../widgets/heart_bar_widget.dart';
import '../widgets/level_badge_widget.dart';
import '../widgets/missions_card.dart';
import '../widgets/mood_bar_widget.dart';
import 'settings_page.dart';

// ── Floating heart entry ────────────────────────────────────────
class _HeartEntry {
  final int id;
  final OverlayEntry entry;
  _HeartEntry({required this.id, required this.entry});
}

// ── Star field (static background decoration) ───────────────────
class _StarPainter extends CustomPainter {
  // [xFrac, yFrac, radius, opacity*255]
  static const List<List<double>> _stars = [
    [0.06, 0.02, 1.8, 220], [0.18, 0.06, 1.2, 180], [0.35, 0.01, 1.5, 200],
    [0.52, 0.04, 1.0, 150], [0.71, 0.02, 2.0, 210], [0.87, 0.07, 1.3, 190],
    [0.93, 0.13, 1.0, 140], [0.12, 0.11, 1.5, 170], [0.28, 0.15, 0.8, 130],
    [0.44, 0.09, 1.2, 160], [0.60, 0.12, 1.6, 185], [0.78, 0.08, 1.0, 145],
    [0.03, 0.20, 2.0, 200], [0.22, 0.24, 1.3, 165], [0.50, 0.19, 1.8, 195],
    [0.67, 0.22, 1.0, 155], [0.82, 0.17, 1.5, 175], [0.95, 0.25, 0.8, 120],
    [0.10, 0.30, 1.2, 140], [0.38, 0.28, 2.0, 210], [0.72, 0.31, 1.3, 170],
    [0.14, 0.40, 1.0, 150], [0.55, 0.35, 1.5, 185], [0.90, 0.38, 1.8, 200],
    [0.25, 0.45, 0.8, 120], [0.46, 0.42, 1.2, 160], [0.68, 0.46, 1.5, 180],
    [0.08, 0.52, 1.8, 190], [0.32, 0.55, 1.0, 145], [0.76, 0.50, 1.3, 170],
    [0.58, 0.58, 0.8, 115], [0.42, 0.62, 1.5, 175], [0.85, 0.60, 1.2, 155],
    [0.16, 0.68, 2.0, 200], [0.62, 0.72, 1.0, 140],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      canvas.drawCircle(
        Offset(size.width * s[0], size.height * s[1]),
        s[2],
        Paint()..color = Color.fromRGBO(255, 255, 255, s[3] / 255),
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ────────────────────────────────────────────────────────────────
//  HomePage
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
  void initState() {
    super.initState();
    // Force white status bar icons
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = ref.read(gameProvider);
      if (data.pendingLoginReward > 0) {
        _showLoginDialog(data.pendingLoginReward, data.loginCycleDay);
      }
    });
  }

  @override
  void dispose() {
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

  // ── Floating heart ────────────────────────────────────────────
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
      if (prev != null && prev.level != next.level) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '${AppStrings.levelUp} Lv.${next.level} '
                  '${GameConstants.titleForLevel(next.level)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF6B2FA0),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.glassBorder),
            ),
          ),
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
                transitionsBuilder: (_, anim, _, child) =>
                    SlideTransition(
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
      body: Stack(
        children: [
          // ── 1. Gradient background ──────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.bgGradient),
            ),
          ),

          // ── 2. Star field ───────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _StarPainter()),
          ),

          // ── 3. Scrollable content ───────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 4),

                  // Level badge
                  LevelBadgeWidget(
                    level: data.level,
                    title: GameConstants.titleForLevel(data.level),
                  ),
                  const SizedBox(height: 16),

                  // Fan counter (big gold)
                  FanCounterWidget(fans: data.fans),
                  const SizedBox(height: 20),

                  // Progress bars in glass card
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
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

                  // Cat (with global key for overlay positioning)
                  CatWidget(
                    key: _catKey,
                    mood: data.nuNuMood,
                    level: data.level,
                    onTap: _onCatTap,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.tapHint,
                    style: const TextStyle(
                      color: AppColors.textOnDarkFaint,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats row
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem('❤️', AppStrings.todayTaps,
                            '${data.todayHeartsTapped}'),
                        _divider(),
                        _statItem('✨', AppStrings.totalHearts,
                            '${data.totalHeartsTapped}'),
                        _divider(),
                        _statItem('🔥', AppStrings.loginStreakLabel,
                            '${data.loginStreak}${AppStrings.days}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Daily missions
                  MissionsCard(
                    data: data,
                    onClaim: (id) =>
                        ref.read(gameProvider.notifier).claimMission(id),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textOnDarkFaint,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      Container(height: 40, width: 1, color: AppColors.glassBorder);
}
