import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../models/quest.dart';
import '../models/daily_quest.dart';

/// Service for Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _userId != null;

  /// Get user progress collection reference
  CollectionReference get _userProgressCollection =>
      _firestore.collection('userProgress');

  /// Get quests collection reference
  CollectionReference get _questsCollection => _firestore.collection('quests');

  /// Get daily quests collection reference
  CollectionReference get _dailyQuestsCollection =>
      _firestore.collection('dailyQuests');

  /// Save user progress to Firestore
  Future<void> saveUserProgress(UserProgress progress) async {
    if (!isAuthenticated) {
      debugPrint('User not authenticated, cannot save progress');
      return;
    }

    try {
      final json = progress.toJson();
      debugPrint('Saving user progress to Firestore for user: $_userId');
      debugPrint('Progress data: totalXP=${progress.totalXP}, level=${progress.level}');
      await _userProgressCollection.doc(_userId).set(
            json,
            SetOptions(merge: true),
          );
      debugPrint('User progress saved successfully');
    } catch (e) {
      debugPrint('Error saving user progress: $e');
      rethrow;
    }
  }

  /// Load user progress from Firestore
  Future<UserProgress> loadUserProgress() async {
    if (!isAuthenticated) {
      debugPrint('User not authenticated, returning default progress');
      return UserProgress();
    }

    try {
      final doc = await _userProgressCollection.doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        return UserProgress.fromJson(doc.data()! as Map<String, dynamic>);
      } else {
        // Create default progress for new user
        final defaultProgress = UserProgress();
        await saveUserProgress(defaultProgress);
        return defaultProgress;
      }
    } catch (e) {
      debugPrint('Error loading user progress: $e');
      return UserProgress();
    }
  }

  /// Save a quest to Firestore
  Future<void> saveQuest(Quest quest) async {
    if (!isAuthenticated) {
      debugPrint('User not authenticated, cannot save quest');
      return;
    }

    try {
      await _questsCollection
          .doc(_userId)
          .collection('userQuests')
          .doc(quest.id)
          .set(quest.toJson());
    } catch (e) {
      debugPrint('Error saving quest: $e');
      rethrow;
    }
  }

  /// Load all quests from Firestore
  Future<List<Quest>> loadQuests() async {
    if (!isAuthenticated) {
      return [];
    }

    try {
      final snapshot = await _questsCollection
          .doc(_userId)
          .collection('userQuests')
          .get();

      return snapshot.docs
          .map((doc) => Quest.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error loading quests: $e');
      return [];
    }
  }

  /// Update a quest in Firestore
  Future<void> updateQuest(Quest quest) async {
    await saveQuest(quest);
  }

  /// Add a new quest to Firestore
  Future<void> addQuest(Quest quest) async {
    await saveQuest(quest);
  }

  /// Save daily quests to Firestore
  Future<void> saveDailyQuests(List<DailyQuest> dailyQuests) async {
    if (!isAuthenticated) {
      debugPrint('User not authenticated, cannot save daily quests');
      return;
    }

    try {
      final data = {
        'quests': dailyQuests.map((dq) => dq.toJson()).toList(),
        'lastUpdate': FieldValue.serverTimestamp(),
      };
      await _dailyQuestsCollection.doc(_userId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving daily quests: $e');
      rethrow;
    }
  }

  /// Load daily quests from Firestore
  Future<List<DailyQuest>> loadDailyQuests() async {
    if (!isAuthenticated) {
      return [];
    }

    try {
      final doc = await _dailyQuestsCollection.doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()! as Map<String, dynamic>;
        final questsList = data['quests'] as List<dynamic>?;
        if (questsList != null) {
          return questsList
              .map((json) => DailyQuest.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error loading daily quests: $e');
      return [];
    }
  }

  /// Delete user data (for account deletion)
  Future<void> deleteUserData() async {
    if (!isAuthenticated) {
      return;
    }

    try {
      // Delete user progress
      await _userProgressCollection.doc(_userId).delete();

      // Delete all quests
      final questsSnapshot = await _questsCollection
          .doc(_userId)
          .collection('userQuests')
          .get();
      for (var doc in questsSnapshot.docs) {
        await doc.reference.delete();
      }
      await _questsCollection.doc(_userId).delete();

      // Delete daily quests
      await _dailyQuestsCollection.doc(_userId).delete();
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      rethrow;
    }
  }

  /// Get top users for leaderboard (sorted by totalXP descending)
  Future<List<Map<String, dynamic>>> getTopUsers({int limit = 100}) async {
    try {
      debugPrint('Getting top users from Firestore...');
      debugPrint('Is authenticated: $isAuthenticated');

      final snapshot = await _userProgressCollection
          .orderBy('totalXP', descending: true)
          .limit(limit)
          .get();

      debugPrint('Snapshot size: ${snapshot.docs.length}');

      final users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('User ${doc.id}: totalXP = ${data['totalXP']}');
        return {
          'userId': doc.id,
          'name': data['name'] as String? ?? 'Anonymous',
          'username': data['username'] as String?,
          'totalXP': data['totalXP'] as int? ?? 0,
          'level': data['level'] as int? ?? 1,
          'completedQuestsCount': data['completedQuestsCount'] as int? ?? 0,
        };
      }).toList();

      debugPrint('Returning ${users.length} users');
      return users;
    } catch (e, stackTrace) {
      debugPrint('Error getting top users: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Get current user's rank in leaderboard
  Future<int> getUserRank() async {
    if (!isAuthenticated) {
      return -1;
    }

    try {
      final userProgress = await loadUserProgress();
      final userXP = userProgress.totalXP;

      // Count users with higher XP
      final snapshot = await _userProgressCollection
          .where('totalXP', isGreaterThan: userXP)
          .get();

      // Rank is 1-based, so add 1
      return snapshot.docs.length + 1;
    } catch (e) {
      debugPrint('Error getting user rank: $e');
      return -1;
    }
  }

  /// Get current user's leaderboard data
  Future<Map<String, dynamic>?> getCurrentUserLeaderboardData() async {
    if (!isAuthenticated) {
      return null;
    }

    try {
      final userProgress = await loadUserProgress();
      final user = _auth.currentUser;
      return {
        'userId': _userId,
        'name': userProgress.name ?? user?.email?.split('@')[0] ?? 'Anonymous',
        'username': userProgress.username,
        'totalXP': userProgress.totalXP,
        'level': userProgress.level,
        'completedQuestsCount': userProgress.completedQuestsCount,
      };
    } catch (e) {
      debugPrint('Error getting current user leaderboard data: $e');
      return null;
    }
  }
}

