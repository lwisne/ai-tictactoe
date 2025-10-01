import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

/// Service for managing application settings with persistence
class SettingsService {
  static const String _settingsKey = 'app_settings';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  /// Load settings from storage, returns defaults if not found
  Settings loadSettings() {
    final String? settingsJson = _prefs.getString(_settingsKey);

    if (settingsJson == null) {
      return Settings.defaults();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(settingsJson);
      return Settings.fromJson(json);
    } catch (e) {
      // If parsing fails, return defaults
      return Settings.defaults();
    }
  }

  /// Save settings to storage
  Future<void> saveSettings(Settings settings) async {
    final String settingsJson = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, settingsJson);
  }

  /// Update sound enabled setting
  Future<void> setSoundEnabled(bool enabled) async {
    final settings = loadSettings();
    await saveSettings(settings.copyWith(soundEnabled: enabled));
  }

  /// Update theme mode setting
  Future<void> setThemeMode(ThemeMode mode) async {
    final settings = loadSettings();
    await saveSettings(settings.copyWith(themeMode: mode));
  }

  /// Update AI difficulty setting
  Future<void> setAiDifficulty(AiDifficulty difficulty) async {
    final settings = loadSettings();
    await saveSettings(settings.copyWith(aiDifficulty: difficulty));
  }

  /// Clear all settings (reset to defaults)
  Future<void> clearSettings() async {
    await _prefs.remove(_settingsKey);
  }
}
