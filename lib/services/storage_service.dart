import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest.dart';
import '../models/user_progress.dart';
import '../models/daily_quest.dart';

/// Service for local storage (offline-first approach)
/// Using SharedPreferences for simplicity, can be replaced with Hive later
class StorageService {
  static const String _userProgressKey = 'user_progress';
  static const String _questsKey = 'quests';
  static const String _dailyQuestsKey = 'daily_quests';

  /// Save user progress
  Future<void> saveUserProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProgressKey, jsonEncode(progress.toJson()));
  }

  /// Load user progress
  Future<UserProgress> loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userProgressKey);

    if (jsonString == null) {
      return UserProgress();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProgress.fromJson(json);
    } catch (e) {
      debugPrint('Error loading user progress: $e');
      return UserProgress();
    }
  }

  /// Save all quests
  Future<void> saveQuests(List<Quest> quests) async {
    final prefs = await SharedPreferences.getInstance();
    final questsJson = quests.map((q) => q.toJson()).toList();
    await prefs.setString(_questsKey, jsonEncode(questsJson));
  }

  /// Load all quests
  Future<List<Quest>> loadQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_questsKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> questsJson = jsonDecode(jsonString);
      return questsJson
          .map((json) => Quest.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading quests: $e');
      return [];
    }
  }

  /// Add a new quest
  Future<void> addQuest(Quest quest) async {
    final quests = await loadQuests();
    quests.add(quest);
    await saveQuests(quests);
  }

  /// Update a quest
  Future<void> updateQuest(Quest quest) async {
    final quests = await loadQuests();
    final index = quests.indexWhere((q) => q.id == quest.id);
    if (index != -1) {
      quests[index] = quest;
      await saveQuests(quests);
    }
  }

  /// Save daily quests
  Future<void> saveDailyQuests(List<DailyQuest> dailyQuests) async {
    final prefs = await SharedPreferences.getInstance();
    final json = dailyQuests.map((dq) => dq.toJson()).toList();
    await prefs.setString(_dailyQuestsKey, jsonEncode(json));
  }

  /// Load daily quests
  Future<List<DailyQuest>> loadDailyQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_dailyQuestsKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> questsJson = jsonDecode(jsonString);
      return questsJson
          .map((json) => DailyQuest.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading daily quests: $e');
      return [];
    }
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProgressKey);
    await prefs.remove(_questsKey);
    await prefs.remove(_dailyQuestsKey);
  }
}

