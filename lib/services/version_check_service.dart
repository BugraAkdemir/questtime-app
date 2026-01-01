import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckService {
  static const String _versionUrl =
      'https://bugradev.com/QuestTime/version.json';
  static String? _cachedUpdateUrl;
  static Map<String, String>? _cachedReleaseNotes;

  /// Initialize - no longer needed but kept for compatibility
  static Future<void> initialize() async {
    // No initialization needed for JSON-based version check
  }

  /// Check if app update is required
  static Future<bool> isUpdateRequired() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.parse(packageInfo.buildNumber);

      // Fetch version info from JSON endpoint
      final response = await http
          .get(Uri.parse(_versionUrl))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Version check timeout');
            },
          );

      if (response.statusCode != 200) {
        print('Version check: HTTP ${response.statusCode}');
        return false; // Don't block app if check fails
      }

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final minimumVersionCode = jsonData['minimum_version_code'] as int? ?? 0;
      _cachedUpdateUrl =
          jsonData['update_url'] as String? ?? 'https://bugradev.com/release';

      // Cache release notes
      if (jsonData['release_notes'] != null) {
        final notes = jsonData['release_notes'] as Map<String, dynamic>;
        _cachedReleaseNotes = {
          'tr': notes['tr'] as String? ?? '',
          'en': notes['en'] as String? ?? '',
        };
      }

      print('Version check: Current version code: $currentVersionCode');
      print('Version check: Minimum version code: $minimumVersionCode');

      // Check version code - if current version is lower than minimum, update is required
      final needsUpdate = currentVersionCode < minimumVersionCode;
      print(
        'Version check: Version comparison: $currentVersionCode < $minimumVersionCode = $needsUpdate',
      );
      return needsUpdate;
    } catch (e) {
      print('Version check error: $e');
      return false; // Don't block app if check fails
    }
  }

  /// Get update URL
  static String getUpdateUrl() {
    return _cachedUpdateUrl ?? 'https://bugradev.com/release';
  }

  /// Check if update is mandatory
  /// Always returns true if update is required (based on version code)
  static bool isUpdateMandatory() {
    return true; // All updates are mandatory when version code is outdated
  }

  /// Get release notes for current language
  static String? getReleaseNotes(String languageCode) {
    if (_cachedReleaseNotes == null) return null;
    return _cachedReleaseNotes![languageCode] ?? _cachedReleaseNotes!['en'];
  }

  /// Get current app version info
  static Future<Map<String, String>> getAppVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'packageName': packageInfo.packageName,
      };
    } catch (e) {
      return {
        'version': 'Unknown',
        'buildNumber': '0',
        'packageName': 'Unknown',
      };
    }
  }
}
