import '../models/achievement.dart';
import '../models/user_progress.dart';
import '../models/quest.dart';
import '../utils/enums.dart';

/// Service for managing achievements
class AchievementService {
  /// Check and update achievements based on user progress
  static List<Achievement> checkAchievements({
    required UserProgress userProgress,
    required List<Quest> completedQuests,
    Quest? newlyCompletedQuest,
  }) {
    final allAchievements = Achievements.getAllAchievements();
    final unlockedAchievements = <Achievement>[];

    for (final achievement in allAchievements) {
      final progress = _calculateProgress(
        achievement: achievement,
        userProgress: userProgress,
        completedQuests: completedQuests,
        newlyCompletedQuest: newlyCompletedQuest,
      );

      // Check if achievement should be unlocked
      if (progress >= achievement.requirement) {
        unlockedAchievements.add(achievement);
      }
    }

    return unlockedAchievements;
  }

  /// Calculate current progress for an achievement
  static int _calculateProgress({
    required Achievement achievement,
    required UserProgress userProgress,
    required List<Quest> completedQuests,
    Quest? newlyCompletedQuest,
  }) {
    switch (achievement.type) {
      case AchievementType.streak:
        return userProgress.currentStreak;

      case AchievementType.subject:
        if (achievement.subjectKey == null) return 0;
        return userProgress.getSubjectStudyMinutes(achievement.subjectKey!);

      case AchievementType.total:
        return userProgress.totalStudyMinutes;

      case AchievementType.quests:
        return userProgress.completedQuestsCount;
    }
  }

  /// Get progress for a specific achievement
  static int getAchievementProgress({
    required Achievement achievement,
    required UserProgress userProgress,
    required List<Quest> completedQuests,
  }) {
    return _calculateProgress(
      achievement: achievement,
      userProgress: userProgress,
      completedQuests: completedQuests,
      newlyCompletedQuest: null,
    );
  }

  /// Get subject key from Subject enum
  static String getSubjectKey(Subject subject) {
    return subject.name.toLowerCase();
  }

  /// Get subject key from quest (handles custom subjects)
  static String getQuestSubjectKey(Quest quest) {
    if (quest.customSubjectName != null) {
      // For custom subjects, use a normalized version of the custom name
      return quest.customSubjectName!.toLowerCase().replaceAll(' ', '_');
    }
    return getSubjectKey(quest.subject);
  }

  /// Update subject study minutes in user progress
  static UserProgress updateSubjectStudyMinutes(
    UserProgress userProgress,
    Quest quest,
  ) {
    final subjectKey = getQuestSubjectKey(quest);
    final currentMinutes = userProgress.getSubjectStudyMinutes(subjectKey);
    final newMinutes = currentMinutes + quest.durationMinutes;

    final updatedSubjectMinutes = Map<String, int>.from(
      userProgress.subjectStudyMinutes,
    );
    updatedSubjectMinutes[subjectKey] = newMinutes;

    return userProgress.copyWith(
      subjectStudyMinutes: updatedSubjectMinutes,
    );
  }

  /// Update streak based on last study date
  static UserProgress updateStreak(UserProgress userProgress) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudy = userProgress.lastStudyDate;

    if (lastStudy == null) {
      // First time studying
      return userProgress.copyWith(
        currentStreak: 1,
        lastStudyDate: today,
      );
    }

    final lastStudyDay = DateTime(lastStudy.year, lastStudy.month, lastStudy.day);
    final daysDifference = today.difference(lastStudyDay).inDays;

    if (daysDifference == 0) {
      // Same day, no change
      return userProgress;
    } else if (daysDifference == 1) {
      // Consecutive day, increment streak
      return userProgress.copyWith(
        currentStreak: userProgress.currentStreak + 1,
        lastStudyDate: today,
      );
    } else {
      // Streak broken, reset to 1
      return userProgress.copyWith(
        currentStreak: 1,
        lastStudyDate: today,
      );
    }
  }
}

