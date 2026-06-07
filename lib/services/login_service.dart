import '../models/game_data.dart';
import '../constants/game_constants.dart';

class LoginResult {
  final GameData updatedData;
  final bool isNewDay;
  final int rewardHearts;

  const LoginResult({
    required this.updatedData,
    required this.isNewDay,
    required this.rewardHearts,
  });
}

class LoginService {
  static String todayString() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  static String yesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final m = yesterday.month.toString().padLeft(2, '0');
    final d = yesterday.day.toString().padLeft(2, '0');
    return '${yesterday.year}-$m-$d';
  }

  static LoginResult checkLogin(GameData data) {
    final today = todayString();
    final yesterday = yesterdayString();

    if (data.lastLoginDate == today) {
      return LoginResult(
        updatedData: data,
        isNewDay: false,
        rewardHearts: 0,
      );
    }

    final int newStreak;
    final int newCycleDay;

    if (data.lastLoginDate == yesterday) {
      newStreak = data.loginStreak + 1;
      newCycleDay = (data.loginCycleDay % 7) + 1;
    } else {
      newStreak = 1;
      newCycleDay = 1;
    }

    final rewardHearts = GameConstants.dailyLoginRewards[newCycleDay - 1];

    final updated = data.copyWith(
      lastLoginDate: today,
      loginStreak: newStreak,
      loginCycleDay: newCycleDay,
      todayHeartsTapped: 0,
      todayDate: today,
      hasClaimedToday: false,
      pendingLoginReward: rewardHearts,
    );

    return LoginResult(
      updatedData: updated,
      isNewDay: true,
      rewardHearts: rewardHearts,
    );
  }
}
