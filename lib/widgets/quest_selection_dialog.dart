import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quest.dart';
import '../utils/enums.dart';
import '../theme/app_theme.dart';
import '../utils/subject_icons.dart';
import '../utils/localizations.dart';
import '../providers/settings_provider.dart';

/// Dialog for selecting quest parameters before starting timer
class QuestSelectionDialog extends StatefulWidget {
  const QuestSelectionDialog({super.key});

  @override
  State<QuestSelectionDialog> createState() => _QuestSelectionDialogState();
}

class _QuestSelectionDialogState extends State<QuestSelectionDialog> {
  Subject _selectedSubject = Subject.mathematics;
  Difficulty _selectedDifficulty = Difficulty.medium;
  int _selectedDuration = 25;
  bool _useCustomDuration = false;
  bool _useCustomSubject = false;
  final TextEditingController _customDurationController =
      TextEditingController();
  final TextEditingController _customSubjectController =
      TextEditingController();

  @override
  void dispose() {
    _customDurationController.dispose();
    _customSubjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final localizations = AppLocalizations(settings.language);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      ),
      title: Text(localizations.startNewQuest),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom Subject checkbox
            Row(
              children: [
                Checkbox(
                  value: _useCustomSubject,
                  onChanged: (value) {
                    final newValue = value ?? false;
                    if (newValue != _useCustomSubject) {
                      setState(() {
                        _useCustomSubject = newValue;
                        if (!_useCustomSubject) {
                          _customSubjectController.clear();
                        }
                      });
                    }
                  },
                ),
                Text(localizations.customQuest),
              ],
            ),
            if (_useCustomSubject) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customSubjectController,
                decoration: InputDecoration(
                  labelText: localizations.enterSubjectName,
                  border: const OutlineInputBorder(),
                  hintText: localizations.isTurkish
                      ? 'örn: Türkçe'
                      : 'e.g., Spanish',
                  prefixIcon: const Icon(Icons.edit),
                  labelStyle: const TextStyle(
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ),
            ] else ...[
              // Subject selection
              Text(
                localizations.subject,
                style: const TextStyle(
                  inherit: false,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Subject.values.map((subject) {
                  final isSelected = _selectedSubject == subject;
                  return FilterChip(
                    avatar: Icon(
                      SubjectIcons.getIcon(subject),
                      size: 20,
                      color: isSelected
                          ? Colors.white
                          : SubjectIcons.getIconColor(subject),
                    ),
                    label: Text(subject.safeDisplayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedSubject = subject);
                      }
                    },
                    selectedColor: AppTheme.primaryPurple,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            // Difficulty selection
            Text(
              localizations.difficulty,
              style: const TextStyle(
                inherit: false,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Difficulty.values.map((difficulty) {
                final isSelected = _selectedDifficulty == difficulty;
                Color difficultyColor;
                IconData difficultyIcon;
                switch (difficulty) {
                  case Difficulty.easy:
                    difficultyColor = Colors.green.shade600;
                    difficultyIcon = Icons.check_circle_outline;
                    break;
                  case Difficulty.medium:
                    difficultyColor = Colors.orange.shade600;
                    difficultyIcon = Icons.radio_button_checked;
                    break;
                  case Difficulty.hard:
                    difficultyColor = Colors.red.shade600;
                    difficultyIcon = Icons.whatshot;
                    break;
                }
                return FilterChip(
                  avatar: Icon(
                    difficultyIcon,
                    size: 18,
                    color: isSelected ? Colors.white : difficultyColor,
                  ),
                  label: Text(difficulty.safeDisplayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedDifficulty = difficulty);
                    }
                  },
                  selectedColor: difficultyColor,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Duration selection
            Text(
              localizations.duration,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                inherit: false,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [15, 25, 30, 45, 60].map((duration) {
                final isSelected =
                    _selectedDuration == duration && !_useCustomDuration;
                return ChoiceChip(
                  avatar: Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: isSelected ? Colors.white : AppTheme.primaryPurple,
                  ),
                  label: Text('$duration min'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDuration = duration;
                        _useCustomDuration = false;
                      });
                    }
                  },
                  selectedColor: AppTheme.primaryPurple,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _useCustomDuration,
                  onChanged: (value) {
                    final newValue = value ?? false;
                    if (newValue != _useCustomDuration) {
                      setState(() {
                        _useCustomDuration = newValue;
                        if (_useCustomDuration &&
                            _customDurationController.text.isEmpty) {
                          _customDurationController.text = _selectedDuration
                              .toString();
                        }
                      });
                    }
                  },
                ),
                Text(localizations.customDuration),
              ],
            ),
            if (_useCustomDuration) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customDurationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: localizations.enterMinutes,
                  border: const OutlineInputBorder(),
                  hintText: localizations.isTurkish ? 'örn: 37' : 'e.g., 37',
                  prefixIcon: const Icon(Icons.timer_outlined),
                  labelStyle: const TextStyle(
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
                onChanged: (value) {
                  if (value.isEmpty) return;
                  final minutes = int.tryParse(value);
                  if (minutes != null && minutes > 0 && minutes <= 999) {
                    setState(() {
                      _selectedDuration = minutes;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (!context.mounted) return;

            try {
              // Validate custom subject
              String? customSubjectName;
              Subject questSubject = _selectedSubject;

              if (_useCustomSubject) {
                final customName = _customSubjectController.text.trim();
                if (customName.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.enterSubjectNameError),
                      ),
                    );
                  }
                  return;
                }
                customSubjectName = customName;
                // Use mathematics subject for custom quests (same XP multiplier)
                questSubject = Subject.mathematics;
              }

              // Validate duration
              int duration;
              if (_useCustomDuration) {
                final customText = _customDurationController.text.trim();
                if (customText.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.invalidDuration)),
                    );
                  }
                  return;
                }
                final parsedDuration = int.tryParse(customText);
                if (parsedDuration == null ||
                    parsedDuration <= 0 ||
                    parsedDuration > 999) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.invalidNumber)),
                    );
                  }
                  return;
                }
                duration = parsedDuration;
              } else {
                duration = _selectedDuration;
              }

              if (duration <= 0 || duration > 999) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.invalidDuration)),
                  );
                }
                return;
              }

              final quest = Quest(
                subject: questSubject,
                difficulty: _selectedDifficulty,
                durationMinutes: duration,
                startTime: DateTime.now(),
                customSubjectName: customSubjectName,
              );
              if (context.mounted) {
                Navigator.of(context).pop(quest);
              }
            } catch (e, stackTrace) {
              debugPrint('Error creating quest: $e');
              debugPrint('Stack trace: $stackTrace');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
          child: Text(localizations.startQuest),
        ),
      ],
    );
  }
}
