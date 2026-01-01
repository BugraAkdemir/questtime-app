import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service for handling push notifications and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request permission for iOS
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
      } else {
        debugPrint('User declined notification permission');
      }

      // Note: Local notifications can be added later if needed
      // For now, we'll use FCM for notifications

      // Get FCM token and save to Firestore
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      await _saveFCMTokenToFirestore(token);

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM Token refreshed: $newToken');
        await _saveFCMTokenToFirestore(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages (when app is terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      _initialized = true;
      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }


  /// Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.notification?.title}');
    // FCM will handle displaying the notification
  }

  /// Handle background message (when app is opened from notification)
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Background message received: ${message.notification?.title}');
    // Navigate to appropriate screen
  }

  /// Schedule daily study reminder
  /// Note: This should be configured in Firebase Console
  /// For now, this is a placeholder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    try {
      debugPrint('Daily reminder should be configured in Firebase Console');
      debugPrint('Schedule: $hour:$minute - $title: $body');
      // FCM scheduled notifications should be set up via Firebase Console
      // or Cloud Functions
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
    }
  }

  /// Show achievement unlocked notification
  /// Note: This can be triggered via FCM or local notification
  Future<void> showAchievementNotification({
    required String achievementTitle,
    required String achievementDescription,
  }) async {
    debugPrint('Achievement unlocked: $achievementTitle - $achievementDescription');
    // Can be implemented with local notifications if needed
  }

  /// Save FCM token to Firestore
  Future<void> _saveFCMTokenToFirestore(String? token) async {
    if (token == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('User not authenticated, cannot save FCM token');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('userProgress')
          .doc(user.uid)
          .set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('FCM Token saved to Firestore for user: ${user.uid}');
    } catch (e) {
      debugPrint('Error saving FCM token to Firestore: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}


