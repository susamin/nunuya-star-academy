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
    final progress = isMax ? 1.0 : (current / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lv.$level',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              isMax ? 'MAX ✨' : '$current / $total ❤️',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 14,
            backgroundColor: AppColors.heartRedLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.heartRed),
          ),
        ),
      ],
    );
  }
}
