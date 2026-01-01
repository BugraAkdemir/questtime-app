/// Achievement types
enum AchievementType {
  streak, // Streak-based achievements
  subject, // Subject-specific achievements
  total, // Total study time achievements
  quests, // Quest count achievements
}

/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // Material Icon name
  final AchievementType type;
  final int requirement; // Requirement value (days, hours, quests, etc.)
  final String? subjectKey; // For subject-specific achievements
  final int xpReward; // XP reward for unlocking
  final int coinReward; // Coin reward for unlocking

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.requirement,
    this.subjectKey,
    this.xpReward = 0,
    this.coinReward = 0,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'type': type.name,
    'requirement': requirement,
    'subjectKey': subjectKey,
    'xpReward': xpReward,
    'coinReward': coinReward,
  };

  /// Create from JSON
  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    icon: json['icon'] as String,
    type: AchievementType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => AchievementType.total,
    ),
    requirement: json['requirement'] as int,
    subjectKey: json['subjectKey'] as String?,
    xpReward: json['xpReward'] as int? ?? 0,
    coinReward: json['coinReward'] as int? ?? 0,
  );
}

/// User's achievement progress
class UserAchievement {
  final String achievementId;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress; // Current progress towards requirement

  UserAchievement({
    required this.achievementId,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  /// Progress percentage (0.0 to 1.0)
  double getProgressPercentage(int requirement) {
    if (requirement == 0) return 1.0;
    return (currentProgress / requirement).clamp(0.0, 1.0);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'currentProgress': currentProgress,
  };

  /// Create from JSON
  factory UserAchievement.fromJson(Map<String, dynamic> json) => UserAchievement(
    achievementId: json['achievementId'] as String,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    unlockedAt: json['unlockedAt'] != null
        ? DateTime.parse(json['unlockedAt'] as String)
        : null,
    currentProgress: json['currentProgress'] as int? ?? 0,
  );
}

/// Predefined achievements
class Achievements {
  static List<Achievement> getAllAchievements() {
    return [
      // Streak achievements
      Achievement(
        id: 'streak_7',
        title: '7 Day Streak',
        description: 'Study for 7 days in a row',
        icon: 'local_fire_department',
        type: AchievementType.streak,
        requirement: 7,
        xpReward: 500,
        coinReward: 50,
      ),
      Achievement(
        id: 'streak_30',
        title: '30 Day Streak',
        description: 'Study for 30 days in a row',
        icon: 'whatshot',
        type: AchievementType.streak,
        requirement: 30,
        xpReward: 2000,
        coinReward: 200,
      ),
      Achievement(
        id: 'streak_50',
        title: '50 Day Streak',
        description: 'Study for 50 days in a row',
        icon: 'emoji_events',
        type: AchievementType.streak,
        requirement: 50,
        xpReward: 5000,
        coinReward: 500,
      ),
      Achievement(
        id: 'streak_100',
        title: '100 Day Streak',
        description: 'Study for 100 days in a row',
        icon: 'stars',
        type: AchievementType.streak,
        requirement: 100,
        xpReward: 10000,
        coinReward: 1000,
      ),

      // Subject-specific achievements (10 hours = 600 minutes)
      Achievement(
        id: 'subject_math_10h',
        title: 'Mathematics Master',
        description: 'Study Mathematics for 10 hours',
        icon: 'calculate',
        type: AchievementType.subject,
        requirement: 600, // 10 hours in minutes
        subjectKey: 'mathematics',
        xpReward: 1000,
        coinReward: 100,
      ),
      Achievement(
        id: 'subject_science_10h',
        title: 'Science Expert',
        description: 'Study Science for 10 hours',
        icon: 'science',
        type: AchievementType.subject,
        requirement: 600,
        subjectKey: 'science',
        xpReward: 1000,
        coinReward: 100,
      ),
      Achievement(
        id: 'subject_history_10h',
        title: 'History Scholar',
        description: 'Study History for 10 hours',
        icon: 'menu_book',
        type: AchievementType.subject,
        requirement: 600,
        subjectKey: 'history',
        xpReward: 1000,
        coinReward: 100,
      ),
      Achievement(
        id: 'subject_language_10h',
        title: 'Language Learner',
        description: 'Study Language for 10 hours',
        icon: 'translate',
        type: AchievementType.subject,
        requirement: 600,
        subjectKey: 'language',
        xpReward: 1000,
        coinReward: 100,
      ),
      Achievement(
        id: 'subject_physics_10h',
        title: 'Physics Pro',
        description: 'Study Physics for 10 hours',
        icon: 'biotech',
        type: AchievementType.subject,
        requirement: 600,
        subjectKey: 'physics',
        xpReward: 1000,
        coinReward: 100,
      ),
      Achievement(
        id: 'subject_chemistry_10h',
        title: 'Chemistry Wizard',
        description: 'Study Chemistry for 10 hours',
        icon: 'science',
        type: AchievementType.subject,
        requirement: 600,
        subjectKey: 'chemistry',
        xpReward: 1000,
        coinReward: 100,
      ),
      Achievement(
        id: 'subject_biology_10h',
        title: 'Biology Expert',
        description: 'Study Biology for 10 hours',
        icon: 'eco',
        type: AchievementType.subject,
        requirement: 600,
        subjectKey: 'biology',
        xpReward: 1000,
        coinReward: 100,
      ),
      Achievement(
        id: 'subject_literature_10h',
        title: 'Literature Lover',
        description: 'Study Literature for 10 hours',
        icon: 'auto_stories',
        type: AchievementType.subject,
        requirement: 600,
        subjectKey: 'literature',
        xpReward: 1000,
        coinReward: 100,
      ),

      // Total study time achievements
      Achievement(
        id: 'total_10h',
        title: 'Dedicated Learner',
        description: 'Study for 10 hours total',
        icon: 'school',
        type: AchievementType.total,
        requirement: 600,
        xpReward: 500,
        coinReward: 50,
      ),
      Achievement(
        id: 'total_50h',
        title: 'Serious Student',
        description: 'Study for 50 hours total',
        icon: 'workspace_premium',
        type: AchievementType.total,
        requirement: 3000,
        xpReward: 2000,
        coinReward: 200,
      ),
      Achievement(
        id: 'total_100h',
        title: 'Study Master',
        description: 'Study for 100 hours total',
        icon: 'emoji_events',
        type: AchievementType.total,
        requirement: 6000,
        xpReward: 5000,
        coinReward: 500,
      ),

      // Quest count achievements
      Achievement(
        id: 'quests_10',
        title: 'Quest Starter',
        description: 'Complete 10 quests',
        icon: 'check_circle',
        type: AchievementType.quests,
        requirement: 10,
        xpReward: 300,
        coinReward: 30,
      ),
      Achievement(
        id: 'quests_50',
        title: 'Quest Warrior',
        description: 'Complete 50 quests',
        icon: 'military_tech',
        type: AchievementType.quests,
        requirement: 50,
        xpReward: 1500,
        coinReward: 150,
      ),
      Achievement(
        id: 'quests_100',
        title: 'Quest Champion',
        description: 'Complete 100 quests',
        icon: 'workspace_premium',
        type: AchievementType.quests,
        requirement: 100,
        xpReward: 3000,
        coinReward: 300,
      ),
    ];
  }

  /// Get achievement by ID
  static Achievement? getById(String id) {
    return getAllAchievements().firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('Achievement not found: $id'),
    );
  }

  /// Get achievements by type
  static List<Achievement> getByType(AchievementType type) {
    return getAllAchievements().where((a) => a.type == type).toList();
  }

  /// Get subject-specific achievements
  static List<Achievement> getSubjectAchievements(String subjectKey) {
    return getAllAchievements()
        .where((a) => a.type == AchievementType.subject && a.subjectKey == subjectKey)
        .toList();
  }
}

