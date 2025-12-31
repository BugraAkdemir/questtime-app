import 'package:uuid/uuid.dart';

/// Daily quest challenges
enum DailyQuestType {
  completeQuests('Complete Quests', 'Complete {target} quests'),
  studyMinutes('Study Time', 'Study for {target} minutes');

  const DailyQuestType(this.title, this.descriptionTemplate);
  final String title;
  final String descriptionTemplate;
}

/// Represents a daily quest
class DailyQuest {
  final String id;
  final DailyQuestType type;
  final int target;
  final int progress;
  final int xpReward;
  final DateTime date;
  bool isCompleted;

  DailyQuest({
    String? id,
    required this.type,
    required this.target,
    this.progress = 0,
    required this.xpReward,
    required this.date,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  String get description {
    return type.descriptionTemplate.replaceAll('{target}', target.toString());
  }

  double get progressPercentage => (progress / target).clamp(0.0, 1.0);

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'target': target,
        'progress': progress,
        'xpReward': xpReward,
        'date': date.toIso8601String(),
        'isCompleted': isCompleted,
      };

  /// Create from JSON
  factory DailyQuest.fromJson(Map<String, dynamic> json) => DailyQuest(
        id: json['id'] as String,
        type: DailyQuestType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => DailyQuestType.completeQuests,
        ),
        target: json['target'] as int,
        progress: json['progress'] as int? ?? 0,
        xpReward: json['xpReward'] as int,
        date: DateTime.parse(json['date'] as String),
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  /// Update progress
  DailyQuest updateProgress(int newProgress) {
    final updatedProgress = newProgress.clamp(0, target);
    return DailyQuest(
      id: id,
      type: type,
      target: target,
      progress: updatedProgress,
      xpReward: xpReward,
      date: date,
      isCompleted: updatedProgress >= target,
    );
  }
}

