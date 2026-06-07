import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/game_constants.dart';
import '../models/game_data.dart';
import '../providers/game_provider.dart';
import '../widgets/cat_widget.dart';
import '../widgets/daily_login_dialog.dart';
import '../widgets/fan_counter_widget.dart';
import '../widgets/heart_bar_widget.dart';
import '../widgets/level_badge_widget.dart';
import 'settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = ref.read(gameProvider);
      if (data.pendingLoginReward > 0) {
        _showLoginDialog(data.pendingLoginReward, data.loginCycleDay);
      }
    });
  }

  void _showLoginDialog(int reward, int cycleDay) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DailyLoginDialog(
        rewardHearts: reward,
        cycleDay: cycleDay,
        onClaim: () {
          ref.read(gameProvider.notifier).claimDailyReward();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(gameProvider);

    ref.listen<GameData>(gameProvider, (prev, next) {
      if (prev != null && prev.level != next.level) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.levelUp} Lv.${next.level}  ${GameConstants.titleForLevel(next.level)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.levelPurple,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              LevelBadgeWidget(
                level: data.level,
                title: GameConstants.titleForLevel(data.level),
              ),
              const SizedBox(height: 10),
              FanCounterWidget(fans: data.fans),
              const SizedBox(height: 20),
              HeartBarWidget(
                current: data.currentHearts,
                total: GameConstants.heartsNeeded(data.level),
                level: data.level,
                maxLevel: GameConstants.maxLevel,
              ),
              const SizedBox(height: 36),
              CatWidget(
                onTap: () => ref.read(gameProvider.notifier).addHeart(),
              ),
              const SizedBox(height: 10),
              const Text(
                AppStrings.tapHint,
                style: TextStyle(color: AppColors.textLight, fontSize: 14),
              ),
              const SizedBox(height: 28),
              _buildStatsCard(data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(GameData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('❤️', AppStrings.todayTaps, '${data.todayHeartsTapped}'),
            _divider(),
            _statItem('✨', AppStrings.totalHearts, '${data.totalHeartsTapped}'),
            _divider(),
            _statItem(
              '🔥',
              AppStrings.loginStreakLabel,
              '${data.loginStreak}${AppStrings.days}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textLight, fontSize: 11),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 40,
      width: 1,
      color: const Color(0xFFEEEEEE),
    );
  }
}
