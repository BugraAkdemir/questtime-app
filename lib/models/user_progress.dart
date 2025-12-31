/// User progress and statistics
class UserProgress {
  int level;
  int currentXP;
  int totalXP;
  int totalStudyMinutes;
  int completedQuestsCount;
  int coins; // Coins earned from completing quests
  DateTime lastUpdate;

  UserProgress({
    this.level = 1,
    this.currentXP = 0,
    this.totalXP = 0,
    this.totalStudyMinutes = 0,
    this.completedQuestsCount = 0,
    this.coins = 0,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

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
  };

  /// Create from JSON
  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    level: json['level'] as int? ?? 1,
    currentXP: json['currentXP'] as int? ?? 0,
    totalXP: json['totalXP'] as int? ?? 0,
    totalStudyMinutes: json['totalStudyMinutes'] as int? ?? 0,
    completedQuestsCount: json['completedQuestsCount'] as int? ?? 0,
    coins: json['coins'] as int? ?? 0,
    lastUpdate: json['lastUpdate'] != null
        ? DateTime.parse(json['lastUpdate'] as String)
        : DateTime.now(),
  );

  /// Copy with updated values
  UserProgress copyWith({
    int? level,
    int? currentXP,
    int? totalXP,
    int? totalStudyMinutes,
    int? completedQuestsCount,
    int? coins,
    DateTime? lastUpdate,
  }) => UserProgress(
    level: level ?? this.level,
    currentXP: currentXP ?? this.currentXP,
    totalXP: totalXP ?? this.totalXP,
    totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
    completedQuestsCount: completedQuestsCount ?? this.completedQuestsCount,
    coins: coins ?? this.coins,
    lastUpdate: lastUpdate ?? this.lastUpdate,
  );
}
