import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HeartBarWidget extends StatelessWidget {
  final int current;
  final int total;
  final int level;
  final int maxLevel;

  const HeartBarWidget({
    super.key,
    required this.current,
    required this.total,
    required this.level,
    required this.maxLevel,
  });

  @override
  Widget build(BuildContext context) {
    final isMax = level >= maxLevel;
    final pct = isMax ? 1.0 : (current / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isMax ? 'MAX ✨' : 'Lv.$level → Lv.${level + 1}',
              style: const TextStyle(
                color: AppColors.textOnDarkMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              isMax ? '★ 傳奇等級 ★' : '$current / $total ❤️',
              style: const TextStyle(
                color: AppColors.idolPink,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        // Gradient progress bar
        LayoutBuilder(
          builder: (_, constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // Track
                  Container(
                    height: 14,
                    width: constraints.maxWidth,
                    color: AppColors.barBackground,
                  ),
                  // Fill with gradient
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (_, value, _) {
                      return Container(
                        height: 14,
                        width: constraints.maxWidth * value,
                        decoration: const BoxDecoration(
                          gradient: AppColors.heartBarGradient,
                        ),
                      );
                    },
                  ),
                  // Shine overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x33FFFFFF), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
