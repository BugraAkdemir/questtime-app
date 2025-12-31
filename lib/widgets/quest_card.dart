import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../theme/app_theme.dart';
import '../utils/subject_icons.dart';

/// Modern card widget for displaying quest information
class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onTap;

  const QuestCard({
    super.key,
    required this.quest,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Row(
              children: [
                // Subject icon with modern container
                Container(
                  width: isTablet ? 72 : 64,
                  height: isTablet ? 72 : 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        SubjectIcons.getIconColor(quest.subject)
                            .withValues(alpha: 0.15),
                        SubjectIcons.getIconColor(quest.subject)
                            .withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: SubjectIcons.getIconColor(quest.subject)
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    SubjectIcons.getIcon(quest.subject),
                    size: isTablet ? 36 : 32,
                    color: SubjectIcons.getIconColor(quest.subject),
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
                // Quest info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.subjectDisplayName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${quest.durationMinutes} min',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(quest.difficulty)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                              border: Border.all(
                                color: _getDifficultyColor(quest.difficulty)
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getDifficultyIcon(quest.difficulty),
                                  size: 14,
                                  color: _getDifficultyColor(quest.difficulty),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  quest.difficulty.displayName,
                                  style: TextStyle(
                                    inherit: false,
                                    color: _getDifficultyColor(quest.difficulty),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // XP reward
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.xpGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    boxShadow: AppTheme.softGlow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${quest.xpReward}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              inherit: false,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                      ),
                      Text(
                        'XP',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              inherit: false,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(dynamic difficulty) {
    switch (difficulty.displayName) {
      case 'Easy':
        return Colors.green.shade600;
      case 'Medium':
        return Colors.orange.shade600;
      case 'Hard':
        return Colors.red.shade600;
      default:
        return AppTheme.primaryPurple;
    }
  }

  IconData _getDifficultyIcon(dynamic difficulty) {
    switch (difficulty.displayName) {
      case 'Easy':
        return Icons.check_circle_outline;
      case 'Medium':
        return Icons.radio_button_checked;
      case 'Hard':
        return Icons.whatshot;
      default:
        return Icons.circle_outlined;
    }
  }
}
