import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/theme_preference.dart';

/// Repository for persisting theme preferences
/// Follows Clean Architecture - handles data persistence only
@LazySingleton()
class ThemeRepository {
  static const String _themeSettingsKey = 'theme_settings';

  /// Saves theme settings to persistent storage
  Future<void> saveThemeSettings(ThemeSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(_themeSettingsKey, jsonString);
  }

  /// Loads theme settings from persistent storage
  /// Returns default settings (system theme) if no saved settings exist
  Future<ThemeSettings> loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_themeSettingsKey);

    if (jsonString == null) {
      return const ThemeSettings();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ThemeSettings.fromJson(json);
    } catch (e) {
      // If corrupted data, return default and clean up
      await deleteThemeSettings();
      return const ThemeSettings();
    }
  }

  /// Checks if saved theme settings exist
  Future<bool> hasThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_themeSettingsKey);
  }

  /// Deletes saved theme settings
  Future<void> deleteThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeSettingsKey);
  }
}
