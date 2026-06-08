import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../constants/game_constants.dart';

class MoodBarWidget extends StatelessWidget {
  final int mood;

  const MoodBarWidget({super.key, required this.mood});

  Color get _barColor {
    if (mood >= 80) return const Color(0xFF66BB6A); // green
    if (mood >= 50) return const Color(0xFFFFB300); // amber
    if (mood >= 20) return const Color(0xFFFF7043); // orange
    return const Color(0xFFEF5350); // red
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
            Text(_moodEmoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              AppStrings.nuNuEnergy,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF616161),
                  ),
            ),
            const Spacer(),
            Text(
              '$mood / ${GameConstants.moodMax}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _barColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (_, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              );
            },
          ),
        ),
      ],
    );
  }
}
