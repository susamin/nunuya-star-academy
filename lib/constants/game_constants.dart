class GameConstants {
  static const int maxLevel = 10;

  static const List<int> heartsToNextLevel = [
    50, 100, 200, 350, 500, 800, 1200, 1800, 2700, 4000,
  ];

  static const List<String> levelTitles = [
    '路人貓',
    '練習生',
    '出道新星',
    '上升新人',
    '人氣偶像',
    '頂尖偶像',
    '超級偶像',
    '全國偶像',
    '傳說巨星',
    '⭐ 星際巨星',
  ];

  static const List<int> levelBaseFans = [
    0, 100, 300, 700, 1500, 3000, 6000, 12000, 25000, 100000,
  ];

  static const List<int> dailyLoginRewards = [
    30, 50, 80, 100, 150, 200, 300,
  ];

  // ── Combo system ──────────────────────────────────────────────
  /// Tap within this many milliseconds to continue the combo
  static const int comboWindowMs = 800;

  /// Combo count needed to reach ×2 multiplier
  static const int combo2xThreshold = 10;

  /// Combo count needed to reach ×3 multiplier
  static const int combo3xThreshold = 30;

  /// Returns 1, 2, or 3 based on current combo count
  static int comboMultiplier(int combo) {
    if (combo >= combo3xThreshold) return 3;
    if (combo >= combo2xThreshold) return 2;
    return 1;
  }

  // ── Mood / energy system ──────────────────────────────────────
  static const int moodMax = 100;
  static const int moodDefault = 60;

  /// Mood gained per tap (capped at moodMax)
  static const int moodPerTap = 2;

  /// Mood lost per hour while offline
  static const double moodDecayPerHour = 8.0;

  /// Fan multiplier based on Nunu's current mood
  static double moodFanMultiplier(int mood) {
    if (mood >= 80) return 2.0;
    if (mood >= 50) return 1.5;
    if (mood >= 20) return 1.0;
    return 0.5;
  }

  // ── Daily missions ────────────────────────────────────────────
  static const int mission1Target = 50;   // today's taps
  static const int mission2Target = 150;  // today's taps
  static const int mission3Target = 80;   // mood value

  static const int mission1Reward = 50;
  static const int mission2Reward = 100;
  static const int mission3Reward = 80;

  // ── Helpers ───────────────────────────────────────────────────
  static int heartsNeeded(int level) {
    if (level >= maxLevel) return 999999999;
    final idx = (level - 1).clamp(0, heartsToNextLevel.length - 1);
    return heartsToNextLevel[idx];
  }

  static String titleForLevel(int level) {
    final idx = (level - 1).clamp(0, levelTitles.length - 1);
    return levelTitles[idx];
  }

  static int baseFansForLevel(int level) {
    final idx = (level - 1).clamp(0, levelBaseFans.length - 1);
    return levelBaseFans[idx];
  }
}
