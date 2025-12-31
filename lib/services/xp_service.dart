import '../models/user_progress.dart';
import '../utils/constants.dart';

/// Service for XP and level calculations
class XPService {
  /// Calculate XP needed for a specific level
  static int xpForLevel(int level) {
    if (level == 1) return 0;
    if (level == 2) return AppConstants.levelUpThresholdBase;

    int totalXP = AppConstants.levelUpThresholdBase;
    for (int i = 2; i < level; i++) {
      totalXP += (AppConstants.levelUpThresholdBase *
                  (AppConstants.levelUpMultiplier * (i - 1))).round();
    }
    return totalXP;
  }

  /// Calculate level from total XP
  static int levelFromXP(int totalXP) {
    if (totalXP < AppConstants.levelUpThresholdBase) return 1;

    int level = 1;
    int requiredXP = 0;

    while (requiredXP <= totalXP) {
      level++;
      if (level == 2) {
        requiredXP = AppConstants.levelUpThresholdBase;
      } else {
        requiredXP += (AppConstants.levelUpThresholdBase *
                      (AppConstants.levelUpMultiplier * (level - 2))).round();
      }
    }

    return level - 1;
  }

  /// Add XP and return updated progress (handles level ups)
  static UserProgress addXP(UserProgress currentProgress, int xpGained) {
    final newTotalXP = currentProgress.totalXP + xpGained;
    final newLevel = levelFromXP(newTotalXP);

    // Calculate current XP for the new level
    final xpAtCurrentLevel = newTotalXP - xpForLevel(newLevel);

    return currentProgress.copyWith(
      level: newLevel,
      totalXP: newTotalXP,
      currentXP: xpAtCurrentLevel,
      lastUpdate: DateTime.now(),
    );
  }

  /// Get XP needed for next level
  static int xpNeededForNextLevel(UserProgress progress) {
    final nextLevelXP = xpForLevel(progress.level + 1);
    return nextLevelXP - progress.totalXP;
  }
}

