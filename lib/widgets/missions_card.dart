import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../constants/game_constants.dart';
import '../models/game_data.dart';

class MissionsCard extends StatelessWidget {
  final GameData data;
  final void Function(int missionId) onClaim;

  const MissionsCard({super.key, required this.data, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📋', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  AppStrings.missionTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF424242),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MissionRow(
              label: AppStrings.missionTap50,
              icon: '💖',
              progress: data.todayHeartsTapped,
              target: GameConstants.mission1Target,
              reward: GameConstants.mission1Reward,
              claimed: data.mission1Claimed,
              onClaim: () => onClaim(1),
            ),
            const Divider(height: 20),
            _MissionRow(
              label: AppStrings.missionTap150,
              icon: '💫',
              progress: data.todayHeartsTapped,
              target: GameConstants.mission2Target,
              reward: GameConstants.mission2Reward,
              claimed: data.mission2Claimed,
              onClaim: () => onClaim(2),
            ),
            const Divider(height: 20),
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
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: claimed ? const Color(0xFF9E9E9E) : const Color(0xFF424242),
                      decoration: claimed ? TextDecoration.lineThrough : null,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            if (claimed)
              Text(
                AppStrings.missionClaimed,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF9E9E9E),
                    ),
              )
            else
              FilledButton.tonal(
                onPressed: canClaim ? onClaim : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(64, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  backgroundColor: canClaim ? const Color(0xFFE91E63) : null,
                  foregroundColor: canClaim ? Colors.white : null,
                ),
                child: Text(canClaim
                    ? '${AppStrings.missionClaim} +$reward❤️'
                    : '$progress / $target'),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation<Color>(
              claimed
                  ? const Color(0xFFBDBDBD)
                  : _completed
                      ? const Color(0xFFE91E63)
                      : const Color(0xFFFF9800),
            ),
          ),
        ),
      ],
    );
  }
}
