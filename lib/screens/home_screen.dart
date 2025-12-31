import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import '../models/quest.dart';
import '../providers/app_state_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/circular_timer.dart';
import '../widgets/quest_selection_dialog.dart';
import '../widgets/quest_card.dart';
import '../theme/app_theme.dart';
import '../services/xp_service.dart';
import '../utils/localizations.dart';
import 'auth_screen.dart';

/// Main screen with circular timer and quest management
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Quest? _currentQuest;
  int _currentElapsedSeconds = 0; // For stopwatch real-time display

  Future<void> _startNewQuest() async {
    final quest = await showDialog<Quest>(
      context: context,
      builder: (context) => const QuestSelectionDialog(),
    );

    if (quest != null && mounted) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      await appState.addQuest(quest);

      setState(() {
        _currentQuest = quest;
        _currentElapsedSeconds = 0; // Reset elapsed seconds
      });
    }
  }

  Future<void> _onTimerComplete() async {
    final quest = _currentQuest;
    if (quest == null) return;

    final completedQuest = quest;
    final questXP = completedQuest.xpReward;

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final shop = Provider.of<ShopProvider>(context, listen: false);

    await appState.completeQuest(completedQuest);
    shop.updateUserProgress(appState.userProgress);

    if (!mounted) return;

    final totalXP = appState.userProgress.totalXP;
    final level = appState.userProgress.level;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _CompletionDialog(questXP: questXP, totalXP: totalXP, level: level),
    ).then((_) {
      if (mounted) {
        setState(() {
          _currentQuest = null;
          _currentElapsedSeconds = 0; // Reset elapsed seconds
        });
      }
    });
  }

  void _onTimerTick(int remainingSeconds) {
    final quest = _currentQuest;
    if (quest != null && quest.isStopwatch) {
      // For stopwatch, remainingSeconds is actually elapsed seconds
      setState(() {
        _currentElapsedSeconds = remainingSeconds;
      });
    }
  }

  Future<void> _onTimerCancel(int completedMinutes) async {
    final quest = _currentQuest;
    if (quest == null) return;

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final localizations = AppLocalizations(
      Provider.of<SettingsProvider>(context, listen: false).language,
    );

    if (quest.isStopwatch) {
      // For stopwatch, complete with elapsed time
      final completedQuest = quest.completeStopwatch(completedMinutes);
      final questXP = completedQuest.xpReward;

      await appState.completeQuest(completedQuest);
      final shop = Provider.of<ShopProvider>(context, listen: false);
      shop.updateUserProgress(appState.userProgress);

      if (!mounted) return;

      final totalXP = appState.userProgress.totalXP;
      final level = appState.userProgress.level;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            _CompletionDialog(questXP: questXP, totalXP: totalXP, level: level),
      ).then((_) {
        if (mounted) {
          setState(() {
            _currentQuest = null;
          });
        }
      });
    } else {
      // For normal timer, cancel quest
      await appState.cancelQuest(quest, completedMinutes);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(localizations.questCancelled),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.isTurkish
                    ? 'Quest iptal edildi.'
                    : 'Quest has been cancelled.',
              ),
              const SizedBox(height: 8),
              Text(
                localizations.isTurkish
                    ? '$completedMinutes dakika çalıştın.'
                    : 'You studied for $completedMinutes minutes.',
              ),
              const SizedBox(height: 8),
              Text(
                localizations.xpOnlyOnCompletion,
                style: const TextStyle(inherit: false, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.ok),
            ),
          ],
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _currentQuest = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final localizations = AppLocalizations(settings.language);
            return Text(localizations.appTitle);
          },
        ),
        actions: [
          Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              final localizations = AppLocalizations(
                Provider.of<SettingsProvider>(context, listen: false).language,
              );
              return IconButton(
                icon: const Icon(Icons.store),
                tooltip: localizations.isTurkish ? 'Market' : 'Market',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      ),
                      title: Row(
                        children: [
                          Icon(
                            Icons.rocket_launch,
                            color: AppTheme.primaryPurple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            localizations.isTurkish ? 'Yakında' : 'Coming Soon',
                          ),
                        ],
                      ),
                      content: Text(
                        localizations.isTurkish
                            ? 'Market özelliği yakında eklenecek!'
                            : 'Market feature coming soon!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(localizations.ok),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.pushNamed(context, '/stats');
            },
            tooltip: 'Stats',
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              final localizations = AppLocalizations(settings.language);
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                tooltip: localizations.logout,
                onSelected: (value) async {
                  if (value == 'profile') {
                    Navigator.pushNamed(context, '/profile');
                  } else if (value == 'logout') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLG,
                          ),
                        ),
                        title: Text(localizations.logout),
                        content: Text(
                          localizations.isTurkish
                              ? 'Çıkış yapmak istediğinize emin misiniz?'
                              : 'Are you sure you want to logout?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(localizations.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(localizations.logout),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      // Clear local data before logout
                      final appStateProvider = Provider.of<AppStateProvider>(
                        context,
                        listen: false,
                      );
                      await appStateProvider.clearLocalData();
                      await authProvider.signOut();
                      // Navigation will be handled by main.dart
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 20),
                        const SizedBox(width: 8),
                        Text(localizations.profile),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 20),
                        const SizedBox(width: 8),
                        Text(localizations.logout),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer3<AppStateProvider, SettingsProvider, AuthProvider>(
        builder: (context, appState, settings, auth, child) {
          final localizations = AppLocalizations(settings.language);

          return Column(
            children: [
              // Warning banner if not logged in
              if (!auth.isAuthenticated)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade700, Colors.orange.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizations.notLoggedInWarning,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AuthScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          localizations.login,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 800 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        // Level and XP display
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryPurple.withValues(alpha: 0.15),
                                AppTheme.secondaryBlue.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusXL,
                            ),
                            border: Border.all(
                              color: AppTheme.primaryPurple.withValues(
                                alpha: 0.2,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isTablet ? 24 : 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            color: AppTheme.primaryPurple,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${localizations.level} ${appState.userProgress.level}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineMedium,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      LinearProgressIndicator(
                                        value:
                                            appState.userProgress.levelProgress,
                                        minHeight: 10,
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppTheme.primaryPurple,
                                            ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            size: 16,
                                            color: AppTheme.xpCyan,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${appState.userProgress.currentXP} / ${XPService.xpNeededForNextLevel(appState.userProgress)} XP',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.xpGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: AppTheme.softGlow,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.workspace_premium,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${appState.userProgress.totalXP}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              inherit: false,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Timer section
                        if (_currentQuest != null) ...[
                          Builder(
                            builder: (context) {
                              final quest = _currentQuest;
                              if (quest == null) return const SizedBox.shrink();
                              // Calculate real-time XP and coins for stopwatch
                              int currentXP = 0;
                              int currentCoins = 0;
                              if (quest.isStopwatch &&
                                  _currentElapsedSeconds > 0) {
                                currentXP = Quest.calculateXPForSeconds(
                                  _currentElapsedSeconds,
                                  quest.subject,
                                );
                                currentCoins = Quest.calculateCoinsForSeconds(
                                  _currentElapsedSeconds,
                                  quest.subject,
                                );
                              }

                              return Column(
                                children: [
                                  QuestCard(quest: quest),
                                  // Real-time XP and Coins display for stopwatch
                                  if (quest.isStopwatch &&
                                      _currentElapsedSeconds > 0) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppTheme.xpGreen.withValues(
                                              alpha: 0.15,
                                            ),
                                            AppTheme.xpCyan.withValues(
                                              alpha: 0.15,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusLG,
                                        ),
                                        border: Border.all(
                                          color: AppTheme.xpGreen.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // XP display
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.auto_awesome,
                                                    size: 20,
                                                    color: AppTheme.xpGreen,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '$currentXP',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium
                                                        ?.copyWith(
                                                          inherit: false,
                                                          color:
                                                              AppTheme.xpGreen,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          textBaseline:
                                                              TextBaseline
                                                                  .alphabetic,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'XP',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      inherit: false,
                                                      color: AppTheme
                                                          .textSecondary,
                                                      textBaseline: TextBaseline
                                                          .alphabetic,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          // Divider
                                          Container(
                                            width: 1,
                                            height: 40,
                                            color: AppTheme.textSecondary
                                                .withValues(alpha: 0.3),
                                          ),
                                          // Coins display
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.monetization_on,
                                                    size: 20,
                                                    color: AppTheme.xpCyan,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '$currentCoins',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium
                                                        ?.copyWith(
                                                          inherit: false,
                                                          color:
                                                              AppTheme.xpCyan,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          textBaseline:
                                                              TextBaseline
                                                                  .alphabetic,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                localizations.coins,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      inherit: false,
                                                      color: AppTheme
                                                          .textSecondary,
                                                      textBaseline: TextBaseline
                                                          .alphabetic,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  CircularTimer(
                                    durationMinutes: quest.durationMinutes,
                                    isStopwatch: quest.isStopwatch,
                                    onComplete: _onTimerComplete,
                                    onTick: _onTimerTick,
                                    onCancel: _onTimerCancel,
                                  ),
                                ],
                              );
                            },
                          ),
                        ] else
                          Container(
                            padding: EdgeInsets.all(isTablet ? 48 : 40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.xpGreen.withValues(alpha: 0.08),
                                  AppTheme.xpCyan.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusXL,
                              ),
                              border: Border.all(
                                color: AppTheme.xpGreen.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryPurple.withValues(
                                          alpha: 0.1,
                                        ),
                                        AppTheme.secondaryBlue.withValues(
                                          alpha: 0.1,
                                        ),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    size: 64,
                                    color: AppTheme.primaryPurple,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  localizations.readyToStudy,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: _startNewQuest,
                                  icon: const Icon(Icons.play_circle_outline),
                                  label: Text(localizations.startNewQuest),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 48 : 32,
                                      vertical: isTablet ? 20 : 16,
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 32),
                        // Recent quests
                        if (appState.quests.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusLG,
                              ),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.assignment,
                                      color: AppTheme.primaryPurple,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      localizations.recentQuests,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...appState.quests.reversed
                                    .take(5)
                                    .map(
                                      (quest) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: QuestCard(quest: quest),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Completion dialog with confetti animation
class _CompletionDialog extends StatefulWidget {
  final int questXP;
  final int totalXP;
  final int level;

  const _CompletionDialog({
    required this.questXP,
    required this.totalXP,
    required this.level,
  });

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations(
      Provider.of<SettingsProvider>(context, listen: false).language,
    );

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.xpGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.questCompleted,
                    style: const TextStyle(
                      inherit: false,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.xpGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      boxShadow: AppTheme.softGlow,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '+${widget.questXP} XP',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                inherit: false,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                textBaseline: TextBaseline.alphabetic,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${localizations.totalXP}: ${widget.totalXP}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${localizations.level}: ${widget.level}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          inherit: false,
                          color: AppTheme.textSecondary,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(localizations.awesome),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -50,
              left: 0,
              right: 0,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi / 2,
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.1,
                colors: const [
                  AppTheme.primaryPurple,
                  AppTheme.secondaryBlue,
                  AppTheme.xpGreen,
                  AppTheme.xpCyan,
                  AppTheme.xpNeon,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
