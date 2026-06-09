import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/game_constants.dart';
import '../models/game_data.dart';
import 'glass_card.dart';

class MissionsCard extends StatelessWidget {
  final GameData data;
  final void Function(int missionId) onClaim;

  const MissionsCard({super.key, required this.data, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('📋', style: TextStyle(fontSize: 17)),
              SizedBox(width: 8),
              Text(
                AppStrings.missionTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MissionRow(
            label: AppStrings.missionTap50,
            icon: '💖',
            progress: data.todayHeartsTapped,
            target: GameConstants.mission1Target,
            reward: GameConstants.mission1Reward,
            claimed: data.mission1Claimed,
            onClaim: () => onClaim(1),
          ),
          Divider(color: AppColors.glassBorder, height: 22),
          _MissionRow(
            label: AppStrings.missionTap150,
            icon: '💫',
            progress: data.todayHeartsTapped,
            target: GameConstants.mission2Target,
            reward: GameConstants.mission2Reward,
            claimed: data.mission2Claimed,
            onClaim: () => onClaim(2),
          ),
          Divider(color: AppColors.glassBorder, height: 22),
          _MissionRow(
            label: AppStrings.missionMood,
            icon: '⚡',
            progress: data.nuNuMood,
            target: GameConstants.mission3Target,
            reward: GameConstants.mission3Reward,
            claimed: data.mission3Claimed,
            onClaim: () => onClaim(3),
          ),
        ],
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final String label;
  final String icon;
  final int progress;
  final int target;
  final int reward;
  final bool claimed;
  final VoidCallback onClaim;

  const _MissionRow({
    required this.label,
    required this.icon,
    required this.progress,
    required this.target,
    required this.reward,
    required this.claimed,
    required this.onClaim,
  });

  bool get _completed => progress >= target;

  @override
  Widget build(BuildContext context) {
    final pct = (progress / target).clamp(0.0, 1.0);
    final canClaim = _completed && !claimed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: claimed
                      ? AppColors.textOnDarkFaint
                      : AppColors.textOnDarkMuted,
                  fontSize: 13,
                  decoration: claimed ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textOnDarkFaint,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (claimed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Text(
                  AppStrings.missionClaimed,
                  style: TextStyle(
                    color: AppColors.textOnDarkFaint,
                    fontSize: 11,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: canClaim ? onClaim : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: canClaim
                        ? const LinearGradient(
                            colors: [AppColors.idolPink, Color(0xFFFF1744)],
                          )
                        : null,
                    color: canClaim ? null : AppColors.glassFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: canClaim
                          ? AppColors.idolPink
                          : AppColors.glassBorder,
                    ),
                    boxShadow: canClaim
                        ? const [
                            BoxShadow(
                              color: Color(0x66FF6B9D),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    canClaim
                        ? '${AppStrings.missionClaim} +$reward❤️'
                        : '$progress / $target',
                    style: TextStyle(
                      color: canClaim
                          ? Colors.white
                          : AppColors.textOnDarkFaint,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: AppColors.barBackground,
            valueColor: AlwaysStoppedAnimation<Color>(
              claimed
                  ? AppColors.textOnDarkFaint
                  : _completed
                      ? AppColors.idolPink
                      : const Color(0xFFFFB300),
            ),
          ),
        ),
      ],
    );
  }
}
