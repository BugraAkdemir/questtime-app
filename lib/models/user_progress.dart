/// User progress and statistics
class UserProgress {
  int level;
  int currentXP;
  int totalXP;
  int totalStudyMinutes;
  int completedQuestsCount;
  int coins; // Coins earned from completing quests
  DateTime lastUpdate;
  String? name; // User's display name
  String? username; // User's username
  int currentStreak; // Current daily study streak
  DateTime? lastStudyDate; // Last date user completed a quest
  Map<String, int> subjectStudyMinutes; // Minutes studied per subject

  UserProgress({
    this.level = 1,
    this.currentXP = 0,
    this.totalXP = 0,
    this.totalStudyMinutes = 0,
    this.completedQuestsCount = 0,
    this.coins = 0,
    DateTime? lastUpdate,
    this.name,
    this.username,
    this.currentStreak = 0,
    this.lastStudyDate,
    Map<String, int>? subjectStudyMinutes,
  })  : lastUpdate = lastUpdate ?? DateTime.now(),
        subjectStudyMinutes = subjectStudyMinutes ?? {};

  /// XP needed for next level
  int get xpForNextLevel {
    if (level == 1) return 1000;
    return (1000 * (1.2 * (level - 1))).round();
  }

  /// Progress percentage to next level (0.0 to 1.0)
  double get levelProgress {
    if (level == 1) {
      return currentXP / xpForNextLevel;
    }
    final previousLevelXP = level > 1
        ? (1000 * (1.2 * (level - 2))).round()
        : 0;
    final levelXP = currentXP - previousLevelXP;
    final levelXPNeeded = xpForNextLevel - previousLevelXP;
    return (levelXP / levelXPNeeded).clamp(0.0, 1.0);
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'level': level,
    'currentXP': currentXP,
    'totalXP': totalXP,
    'totalStudyMinutes': totalStudyMinutes,
    'completedQuestsCount': completedQuestsCount,
    'coins': coins,
    'lastUpdate': lastUpdate.toIso8601String(),
    'name': name,
    'username': username,
    'currentStreak': currentStreak,
    'lastStudyDate': lastStudyDate?.toIso8601String(),
    'subjectStudyMinutes': subjectStudyMinutes,
  };

  /// Create from JSON
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final subjectMinutes = json['subjectStudyMinutes'];
    Map<String, int> subjectMap = {};
    if (subjectMinutes != null && subjectMinutes is Map) {
      subjectMap = Map<String, int>.from(
        subjectMinutes.map((key, value) => MapEntry(
              key.toString(),
              value is int ? value : (value as num).toInt(),
            )),
      );
    }

    return UserProgress(
      level: json['level'] as int? ?? 1,
      currentXP: json['currentXP'] as int? ?? 0,
      totalXP: json['totalXP'] as int? ?? 0,
      totalStudyMinutes: json['totalStudyMinutes'] as int? ?? 0,
      completedQuestsCount: json['completedQuestsCount'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      lastUpdate: json['lastUpdate'] != null
          ? DateTime.parse(json['lastUpdate'] as String)
          : DateTime.now(),
      name: json['name'] as String?,
      username: json['username'] as String?,
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.parse(json['lastStudyDate'] as String)
          : null,
      subjectStudyMinutes: subjectMap,
    );
  }

  /// Copy with updated values
  UserProgress copyWith({
    int? level,
    int? currentXP,
    int? totalXP,
    int? totalStudyMinutes,
    int? completedQuestsCount,
    int? coins,
    DateTime? lastUpdate,
    String? name,
    String? username,
    int? currentStreak,
    DateTime? lastStudyDate,
    Map<String, int>? subjectStudyMinutes,
  }) => UserProgress(
    level: level ?? this.level,
    currentXP: currentXP ?? this.currentXP,
    totalXP: totalXP ?? this.totalXP,
    totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
    completedQuestsCount: completedQuestsCount ?? this.completedQuestsCount,
    coins: coins ?? this.coins,
    lastUpdate: lastUpdate ?? this.lastUpdate,
    name: name ?? this.name,
    username: username ?? this.username,
    currentStreak: currentStreak ?? this.currentStreak,
    lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    subjectStudyMinutes: subjectStudyMinutes ?? this.subjectStudyMinutes,
  );

  /// Get study minutes for a specific subject
  int getSubjectStudyMinutes(String subjectKey) {
    return subjectStudyMinutes[subjectKey] ?? 0;
  }

  /// Get study hours for a specific subject
  double getSubjectStudyHours(String subjectKey) {
    return getSubjectStudyMinutes(subjectKey) / 60.0;
  }
}
