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
  });

  factory GameData.initial() => const GameData(
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
      );
}
