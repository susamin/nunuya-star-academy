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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        AppStrings.dailyLogin,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            style: TextStyle(color: AppColors.textLight, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '❤️ × $rewardHearts',
            style: const TextStyle(
              color: AppColors.heartRed,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onClaim,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              AppStrings.claim,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
    final Color bg;
    final Color fg;

    if (isToday) {
      bg = AppColors.primary;
      fg = Colors.white;
    } else if (isClaimed) {
      bg = AppColors.heartRedClaimed;
      fg = Colors.white;
    } else {
      bg = const Color(0xFFEEEEEE);
      fg = AppColors.textLight;
    }

    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(
            child: Text(
              isClaimed ? '✓' : '$day',
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '❤️$reward',
          style: const TextStyle(fontSize: 9, color: AppColors.textLight),
        ),
      ],
    );
  }
}
