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

  // ── Fan calculation ────────────────────────────────────────
  int _calculateFans(GameData data) {
    final base = GameConstants.baseFansForLevel(data.level);
    final moodMult = GameConstants.moodFanMultiplier(data.nuNuMood);
    final heartBonus = (data.totalHeartsTapped / 100.0 * moodMult).floor();
    return base + data.loginStreak * 10 + heartBonus;
  }

  // ── Add hearts (combo-aware) ───────────────────────────────
  /// [count] is the combo multiplier (1, 2, or 3).
  void addHeart(int count) {
    final today = LoginService.todayString();
    var data = state;

    // Reset daily counters and missions if it's a new day
    if (data.todayDate != today) {
      data = data.copyWith(
        todayHeartsTapped: 0,
        todayDate: today,
        mission1Claimed: false,
        mission2Claimed: false,
        mission3Claimed: false,
        missionDate: today,
      );
    }

    // Update mood: +moodPerTap per tap
    final moodGain = GameConstants.moodPerTap * count;
    final newMood = (data.nuNuMood + moodGain).clamp(0, GameConstants.moodMax);

    // Update counts
    final newTotal = data.totalHeartsTapped + count;
    final newToday = data.todayHeartsTapped + count;
    final now = DateTime.now().toIso8601String();

    // Apply base field updates
    data = data.copyWith(
      totalHeartsTapped: newTotal,
      todayHeartsTapped: newToday,
      todayDate: today,
      nuNuMood: newMood,
      lastActiveTime: now,
    );

    // Apply level progression (handles multi-level-ups)
    data = _applyHearts(data, count);

    state = data.copyWith(fans: _calculateFans(data));
    _save();
  }

  /// Distribute [count] hearts into current level, levelling up as needed.
  GameData _applyHearts(GameData data, int count) {
    if (data.level >= GameConstants.maxLevel) return data;

    var curr = data.currentHearts + count;
    var level = data.level;

    while (level < GameConstants.maxLevel) {
      final needed = GameConstants.heartsNeeded(level);
      if (curr >= needed) {
        curr -= needed;
        level++;
      } else {
        break;
      }
    }

    return data.copyWith(level: level, currentHearts: curr);
  }

  // ── Daily login ────────────────────────────────────────────
  void processLogin() {
    final result = LoginService.checkLogin(state);
    var data = result.isNewDay ? result.updatedData : state;

    // Decay mood based on time offline
    data = _decayMood(data);

    // Reset missions on new day
    if (result.isNewDay) {
      final today = LoginService.todayString();
      data = data.copyWith(
        mission1Claimed: false,
        mission2Claimed: false,
        mission3Claimed: false,
        missionDate: today,
      );
    }

    state = data;
    _save();
  }

  GameData _decayMood(GameData data) {
    if (data.lastActiveTime.isEmpty) return data;
    final lastActive = DateTime.tryParse(data.lastActiveTime);
    if (lastActive == null) return data;

    final minutesElapsed = DateTime.now().difference(lastActive).inMinutes;
    if (minutesElapsed < 1) return data;

    final hoursElapsed = minutesElapsed / 60.0;
    final moodLoss = (hoursElapsed * GameConstants.moodDecayPerHour).floor();
    if (moodLoss <= 0) return data;

    final newMood = (data.nuNuMood - moodLoss).clamp(0, GameConstants.moodMax);
    return data.copyWith(nuNuMood: newMood);
  }

  // ── Claim daily login reward ───────────────────────────────
  void claimDailyReward() {
    final hearts = state.pendingLoginReward;
    if (hearts <= 0) return;

    final newTotal = state.totalHeartsTapped + hearts;
    var data = state.copyWith(
      totalHeartsTapped: newTotal,
      pendingLoginReward: 0,
      hasClaimedToday: true,
    );
    data = _applyHearts(data, hearts);
    state = data.copyWith(fans: _calculateFans(data));
    _save();
  }

  // ── Claim mission reward ───────────────────────────────────
  void claimMission(int missionId) {
    final data = state;
    int reward = 0;
    GameData updated;

    switch (missionId) {
      case 1:
        if (data.mission1Claimed) return;
        if (data.todayHeartsTapped < GameConstants.mission1Target) return;
        reward = GameConstants.mission1Reward;
        updated = data.copyWith(mission1Claimed: true);
      case 2:
        if (data.mission2Claimed) return;
        if (data.todayHeartsTapped < GameConstants.mission2Target) return;
        reward = GameConstants.mission2Reward;
        updated = data.copyWith(mission2Claimed: true);
      case 3:
        if (data.mission3Claimed) return;
        if (data.nuNuMood < GameConstants.mission3Target) return;
        reward = GameConstants.mission3Reward;
        updated = data.copyWith(mission3Claimed: true);
      default:
        return;
    }

    if (reward > 0) {
      final newTotal = updated.totalHeartsTapped + reward;
      updated = updated.copyWith(totalHeartsTapped: newTotal);
      updated = _applyHearts(updated, reward);
      state = updated.copyWith(fans: _calculateFans(updated));
    } else {
      state = updated;
    }
    _save();
  }

  // ── Reset ──────────────────────────────────────────────────
  void resetData() {
    state = GameData.initial();
    _storage.clearAll();
  }

  void _save() {
    _storage.saveGameData(state);
  }
}
