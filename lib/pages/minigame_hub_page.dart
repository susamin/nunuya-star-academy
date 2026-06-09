import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/minigame_constants.dart';
import '../providers/game_provider.dart';
import '../widgets/glass_card.dart';
import 'minigames/catch_fish_page.dart';
import 'minigames/memory_match_page.dart';
import 'minigames/rhythm_tap_page.dart';

class _GameEntry {
  final String id;
  final String name;
  final String desc;
  final String emoji;
  final List<Color> gradient;
  final WidgetBuilder builder;
  const _GameEntry({
    required this.id,
    required this.name,
    required this.desc,
    required this.emoji,
    required this.gradient,
    required this.builder,
  });
}

class MinigameHubPage extends ConsumerWidget {
  const MinigameHubPage({super.key});

  static final _games = <_GameEntry>[
    _GameEntry(
      id: 'rhythm',
      name: AppStrings.rhythmName,
      desc: AppStrings.rhythmDesc,
      emoji: '🎵',
      gradient: const [Color(0xFFFF6B9D), Color(0xFFC2185B)],
      builder: (_) => const RhythmTapPage(),
    ),
    _GameEntry(
      id: 'fish',
      name: AppStrings.fishName,
      desc: AppStrings.fishDesc,
      emoji: '🐟',
      gradient: const [Color(0xFF29B6F6), Color(0xFF1565C0)],
      builder: (_) => const CatchFishPage(),
    ),
    _GameEntry(
      id: 'memory',
      name: AppStrings.memoryName,
      desc: AppStrings.memoryDesc,
      emoji: '🎴',
      gradient: const [Color(0xFFAB47BC), Color(0xFF6A1B9A)],
      builder: (_) => const MemoryMatchPage(),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(gameProvider);

    int playsLeft(String id) {
      final used = switch (id) {
        'rhythm' => data.rhythmPlaysToday,
        'fish'   => data.fishPlaysToday,
        'memory' => data.memoryPlaysToday,
        _ => 0,
      };
      return MinigameConstants.dailyPlaysPerGame - used;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎮', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text(
              AppStrings.minigamesTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          itemCount: _games.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '完成迷你遊戲拿愛心，幫 Nunu 變得更強！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textOnDarkMuted,
                    fontSize: 13,
                  ),
                ),
              );
            }
            final g = _games[i - 1];
            final left = playsLeft(g.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _GameCard(
                entry: g,
                playsLeft: left,
                onPlay: left > 0
                    ? () => Navigator.of(context).push(
                          PageRouteBuilder<void>(
                            pageBuilder: (_, _, _) => g.builder(context),
                            transitionsBuilder: (_, anim, _, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration:
                                const Duration(milliseconds: 250),
                          ),
                        )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Game card
// ─────────────────────────────────────────────────────────────────
class _GameCard extends StatelessWidget {
  final _GameEntry entry;
  final int playsLeft;
  final VoidCallback? onPlay;

  const _GameCard({
    required this.entry,
    required this.playsLeft,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPlay == null;
    return GestureDetector(
      onTap: onPlay,
      child: GlassCard(
        padding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            // Tinted gradient strip on the left
            Positioned.fill(
              left: 0,
              right: null,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: entry.gradient,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 14, 16),
              child: Row(
                children: [
                  // Big emoji badge with gradient bg
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: entry.gradient),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: entry.gradient.first.withAlpha(160),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(entry.emoji,
                          style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.name,
                          style: TextStyle(
                            color: disabled
                                ? AppColors.textOnDarkFaint
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.desc,
                          style: const TextStyle(
                            color: AppColors.textOnDarkMuted,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 14,
                              color: playsLeft > 0
                                  ? AppColors.starGold
                                  : AppColors.textOnDarkFaint,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              disabled
                                  ? AppStrings.noPlaysLeft
                                  : '${AppStrings.playsRemaining} '
                                      '$playsLeft / ${entry.id == "memory" ? 5 : 5}',
                              style: TextStyle(
                                color: disabled
                                    ? AppColors.textOnDarkFaint
                                    : AppColors.starGold,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: disabled
                        ? AppColors.textOnDarkFaint
                        : Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
