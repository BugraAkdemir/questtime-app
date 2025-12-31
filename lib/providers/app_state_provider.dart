import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../models/quest.dart';
import '../models/daily_quest.dart';
import '../services/storage_service.dart';
import '../services/xp_service.dart';

/// Main app state provider using ChangeNotifier
class AppStateProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  UserProgress _userProgress = UserProgress();
  List<Quest> _quests = [];
  List<DailyQuest> _dailyQuests = [];

  UserProgress get userProgress => _userProgress;
  List<Quest> get quests => _quests;
  List<DailyQuest> get dailyQuests => _dailyQuests;

  /// Initialize and load data
  Future<void> initialize() async {
    await loadUserProgress();
    await loadQuests();
    await loadDailyQuests();
    _checkDailyQuestsReset();
  }

  /// Load user progress from storage
  Future<void> loadUserProgress() async {
    _userProgress = await _storageService.loadUserProgress();
    notifyListeners();
  }

  /// Load quests from storage
  Future<void> loadQuests() async {
    _quests = await _storageService.loadQuests();
    notifyListeners();
  }

  /// Load daily quests from storage
  Future<void> loadDailyQuests() async {
    _dailyQuests = await _storageService.loadDailyQuests();
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
    _userProgress = _userProgress.copyWith(
      totalStudyMinutes: _userProgress.totalStudyMinutes + quest.durationMinutes,
      completedQuestsCount: _userProgress.completedQuestsCount + 1,
      coins: _userProgress.coins + quest.coinReward,
    );

    // Update daily quests progress
    await _updateDailyQuestsProgress(quest);

    // Save to storage
    await _storageService.saveUserProgress(_userProgress);
    await _storageService.updateQuest(completedQuest);
    await _storageService.saveDailyQuests(_dailyQuests);

    notifyListeners();
  }

  /// Add a new quest
  Future<void> addQuest(Quest quest) async {
    _quests.add(quest);
    await _storageService.addQuest(quest);
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
    // Save to storage
    await _storageService.updateQuest(cancelledQuest);

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
        await _storageService.saveUserProgress(_userProgress);
      }

      final index = _dailyQuests.indexWhere((dq) => dq.id == dailyQuest.id);
      if (index != -1) {
        _dailyQuests[index] = updated;
      }
    }
  }

  /// Check if daily quests need to be reset (new day)
  void _checkDailyQuestsReset() {
    final now = DateTime.now();
    final lastUpdate = _userProgress.lastUpdate;

    // Reset if it's a new day
    if (now.year != lastUpdate.year ||
        now.month != lastUpdate.month ||
        now.day != lastUpdate.day) {
      _resetDailyQuests();
    }
  }

  /// Reset daily quests for new day
  void _resetDailyQuests() {
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
    _storageService.saveDailyQuests(_dailyQuests);
    notifyListeners();
  }
}

