import 'package:flutter/material.dart';

/// StudyQuest Design System
///
/// Design Principles:
/// - Calm focus + subtle game energy
/// - Premium and modern feeling
/// - Minimal UI, no clutter
/// - Soft animations (200-400ms, ease-in-out)
///
/// Color Palette:
/// - Background: near-black / deep navy
/// - Primary: purple/indigo
/// - Secondary: soft blue
/// - XP/Reward: neon green/cyan
/// - Text: soft gray (avoid pure white)
class AppTheme {
  // ========== Color Palette ==========

  // Primary Accent - Purple/Indigo
  static const Color primaryPurple = Color(0xFF6366F1); // Indigo-500
  static const Color primaryPurpleLight = Color(0xFF818CF8); // Indigo-400
  static const Color primaryPurpleDark = Color(0xFF4F46E5); // Indigo-600

  // Secondary Accent - Soft Blue
  static const Color secondaryBlue = Color(0xFF60A5FA); // Blue-400
  static const Color secondaryBlueLight = Color(0xFF93C5FD); // Blue-300
  static const Color secondaryBlueDark = Color(0xFF3B82F6); // Blue-500

  // XP / Reward - Neon Green/Cyan
  static const Color xpGreen = Color(0xFF10B981); // Emerald-500
  static const Color xpCyan = Color(0xFF06B6D4); // Cyan-500
  static const Color xpNeon = Color(0xFF34D399); // Emerald-400

  // Background - Near-black / Deep Navy
  static const Color background = Color(0xFF0A0E27); // Deep navy
  static const Color surface = Color(0xFF111827); // Dark gray
  static const Color surfaceElevated = Color(0xFF1F2937); // Lighter dark gray
  static const Color surfaceVariant = Color(0xFF374151); // Medium gray

  // Text Colors - Soft Gray (avoid pure white)
  static const Color textPrimary = Color(0xFFF3F4F6); // Gray-100
  static const Color textSecondary = Color(0xFF9CA3AF); // Gray-400
  static const Color textTertiary = Color(0xFF6B7280); // Gray-500

  // Legacy colors (for backward compatibility)
  static const Color neonPurple = primaryPurple;
  static const Color neonBlue = secondaryBlue;
  static const Color neonCyan = xpCyan;
  static const Color darkBackground = background;
  static const Color darkSurface = surface;
  static const Color darkSurfaceVariant = surfaceVariant;

  // ========== Spacing System ==========
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ========== Border Radius ==========
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // ========== Animation Durations ==========
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 400);

  static const Curve animationCurve = Curves.easeInOut;

  /// Get the dark theme (default)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryPurple,
        secondary: secondaryBlue,
        tertiary: xpCyan,
        surface: surface,
        surfaceContainerHighest: surfaceElevated,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textPrimary,
        titleTextStyle: const TextStyle(
          inherit: false,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXL,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            inherit: false,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textSecondary,
          textStyle: const TextStyle(
            inherit: false,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
      textTheme: TextTheme(
        // Display - Large numbers for timer, XP, levels
        displayLarge: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -1.0,
          height: 1.1,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        displayMedium: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        displaySmall: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        // Headline - Section titles
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.3,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
          height: 1.3,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        // Body - Primary text
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0,
          height: 1.5,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0,
          height: 1.5,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textTertiary,
          letterSpacing: 0.2,
          height: 1.4,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        // Label - Buttons, chips
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
  }

  /// Get the light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryPurple,
        secondary: secondaryBlue,
        tertiary: xpCyan,
        surface: Colors.white,
        surfaceContainerHighest: const Color(0xFFF3F4F6),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF111827),
        onSurfaceVariant: const Color(0xFF6B7280),
      ),
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: const Color(0xFF111827),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111827),
          letterSpacing: -0.5,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXL,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            inherit: false,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF6B7280),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            inherit: false,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
          letterSpacing: -1.0,
          height: 1.1,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
          letterSpacing: -0.5,
          height: 1.2,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
          letterSpacing: -0.5,
          height: 1.2,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
          letterSpacing: -0.5,
          height: 1.3,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
          letterSpacing: -0.3,
          height: 1.3,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111827),
          letterSpacing: 0,
          height: 1.5,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
          letterSpacing: 0,
          height: 1.5,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF9CA3AF),
          letterSpacing: 0.2,
          height: 1.4,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
          letterSpacing: 0.5,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
  }

  // ========== Gradients ==========

  /// Primary gradient for XP/rewards
  static LinearGradient get xpGradient => const LinearGradient(
    colors: [xpGreen, xpCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Primary accent gradient
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryPurple, primaryPurpleLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary accent gradient
  static LinearGradient get secondaryGradient => const LinearGradient(
    colors: [secondaryBlue, secondaryBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Legacy gradient (for backward compatibility)
  static LinearGradient get neonGradient => primaryGradient;

  // ========== Shadows ==========

  /// Soft glow for focus elements (timer, selected items)
  static List<BoxShadow> get softGlow => [
    BoxShadow(
      color: primaryPurple.withValues(alpha: 0.2),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Subtle shadow for cards
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];

  /// Legacy glow (for backward compatibility)
  static List<BoxShadow> get neonGlow => softGlow;
}
