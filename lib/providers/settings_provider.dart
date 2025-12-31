import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode options
enum ThemeModeOption {
  light,
  dark,
  system,
}

/// Language options
enum LanguageOption {
  english,
  turkish,
}

/// Settings provider for theme and language
class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';

  ThemeModeOption _themeMode = ThemeModeOption.system;
  LanguageOption _language = LanguageOption.english;

  ThemeModeOption get themeMode => _themeMode;
  LanguageOption get language => _language;

  /// Get Flutter ThemeMode from ThemeModeOption
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  /// Get language code
  String get languageCode {
    switch (_language) {
      case LanguageOption.english:
        return 'en';
      case LanguageOption.turkish:
        return 'tr';
    }
  }

  /// Get language display name
  String getLanguageDisplayName(LanguageOption lang) {
    switch (lang) {
      case LanguageOption.english:
        return _language == LanguageOption.turkish ? 'İngilizce' : 'English';
      case LanguageOption.turkish:
        return _language == LanguageOption.turkish ? 'Türkçe' : 'Turkish';
    }
  }

  /// Get theme mode display name
  String getThemeModeDisplayName(ThemeModeOption mode) {
    final isTurkish = _language == LanguageOption.turkish;
    switch (mode) {
      case ThemeModeOption.light:
        return isTurkish ? 'Açık' : 'Light';
      case ThemeModeOption.dark:
        return isTurkish ? 'Koyu' : 'Dark';
      case ThemeModeOption.system:
        return isTurkish ? 'Sistem' : 'System';
    }
  }

  /// Load settings from storage
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeModeOption.values.length) {
        _themeMode = ThemeModeOption.values[themeIndex];
      } else {
        _themeMode = ThemeModeOption.system; // Default
      }

      // Load language
      final languageIndex = prefs.getInt(_languageKey);
      if (languageIndex != null && languageIndex >= 0 && languageIndex < LanguageOption.values.length) {
        _language = LanguageOption.values[languageIndex];
      } else {
        _language = LanguageOption.english; // Default
      }

      notifyListeners();
    } catch (e) {
      // If loading fails, use defaults
      _themeMode = ThemeModeOption.system;
      _language = LanguageOption.english;
      notifyListeners();
    }
  }

  /// Save theme mode
  Future<void> setThemeMode(ThemeModeOption mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  /// Save language
  Future<void> setLanguage(LanguageOption lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_languageKey, lang.index);
    notifyListeners();
  }
}

