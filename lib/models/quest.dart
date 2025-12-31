import 'package:uuid/uuid.dart';
import '../utils/enums.dart';

/// Represents a study quest/session
class Quest {
  final String id;
  final Subject subject;
  final Difficulty difficulty;
  final int durationMinutes;
  final DateTime startTime;
  DateTime? endTime;
  final int xpReward;
  final int coinReward; // Coins earned from completing quest
  bool isCompleted;
  final String? customSubjectName; // Custom subject name entered by user

  Quest({
    String? id,
    required this.subject,
    required this.difficulty,
    required this.durationMinutes,
    required this.startTime,
    this.endTime,
    int? xpReward,
    int? coinReward,
    this.isCompleted = false,
    this.customSubjectName,
  })  : id = id ?? const Uuid().v4(),
        xpReward = xpReward ?? _calculateXP(durationMinutes, subject),
        coinReward = coinReward ?? _calculateCoins(durationMinutes, subject);

  /// Get display name for subject (custom name if available, otherwise subject display name)
  String get subjectDisplayName {
    return customSubjectName ?? subject.displayName;
  }

  /// Calculate XP based on duration and subject multiplier
  /// Formula: XP = (durationMinutes / 15) × 100 × subjectMultiplier
  /// Base: 15 minutes = 100 XP
  /// Every minute gives proportional XP (no block system)
  /// Minimum 1 XP for any study time
  static int _calculateXP(int durationMinutes, Subject subject) {
    if (durationMinutes <= 0) return 0;

    const baseXPFor15Minutes = 100;
    final xpPerMinute = baseXPFor15Minutes / 15.0; // ~6.67 XP per minute base
    final totalXP = durationMinutes * xpPerMinute * subject.xpMultiplier;
    final roundedXP = totalXP.round();

    // Minimum 1 XP for any study time (even 1 second)
    return roundedXP > 0 ? roundedXP : 1;
  }

  /// Calculate coins based on duration and subject multiplier
  /// Formula: Coins = (durationMinutes / 15) × 10 × subjectMultiplier
  /// Base: 15 minutes = 10 coins
  /// Every minute gives proportional coins
  /// Minimum 1 coin for any study time
  static int _calculateCoins(int durationMinutes, Subject subject) {
    if (durationMinutes <= 0) return 0;

    const baseCoinsFor15Minutes = 10;
    final coinsPerMinute = baseCoinsFor15Minutes / 15.0; // ~0.67 coins per minute base
    final totalCoins = durationMinutes * coinsPerMinute * subject.xpMultiplier;
    final roundedCoins = totalCoins.round();

    // Minimum 1 coin for any study time
    return roundedCoins > 0 ? roundedCoins : 1;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject.name,
        'difficulty': difficulty.name,
        'durationMinutes': durationMinutes,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'xpReward': xpReward,
        'coinReward': coinReward,
        'isCompleted': isCompleted,
        'customSubjectName': customSubjectName,
      };

  /// Create from JSON
  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
        id: json['id'] as String,
        subject: Subject.values.firstWhere(
          (s) => s.name == json['subject'],
          orElse: () => Subject.mathematics,
        ),
        difficulty: Difficulty.values.firstWhere(
          (d) => d.name == json['difficulty'],
          orElse: () => Difficulty.medium,
        ),
        durationMinutes: json['durationMinutes'] as int,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        xpReward: json['xpReward'] as int,
        coinReward: json['coinReward'] as int? ?? 0,
        isCompleted: json['isCompleted'] as bool,
        customSubjectName: json['customSubjectName'] as String?,
      );

  /// Mark quest as completed
  Quest complete() {
    return Quest(
      id: id,
      subject: subject,
      difficulty: difficulty,
      durationMinutes: durationMinutes,
      startTime: startTime,
      endTime: DateTime.now(),
      xpReward: xpReward,
      coinReward: coinReward,
      isCompleted: true,
      customSubjectName: customSubjectName,
    );
  }

  /// Cancel quest and calculate partial XP based on time spent
  /// Returns a new Quest with partial XP and cancelled status
  /// Uses the same XP formula: (completedMinutes / 15) × 100 × subjectMultiplier
  Quest cancel(int completedMinutes) {
    // Calculate XP directly for completed minutes using the same formula
    final partialXP = _calculateXP(completedMinutes, subject);

    return Quest(
      id: id,
      subject: subject,
      difficulty: difficulty,
      durationMinutes: durationMinutes,
      startTime: startTime,
      endTime: DateTime.now(),
      xpReward: partialXP > 0 ? partialXP : 0,
      coinReward: 0, // No coins for cancelled quests
      isCompleted: false,
      customSubjectName: customSubjectName,
    );
  }
}

