class MinigameConstants {
  // ── Daily play limit per game ─────────────────────────────────
  static const int dailyPlaysPerGame = 5;

  // ── Rhythm Tap ───────────────────────────────────────────────
  static const int rhythmNoteCount    = 20;      // hearts to spawn
  static const int rhythmDurationSec  = 30;
  static const int rhythmPerfectHearts = 10;
  static const int rhythmGoodHearts    = 5;
  static const int rhythmMissHearts    = 0;
  /// Bonus on full clear (>= 90% perfect)
  static const int rhythmClearBonus   = 50;

  // ── Catch Fish ───────────────────────────────────────────────
  static const int fishDurationSec = 30;
  static const int fishSmallReward = 3;   // small fish hearts
  static const int fishGoldReward  = 12;  // gold fish hearts
  static const int fishMoodGain    = 30;  // mood boost on completion

  // ── Memory Match ─────────────────────────────────────────────
  static const int memoryPairCount    = 6;   // 12 cards
  static const int memoryDurationSec  = 60;
  static const int memoryRewardPerPair = 15;
  static const int memoryTimeBonus    = 60;  // bonus if cleared

  // ── Reward caps (anti-cheat safety) ──────────────────────────
  static const int maxRewardPerPlay = 300;
}
