import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_data.dart';
import '../constants/game_constants.dart';
import '../services/storage_service.dart';
import '../services/login_service.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameData>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<GameData> {
  final StorageService _storage = StorageService();

  GameNotifier() : super(GameData.initial()) {
    state = _storage.loadGameData();
  }

  int _calculateFans(GameData data) {
    final base = GameConstants.baseFansForLevel(data.level);
    return base + data.loginStreak * 10 + data.totalHeartsTapped ~/ 100;
  }

  void addHeart() {
    final today = LoginService.todayString();
    var data = state;

    if (data.todayDate != today) {
      data = data.copyWith(todayHeartsTapped: 0, todayDate: today);
    }

    final newTotal = data.totalHeartsTapped + 1;
    final newToday = data.todayHeartsTapped + 1;
    final isMaxLevel = data.level >= GameConstants.maxLevel;

    if (isMaxLevel) {
      final updated = data.copyWith(
        totalHeartsTapped: newTotal,
        todayHeartsTapped: newToday,
        todayDate: today,
      );
      state = updated.copyWith(fans: _calculateFans(updated));
    } else {
      final newCurrent = data.currentHearts + 1;
      final needed = GameConstants.heartsNeeded(data.level);

      if (newCurrent >= needed) {
        final newLevel = data.level + 1;
        final updated = data.copyWith(
          level: newLevel,
          currentHearts: newCurrent - needed,
          totalHeartsTapped: newTotal,
          todayHeartsTapped: newToday,
          todayDate: today,
        );
        state = updated.copyWith(fans: _calculateFans(updated));
      } else {
        final updated = data.copyWith(
          currentHearts: newCurrent,
          totalHeartsTapped: newTotal,
          todayHeartsTapped: newToday,
          todayDate: today,
        );
        state = updated.copyWith(fans: _calculateFans(updated));
      }
    }

    _save();
  }

  void processLogin() {
    final result = LoginService.checkLogin(state);
    if (result.isNewDay) {
      state = result.updatedData;
      _save();
    }
  }

  void claimDailyReward() {
    final hearts = state.pendingLoginReward;
    if (hearts <= 0) return;

    final isMaxLevel = state.level >= GameConstants.maxLevel;
    final newTotal = state.totalHeartsTapped + hearts;

    if (isMaxLevel) {
      final updated = state.copyWith(
        totalHeartsTapped: newTotal,
        pendingLoginReward: 0,
        hasClaimedToday: true,
      );
      state = updated.copyWith(fans: _calculateFans(updated));
    } else {
      final newCurrent = state.currentHearts + hearts;
      final needed = GameConstants.heartsNeeded(state.level);

      if (newCurrent >= needed) {
        final newLevel = state.level + 1;
        final updated = state.copyWith(
          level: newLevel,
          currentHearts: newCurrent - needed,
          totalHeartsTapped: newTotal,
          pendingLoginReward: 0,
          hasClaimedToday: true,
        );
        state = updated.copyWith(fans: _calculateFans(updated));
      } else {
        final updated = state.copyWith(
          currentHearts: newCurrent,
          totalHeartsTapped: newTotal,
          pendingLoginReward: 0,
          hasClaimedToday: true,
        );
        state = updated.copyWith(fans: _calculateFans(updated));
      }
    }

    _save();
  }

  void resetData() {
    state = GameData.initial();
    _storage.clearAll();
  }

  void _save() {
    _storage.saveGameData(state);
  }
}
