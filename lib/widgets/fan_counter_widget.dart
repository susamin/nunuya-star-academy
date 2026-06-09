import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class FanCounterWidget extends StatelessWidget {
  final int fans;

  const FanCounterWidget({super.key, required this.fans});

  String _format(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}萬';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gold gradient number
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.starGold, Color(0xFFFFF176)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            _format(fans),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.people_rounded, color: AppColors.starGold, size: 16),
            SizedBox(width: 4),
            Text(
              AppStrings.fans,
              style: TextStyle(
                color: AppColors.starGold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
