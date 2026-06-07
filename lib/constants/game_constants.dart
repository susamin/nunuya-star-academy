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
