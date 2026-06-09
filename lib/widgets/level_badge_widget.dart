import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LevelBadgeWidget extends StatelessWidget {
  final int level;
  final String title;

  const LevelBadgeWidget({
    super.key,
    required this.level,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66E91E63),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✦', style: TextStyle(color: AppColors.starGold, fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            'Lv.$level  $title',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          const Text('✦', style: TextStyle(color: AppColors.starGold, fontSize: 13)),
        ],
      ),
    );
  }
}
