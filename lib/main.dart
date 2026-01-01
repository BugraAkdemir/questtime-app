import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/market_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/achievements_screen.dart';
import 'services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/app_state_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/auth_provider.dart';

// Top-level function for background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handler
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize notification service
  await NotificationService().initialize();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const StudyQuestApp());
}

class StudyQuestApp extends StatelessWidget {
  const StudyQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()..initialize()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProxyProvider<AppStateProvider, ShopProvider>(
          create: (_) => ShopProvider(),
          update: (_, appState, shop) {
            shop ??= ShopProvider();
            final currentCoins = shop.userProgress?.coins;
            if (shop.userProgress == null ||
                currentCoins != appState.userProgress.coins) {
              shop.initialize(appState.userProgress);
            } else {
              shop.updateUserProgress(appState.userProgress);
            }
            return shop;
          },
        ),
      ],
      child: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settings, auth, child) {
          return MaterialApp(
            title: 'QuestTime',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system, // Always follow system theme
            home: const HomeScreen(),
            routes: {
              '/stats': (context) => const StatsScreen(),
              '/market': (context) => const MarketScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/leaderboard': (context) => const LeaderboardScreen(),
              '/achievements': (context) => const AchievementsScreen(),
            },
          );
        },
      ),
    );
  }
}
