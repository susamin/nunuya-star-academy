import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/game_constants.dart';

class MoodBarWidget extends StatelessWidget {
  final int mood;

  const MoodBarWidget({super.key, required this.mood});

  LinearGradient get _barGradient {
    if (mood >= 80) {
      return const LinearGradient(
        colors: [Color(0xFF43A047), Color(0xFF76FF03)],
      );
    }
    if (mood >= 50) {
      return const LinearGradient(
        colors: [Color(0xFFFFB300), Color(0xFFFFEA00)],
      );
    }
    if (mood >= 20) {
      return const LinearGradient(
        colors: [Color(0xFFFF7043), Color(0xFFFFAB40)],
      );
    }
    return const LinearGradient(
      colors: [Color(0xFFEF5350), Color(0xFFFF8A65)],
    );
  }

  String get _moodEmoji {
    if (mood >= 80) return '😄';
    if (mood >= 50) return '😊';
    if (mood >= 20) return '😐';
    return '😴';
  }

  @override
  Widget build(BuildContext context) {
    final pct = mood / GameConstants.moodMax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(_moodEmoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Text(
              AppStrings.nuNuEnergy,
              style: const TextStyle(
                color: AppColors.textOnDarkMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              '$mood / ${GameConstants.moodMax}',
              style: TextStyle(
                color: _barGradient.colors.first,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        LayoutBuilder(
          builder: (_, constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    width: constraints.maxWidth,
                    color: AppColors.barBackground,
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (_, value, _) {
                      return Container(
                        height: 10,
                        width: constraints.maxWidth * value,
                        decoration: BoxDecoration(gradient: _barGradient),
                      );
                    },
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
