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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.levelPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
