import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/settings_provider.dart';
import '../models/achievement.dart';
import '../theme/app_theme.dart';
import '../utils/localizations.dart';

/// Screen to display user achievements
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final localizations = AppLocalizations(settings.language);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Text(localizations.achievements),
              ],
            );
          },
        ),
      ),
      body: Consumer2<AppStateProvider, SettingsProvider>(
        builder: (context, appState, settings, child) {
          final localizations = AppLocalizations(settings.language);
          final allAchievements = Achievements.getAllAchievements();
          final userAchievements = appState.userAchievements;

          // Group achievements by type
          final streakAchievements = allAchievements
              .where((a) => a.type == AchievementType.streak)
              .toList();
          final subjectAchievements = allAchievements
              .where((a) => a.type == AchievementType.subject)
              .toList();
          final totalAchievements = allAchievements
              .where((a) => a.type == AchievementType.total)
              .toList();
          final questAchievements = allAchievements
              .where((a) => a.type == AchievementType.quests)
              .toList();

          final unlockedCount = userAchievements.values
              .where((ua) => ua.isUnlocked)
              .length;

          return CustomScrollView(
            slivers: [
              // Header with stats
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryPurple,
                        AppTheme.primaryPurpleLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    boxShadow: AppTheme.softGlow,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$unlockedCount / ${allAchievements.length}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizations.achievements,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Streak Achievements
              _buildAchievementSection(
                context,
                localizations,
                '${localizations.streak} ${localizations.achievements}',
                streakAchievements,
                userAchievements,
                Icons.local_fire_department,
              ),

              // Subject Achievements
              _buildAchievementSection(
                context,
                localizations,
                '${localizations.subject} ${localizations.achievements}',
                subjectAchievements,
                userAchievements,
                Icons.school,
              ),

              // Total Study Time Achievements
              _buildAchievementSection(
                context,
                localizations,
                '${localizations.totalXP} ${localizations.achievements}',
                totalAchievements,
                userAchievements,
                Icons.timer,
              ),

              // Quest Count Achievements
              _buildAchievementSection(
                context,
                localizations,
                '${localizations.questsCompleted} ${localizations.achievements}',
                questAchievements,
                userAchievements,
                Icons.check_circle,
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAchievementSection(
    BuildContext context,
    AppLocalizations localizations,
    String title,
    List<Achievement> achievements,
    Map<String, UserAchievement> userAchievements,
    IconData icon,
  ) {
    if (achievements.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryPurple, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...achievements.map((achievement) {
            final userAchievement =
                userAchievements[achievement.id] ??
                UserAchievement(achievementId: achievement.id);
            final isUnlocked = userAchievement.isUnlocked;
            final progress = userAchievement.currentProgress;
            final requirement = achievement.requirement;
            final progressPercent = userAchievement.getProgressPercentage(
              requirement,
            );

            return _buildAchievementCard(
              context,
              localizations,
              achievement,
              isUnlocked,
              progress,
              requirement,
              progressPercent,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    AppLocalizations localizations,
    Achievement achievement,
    bool isUnlocked,
    int progress,
    int requirement,
    double progressPercent,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppTheme.primaryPurple.withValues(alpha: isDark ? 0.3 : 0.15)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: isUnlocked
              ? AppTheme.primaryPurple
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked ? AppTheme.softGlow : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppTheme.primaryPurple
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(
              _getIconData(achievement.icon),
              color: isUnlocked
                  ? Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? AppTheme.primaryPurple
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUnlocked
                          ? AppTheme.primaryPurple
                          : AppTheme.primaryPurple.withValues(alpha: 0.6),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatProgress(progress, requirement, achievement.type),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatProgress(int progress, int requirement, AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return '$progress / $requirement days';
      case AchievementType.subject:
      case AchievementType.total:
        final hours = (progress / 60).toStringAsFixed(1);
        final reqHours = (requirement / 60).toStringAsFixed(1);
        return '$hours / $reqHours hours';
      case AchievementType.quests:
        return '$progress / $requirement quests';
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'stars':
        return Icons.stars;
      case 'calculate':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'menu_book':
        return Icons.menu_book;
      case 'translate':
        return Icons.translate;
      case 'biotech':
        return Icons.biotech;
      case 'eco':
        return Icons.eco;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'school':
        return Icons.school;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'check_circle':
        return Icons.check_circle;
      case 'military_tech':
        return Icons.military_tech;
      case 'timer':
        return Icons.timer;
      default:
        return Icons.star;
    }
  }
}
