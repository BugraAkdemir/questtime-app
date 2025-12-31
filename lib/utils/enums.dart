/// Subject categories for quests with XP multipliers
/// Base: 15 minutes = 100 XP
enum Subject {
  mathematics('Mathematics', '🔢', 1.2),
  physics('Physics', '⚛️', 1.3),
  chemistry('Chemistry', '🧪', 1.25),
  biology('Biology', '🧬', 1.1),
  geography('Geography', '🌍', 1.0),
  history('History', '📜', 1.0),
  literature('Literature', '📖', 1.05),
  english('English', '🇬🇧', 1.0),
  software('Software / Coding', '💻', 1.35),
  algorithms('Algorithms', '⚙️', 1.5),
  philosophy('Philosophy', '🤔', 1.15),
  economics('Economics', '💰', 1.2),
  psychology('Psychology', '🧠', 1.1),
  art('Art / Design', '🎨', 0.95),
  examRevision('Exam Revision', '📝', 1.4);

  const Subject(this.displayName, this.emoji, this.xpMultiplier);
  final String displayName;
  final String emoji;
  final double xpMultiplier;
}

/// Null-safe extension for Subject enum
extension SubjectExtension on Subject {
  /// Safe getter for displayName with fallback
  String get safeDisplayName {
    try {
      return displayName;
    } catch (e) {
      // Fallback to enum name if displayName is somehow null
      return name;
    }
  }

  /// Safe getter for emoji with fallback (deprecated - use SubjectIcons.getIcon instead)
  @Deprecated('Use SubjectIcons.getIcon instead')
  String get safeEmoji {
    try {
      return emoji;
    } catch (e) {
      // Fallback to default emoji if emoji is somehow null
      return '📚';
    }
  }

  /// Safe getter for xpMultiplier with fallback
  double get safeXpMultiplier {
    try {
      return xpMultiplier;
    } catch (e) {
      // Fallback to 1.0 if xpMultiplier is somehow null
      return 1.0;
    }
  }
}

/// Difficulty levels for quests
enum Difficulty {
  easy('Easy', 1.0),
  medium('Medium', 1.5),
  hard('Hard', 2.0);

  const Difficulty(this.displayName, this.xpMultiplier);
  final String displayName;
  final double xpMultiplier;
}

/// Null-safe extension for Difficulty enum
extension DifficultyExtension on Difficulty {
  /// Safe getter for displayName with fallback
  String get safeDisplayName {
    try {
      return displayName;
    } catch (e) {
      // Fallback to enum name if displayName is somehow null
      return name;
    }
  }

  /// Safe getter for xpMultiplier with fallback
  double get safeXpMultiplier {
    try {
      return xpMultiplier;
    } catch (e) {
      // Fallback to 1.0 if xpMultiplier is somehow null
      return 1.0;
    }
  }
}

/// Timer presets
enum TimerPreset {
  pomodoro(25),
  standard(40),
  custom(0);

  const TimerPreset(this.minutes);
  final int minutes;
}

/// Timer states
enum TimerState { idle, running, paused, completed }
