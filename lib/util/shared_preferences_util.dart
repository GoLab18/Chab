import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static SharedPreferencesWithCache? _prefsWithCache;

  static const String _darkThemePrefKey = "isDarkTheme";

  /// Initialize shared preferences instance and retrieves initial preferences
  static Future<void> init() async {
    _prefsWithCache = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{_darkThemePrefKey}
      )
    );
  }

  static bool get isDarkTheme {
    try {
      return _prefsWithCache!.getBool(_darkThemePrefKey) ?? false;
    } catch (e) {
      throw Exception("Failed to load shared preferences");
    }
  }

  static Future<void> toggleThemesPrefs() async {
    try {
      await _prefsWithCache!.reloadCache();
      
      bool isDark = isDarkTheme;

      await _prefsWithCache!.setBool(
        _darkThemePrefKey,
        !isDark
      );
    } catch (e) {
      throw Exception("Failed to toggle dark theme preference");
    }
  }
}
