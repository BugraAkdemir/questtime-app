/// Application constants
class AppConstants {
  // XP System
  static const int baseXPPerMinute = 10;
  static const int levelUpThresholdBase = 1000;
  static const double levelUpMultiplier = 1.2;

  // Timer defaults
  static const int defaultTimerDuration = 25; // minutes
  static const int minTimerDuration = 1; // minutes
  static const int maxTimerDuration = 120; // minutes

  // Daily quests
  static const int dailyQuestResetHour = 0; // midnight

  // UI
  static const double circularTimerSize = 280.0;
  static const double timerStrokeWidth = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}
