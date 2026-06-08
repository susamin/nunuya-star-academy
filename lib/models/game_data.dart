import '../constants/game_constants.dart';

class GameData {
  final int level;
  final int currentHearts;
  final int totalHeartsTapped;
  final int fans;
  final String lastLoginDate;
  final int loginStreak;
  final int loginCycleDay;
  final int todayHeartsTapped;
  final String todayDate;
  final bool hasClaimedToday;
  final int pendingLoginReward;

  // ── v2 fields ─────────────────────────────────────────────────
  /// Nunu's energy / mood (0–100). Rises on tap, decays when offline.
  final int nuNuMood;

  /// ISO-8601 timestamp of last tap, used to calculate mood decay.
  final String lastActiveTime;

  /// Mission claim state (reset daily via missionDate)
  final bool mission1Claimed;
  final bool mission2Claimed;
  final bool mission3Claimed;

  /// The date string when mission state was last reset
  final String missionDate;

  const GameData({
    required this.level,
    required this.currentHearts,
    required this.totalHeartsTapped,
    required this.fans,
    required this.lastLoginDate,
    required this.loginStreak,
    required this.loginCycleDay,
    required this.todayHeartsTapped,
    required this.todayDate,
    required this.hasClaimedToday,
    required this.pendingLoginReward,
    required this.nuNuMood,
    required this.lastActiveTime,
    required this.mission1Claimed,
    required this.mission2Claimed,
    required this.mission3Claimed,
    required this.missionDate,
  });

  factory GameData.initial() => GameData(
        level: 1,
        currentHearts: 0,
        totalHeartsTapped: 0,
        fans: 0,
        lastLoginDate: '',
        loginStreak: 0,
        loginCycleDay: 1,
        todayHeartsTapped: 0,
        todayDate: '',
        hasClaimedToday: false,
        pendingLoginReward: 0,
        nuNuMood: GameConstants.moodDefault,
        lastActiveTime: '',
        mission1Claimed: false,
        mission2Claimed: false,
        mission3Claimed: false,
        missionDate: '',
      );

  GameData copyWith({
    int? level,
    int? currentHearts,
    int? totalHeartsTapped,
    int? fans,
    String? lastLoginDate,
    int? loginStreak,
    int? loginCycleDay,
    int? todayHeartsTapped,
    String? todayDate,
    bool? hasClaimedToday,
    int? pendingLoginReward,
    int? nuNuMood,
    String? lastActiveTime,
    bool? mission1Claimed,
    bool? mission2Claimed,
    bool? mission3Claimed,
    String? missionDate,
  }) {
    return GameData(
      level: level ?? this.level,
      currentHearts: currentHearts ?? this.currentHearts,
      totalHeartsTapped: totalHeartsTapped ?? this.totalHeartsTapped,
      fans: fans ?? this.fans,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      loginStreak: loginStreak ?? this.loginStreak,
      loginCycleDay: loginCycleDay ?? this.loginCycleDay,
      todayHeartsTapped: todayHeartsTapped ?? this.todayHeartsTapped,
      todayDate: todayDate ?? this.todayDate,
      hasClaimedToday: hasClaimedToday ?? this.hasClaimedToday,
      pendingLoginReward: pendingLoginReward ?? this.pendingLoginReward,
      nuNuMood: nuNuMood ?? this.nuNuMood,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      mission1Claimed: mission1Claimed ?? this.mission1Claimed,
      mission2Claimed: mission2Claimed ?? this.mission2Claimed,
      mission3Claimed: mission3Claimed ?? this.mission3Claimed,
      missionDate: missionDate ?? this.missionDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'currentHearts': currentHearts,
        'totalHeartsTapped': totalHeartsTapped,
        'fans': fans,
        'lastLoginDate': lastLoginDate,
        'loginStreak': loginStreak,
        'loginCycleDay': loginCycleDay,
        'todayHeartsTapped': todayHeartsTapped,
        'todayDate': todayDate,
        'hasClaimedToday': hasClaimedToday,
        'pendingLoginReward': pendingLoginReward,
        'nuNuMood': nuNuMood,
        'lastActiveTime': lastActiveTime,
        'mission1Claimed': mission1Claimed,
        'mission2Claimed': mission2Claimed,
        'mission3Claimed': mission3Claimed,
        'missionDate': missionDate,
      };

  factory GameData.fromJson(Map<String, dynamic> json) => GameData(
        level: (json['level'] as num?)?.toInt() ?? 1,
        currentHearts: (json['currentHearts'] as num?)?.toInt() ?? 0,
        totalHeartsTapped: (json['totalHeartsTapped'] as num?)?.toInt() ?? 0,
        fans: (json['fans'] as num?)?.toInt() ?? 0,
        lastLoginDate: json['lastLoginDate'] as String? ?? '',
        loginStreak: (json['loginStreak'] as num?)?.toInt() ?? 0,
        loginCycleDay: (json['loginCycleDay'] as num?)?.toInt() ?? 1,
        todayHeartsTapped: (json['todayHeartsTapped'] as num?)?.toInt() ?? 0,
        todayDate: json['todayDate'] as String? ?? '',
        hasClaimedToday: json['hasClaimedToday'] as bool? ?? false,
        pendingLoginReward: (json['pendingLoginReward'] as num?)?.toInt() ?? 0,
        nuNuMood: (json['nuNuMood'] as num?)?.toInt() ?? GameConstants.moodDefault,
        lastActiveTime: json['lastActiveTime'] as String? ?? '',
        mission1Claimed: json['mission1Claimed'] as bool? ?? false,
        mission2Claimed: json['mission2Claimed'] as bool? ?? false,
        mission3Claimed: json['mission3Claimed'] as bool? ?? false,
        missionDate: json['missionDate'] as String? ?? '',
      );
}
