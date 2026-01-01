import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../models/quest.dart';
import '../models/daily_quest.dart';
import '../models/achievement.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import '../services/xp_service.dart';
import '../services/achievement_service.dart';

/// Main app state provider using ChangeNotifier
class AppStateProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();

  UserProgress _userProgress = UserProgress();
  List<Quest> _quests = [];
  List<DailyQuest> _dailyQuests = [];
  Map<String, UserAchievement> _userAchievements = {}; // achievementId -> UserAchievement

  UserProgress get userProgress => _userProgress;
  List<Quest> get quests => _quests;
  List<DailyQuest> get dailyQuests => _dailyQuests;
  Map<String, UserAchievement> get userAchievements => _userAchievements;

  /// Initialize and load data
  Future<void> initialize() async {
    await loadUserProgress();
    await loadQuests();
    await loadDailyQuests();
    await _checkDailyQuestsReset();
  }

  /// Load user progress from storage (Firebase if authenticated, else local)
  Future<void> loadUserProgress() async {
    if (_firestoreService.isAuthenticated) {
      _userProgress = await _firestoreService.loadUserProgress();
    } else {
      _userProgress = await _storageService.loadUserProgress();
    }
    notifyListeners();
  }

  /// Load quests from storage (Firebase if authenticated, else local)
  Future<void> loadQuests() async {
    if (_firestoreService.isAuthenticated) {
      _quests = await _firestoreService.loadQuests();
    } else {
      _quests = await _storageService.loadQuests();
    }
    notifyListeners();
  }

  /// Load daily quests from storage (Firebase if authenticated, else local)
  Future<void> loadDailyQuests() async {
    if (_firestoreService.isAuthenticated) {
      _dailyQuests = await _firestoreService.loadDailyQuests();
    } else {
      _dailyQuests = await _storageService.loadDailyQuests();
    }
    notifyListeners();
  }

  /// Complete a quest and update progress
  Future<void> completeQuest(Quest quest) async {
    final completedQuest = quest.complete();

    // Update quest in list
    final index = _quests.indexWhere((q) => q.id == quest.id);
    if (index != -1) {
      _quests[index] = completedQuest;
    } else {
      _quests.add(completedQuest);
    }

    // Update user progress
    _userProgress = XPService.addXP(_userProgress, quest.xpReward);

    // Update subject-specific study minutes
    _userProgress = AchievementService.updateSubjectStudyMinutes(
      _userProgress,
      quest,
    );

    // Update streak
    _userProgress = AchievementService.updateStreak(_userProgress);

    _userProgress = _userProgress.copyWith(
      totalStudyMinutes: _userProgress.totalStudyMinutes + quest.durationMinutes,
      completedQuestsCount: _userProgress.completedQuestsCount + 1,
      coins: _userProgress.coins + quest.coinReward,
    );

    // Check achievements
    final completedQuests = _quests.where((q) => q.isCompleted).toList();
    final newlyUnlocked = AchievementService.checkAchievements(
      userProgress: _userProgress,
      completedQuests: completedQuests,
      newlyCompletedQuest: completedQuest,
    );

    // Update user achievements and award rewards
    for (final achievement in newlyUnlocked) {
      final existing = _userAchievements[achievement.id];
      if (existing == null || !existing.isUnlocked) {
        // Newly unlocked achievement
        _userAchievements[achievement.id] = UserAchievement(
          achievementId: achievement.id,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          currentProgress: achievement.requirement,
        );

        // Award XP and coins
        if (achievement.xpReward > 0) {
          _userProgress = XPService.addXP(_userProgress, achievement.xpReward);
        }
        if (achievement.coinReward > 0) {
          _userProgress = _userProgress.copyWith(
            coins: _userProgress.coins + achievement.coinReward,
          );
        }
      }
    }

    // Update achievement progress for all achievements
    _updateAchievementProgress();

    // Update daily quests progress
    await _updateDailyQuestsProgress(quest);

    // Save to storage (Firebase if authenticated, else local)
    if (_firestoreService.isAuthenticated) {
      await _firestoreService.saveUserProgress(_userProgress);
      await _firestoreService.updateQuest(completedQuest);
      await _firestoreService.saveDailyQuests(_dailyQuests);
    } else {
      await _storageService.saveUserProgress(_userProgress);
      await _storageService.updateQuest(completedQuest);
      await _storageService.saveDailyQuests(_dailyQuests);
    }

    notifyListeners();

    // Return newly unlocked achievements for UI display
    return;
  }

  /// Update progress for all achievements
  void _updateAchievementProgress() {
    final allAchievements = Achievements.getAllAchievements();
    final completedQuests = _quests.where((q) => q.isCompleted).toList();

    for (final achievement in allAchievements) {
      final progress = AchievementService.getAchievementProgress(
        achievement: achievement,
        userProgress: _userProgress,
        completedQuests: completedQuests,
      );

      final existing = _userAchievements[achievement.id];
      if (existing == null) {
        // New achievement tracking
        _userAchievements[achievement.id] = UserAchievement(
          achievementId: achievement.id,
          isUnlocked: progress >= achievement.requirement,
          unlockedAt: progress >= achievement.requirement ? DateTime.now() : null,
          currentProgress: progress,
        );
      } else if (!existing.isUnlocked && progress >= achievement.requirement) {
        // Just unlocked
        _userAchievements[achievement.id] = UserAchievement(
          achievementId: achievement.id,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          currentProgress: progress,
        );
      } else {
        // Update progress
        _userAchievements[achievement.id] = UserAchievement(
          achievementId: achievement.id,
          isUnlocked: existing.isUnlocked || progress >= achievement.requirement,
          unlockedAt: existing.unlockedAt ??
              (progress >= achievement.requirement ? DateTime.now() : null),
          currentProgress: progress,
        );
      }
    }
  }

  /// Add a new quest
  Future<void> addQuest(Quest quest) async {
    _quests.add(quest);
    if (_firestoreService.isAuthenticated) {
      await _firestoreService.addQuest(quest);
    } else {
      await _storageService.addQuest(quest);
    }
    notifyListeners();
  }

  /// Cancel a quest (no XP awarded - only completion gives XP)
  Future<void> cancelQuest(Quest quest, int completedMinutes) async {
    final cancelledQuest = quest.cancel(completedMinutes);

    // Update quest in list (mark as cancelled, no XP)
    final index = _quests.indexWhere((q) => q.id == quest.id);
    if (index != -1) {
      _quests[index] = cancelledQuest;
    } else {
      _quests.add(cancelledQuest);
    }

    // No XP awarded for cancelled quests - only completed quests give XP
    // Save to storage (Firebase if authenticated, else local)
    if (_firestoreService.isAuthenticated) {
      await _firestoreService.updateQuest(cancelledQuest);
    } else {
      await _storageService.updateQuest(cancelledQuest);
    }

    notifyListeners();
  }

  /// Update daily quests progress based on completed quest
  Future<void> _updateDailyQuestsProgress(Quest quest) async {
    final today = DateTime.now();
    final todayQuests = _dailyQuests.where((dq) =>
        dq.date.year == today.year &&
        dq.date.month == today.month &&
        dq.date.day == today.day &&
        !dq.isCompleted);

    for (var dailyQuest in todayQuests) {
      DailyQuest updated;
      if (dailyQuest.type == DailyQuestType.completeQuests) {
        updated = dailyQuest.updateProgress(dailyQuest.progress + 1);
      } else if (dailyQuest.type == DailyQuestType.studyMinutes) {
        updated = dailyQuest.updateProgress(
            dailyQuest.progress + quest.durationMinutes);
      } else {
        continue;
      }

      if (updated.isCompleted && !dailyQuest.isCompleted) {
        // Bonus XP for completing daily quest
        _userProgress = XPService.addXP(_userProgress, updated.xpReward);
        if (_firestoreService.isAuthenticated) {
          await _firestoreService.saveUserProgress(_userProgress);
        } else {
          await _storageService.saveUserProgress(_userProgress);
        }
      }

      final index = _dailyQuests.indexWhere((dq) => dq.id == dailyQuest.id);
      if (index != -1) {
        _dailyQuests[index] = updated;
      }
    }
  }

  /// Check if daily quests need to be reset (new day)
  Future<void> _checkDailyQuestsReset() async {
    final now = DateTime.now();
    final lastUpdate = _userProgress.lastUpdate;

    // Reset if it's a new day
    if (now.year != lastUpdate.year ||
        now.month != lastUpdate.month ||
        now.day != lastUpdate.day) {
      await _resetDailyQuests();
    }
  }

  /// Reset daily quests for new day
  Future<void> _resetDailyQuests() async {
    // Generate new daily quests (simplified - you can expand this)
    _dailyQuests = [
      DailyQuest(
        type: DailyQuestType.completeQuests,
        target: 3,
        xpReward: 200,
        date: DateTime.now(),
      ),
      DailyQuest(
        type: DailyQuestType.studyMinutes,
        target: 60,
        xpReward: 300,
        date: DateTime.now(),
      ),
    ];
    if (_firestoreService.isAuthenticated) {
      await _firestoreService.saveDailyQuests(_dailyQuests);
    } else {
      await _storageService.saveDailyQuests(_dailyQuests);
    }
    notifyListeners();
  }

  /// Update user profile (name and username)
  Future<void> updateUserProfile({
    String? name,
    String? username,
  }) async {
    _userProgress = _userProgress.copyWith(
      name: name,
      username: username,
    );

    if (_firestoreService.isAuthenticated) {
      await _firestoreService.saveUserProgress(_userProgress);
    } else {
      await _storageService.saveUserProgress(_userProgress);
    }
    notifyListeners();
  }

  /// Clear all local data (called on logout)
  Future<void> clearLocalData() async {
    _userProgress = UserProgress();
    _quests = [];
    _dailyQuests = [];

    // Clear local storage
    await _storageService.clearAll();

    notifyListeners();
  }

  /// Reload data from Firebase (called on login)
  Future<void> reloadFromFirebase() async {
    if (_firestoreService.isAuthenticated) {
      await loadUserProgress();
      await loadQuests();
      await loadDailyQuests();
      await _checkDailyQuestsReset();
    }
  }
}

