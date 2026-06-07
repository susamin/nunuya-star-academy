import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class FanCounterWidget extends StatelessWidget {
  final int fans;

  const FanCounterWidget({super.key, required this.fans});

  String _format(int n) {
    if (n >= 10000) {
      return '${(n / 10000).toStringAsFixed(1)}萬';
    }
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.people_rounded, color: AppColors.fanGold, size: 22),
        const SizedBox(width: 6),
        Text(
          '${_format(fans)} ${AppStrings.fans}',
          style: const TextStyle(
            color: AppColors.fanGold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
