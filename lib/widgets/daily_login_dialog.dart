import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/game_constants.dart';

class DailyLoginDialog extends StatelessWidget {
  final int rewardHearts;
  final int cycleDay;
  final VoidCallback onClaim;

  const DailyLoginDialog({
    super.key,
    required this.rewardHearts,
    required this.cycleDay,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3D1C6E), Color(0xFF2D0A52)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.glassBorder, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66FF6B9D),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with gold stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('✦', style: TextStyle(color: AppColors.starGold, fontSize: 14)),
                SizedBox(width: 8),
                Text(
                  AppStrings.dailyLogin,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(width: 8),
                Text('✦', style: TextStyle(color: AppColors.starGold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 20),
            // 7-day strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final day = i + 1;
                return _DayCircle(
                  day: day,
                  reward: GameConstants.dailyLoginRewards[i],
                  isClaimed: day < cycleDay,
                  isToday: day == cycleDay,
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text(
              '今日獎勵',
              style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13),
            ),
            const SizedBox(height: 6),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppColors.starGold, AppColors.idolPink],
              ).createShader(b),
              child: Text(
                '❤️ × $rewardHearts',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Gradient claim button
            GestureDetector(
              onTap: onClaim,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.idolPink, Color(0xFFFF1744)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x88FF6B9D),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    AppStrings.claim,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final int day;
  final int reward;
  final bool isClaimed;
  final bool isToday;

  const _DayCircle({
    required this.day,
    required this.reward,
    required this.isClaimed,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final Widget circle;
    if (isToday) {
      circle = Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.idolPink, Color(0xFFFF1744)],
          ),
          boxShadow: [
            BoxShadow(color: Color(0x99FF6B9D), blurRadius: 12, spreadRadius: 1),
          ],
        ),
        child: Center(
          child: Text(
            '$day',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
    } else if (isClaimed) {
      circle = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x33FF6B9D),
          border: Border.all(color: AppColors.idolPink, width: 1.2),
        ),
        child: const Center(
          child: Text(
            '✓',
            style: TextStyle(
              color: AppColors.idolPink,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
    } else {
      circle = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glassFill,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Center(
          child: Text(
            '$day',
            style: const TextStyle(
              color: AppColors.textOnDarkFaint,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        circle,
        const SizedBox(height: 4),
        Text(
          '❤️$reward',
          style: TextStyle(
            fontSize: 9,
            color: isToday ? AppColors.starGold : AppColors.textOnDarkFaint,
          ),
        ),
      ],
    );
  }
}
