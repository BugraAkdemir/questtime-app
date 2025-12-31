import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/localizations.dart';
import '../widgets/quest_card.dart';

/// Stats screen showing user progress and statistics
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final crossAxisCount = isTablet ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final localizations = AppLocalizations(settings.language);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Text(localizations.stats),
              ],
            );
          },
        ),
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              final localizations = AppLocalizations(settings.language);
              return IconButton(
                icon: Icon(
                  settings.language == LanguageOption.turkish
                      ? Icons.language
                      : Icons.translate,
                ),
                tooltip: localizations.isTurkish
                    ? 'Dili Değiştir'
                    : 'Change Language',
                onPressed: () {
                  final newLang = settings.language == LanguageOption.turkish
                      ? LanguageOption.english
                      : LanguageOption.turkish;
                  settings.setLanguage(newLang);
                },
              );
            },
          ),
        ],
      ),
      body: Consumer2<AppStateProvider, SettingsProvider>(
        builder: (context, appState, settings, child) {
          final localizations = AppLocalizations(settings.language);
          final progress = appState.userProgress;
          final totalHours = (progress.totalStudyMinutes / 60).toStringAsFixed(
            1,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Level card
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 0,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.xpGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    boxShadow: AppTheme.softGlow,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 32 : 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${progress.level}',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    inherit: false,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${localizations.level} ${progress.level}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(inherit: false, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: progress.levelProgress,
                          minHeight: 12,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${progress.currentXP} / ${progress.xpForNextLevel} XP ${localizations.isTurkish ? "sonraki seviyeye" : "to next level"}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(inherit: false, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Stats grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isTablet ? 1.3 : 1.15,
                  children: [
                    _ModernStatCard(
                      title: localizations.totalXP,
                      value: '${progress.totalXP}',
                      icon: Icons.auto_awesome,
                      color: AppTheme.primaryPurple,
                    ),
                    _ModernStatCard(
                      title: localizations.isTurkish
                          ? 'Çalışma Süresi'
                          : 'Study Time',
                      value: '$totalHours h',
                      icon: Icons.timer_outlined,
                      color: AppTheme.secondaryBlue,
                    ),
                    _ModernStatCard(
                      title: localizations.isTurkish ? 'Puanlar' : 'Coins',
                      value: '${progress.coins}',
                      icon: Icons.monetization_on,
                      color: AppTheme.xpGreen,
                    ),
                    _ModernStatCard(
                      title: localizations.isTurkish ? 'Questler' : 'Quests',
                      value: '${progress.completedQuestsCount}',
                      icon: Icons.assignment,
                      color: AppTheme.xpCyan,
                    ),
                    if (isTablet)
                      _ModernStatCard(
                        title: localizations.isTurkish
                            ? 'Ortalama Seans'
                            : 'Avg Session',
                        value: progress.completedQuestsCount > 0
                            ? '${(progress.totalStudyMinutes / progress.completedQuestsCount).round()} min'
                            : '0 min',
                        icon: Icons.bar_chart,
                        color: Colors.purpleAccent,
                      ),
                  ],
                ),
                if (!isTablet) ...[
                  const SizedBox(height: 16),
                  _ModernStatCard(
                    title: localizations.isTurkish
                        ? 'Ortalama Seans'
                        : 'Avg Session',
                    value: progress.completedQuestsCount > 0
                        ? '${(progress.totalStudyMinutes / progress.completedQuestsCount).round()} min'
                        : '0 min',
                    icon: Icons.bar_chart,
                    color: Colors.purpleAccent,
                  ),
                ],
                const SizedBox(height: 32),
                // All completed quests
                if (appState.quests.isNotEmpty) ...[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.library_books,
                              color: AppTheme.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${localizations.isTurkish ? "Tüm Questler" : "All Quests"} (${appState.quests.length})',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...appState.quests.reversed.map(
                          (quest) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: QuestCard(quest: quest),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 0),
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.isTurkish
                              ? 'Henüz quest yok'
                              : 'No quests yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.isTurkish
                              ? 'İlk questini başlat ve burada istatistikleri gör!'
                              : 'Start your first quest to see stats here!',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Modern stat card widget with icon
class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  inherit: false,
                  color: color,
                  fontWeight: FontWeight.bold,
                  textBaseline: TextBaseline.alphabetic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  inherit: false,
                  fontWeight: FontWeight.w500,
                  textBaseline: TextBaseline.alphabetic,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
