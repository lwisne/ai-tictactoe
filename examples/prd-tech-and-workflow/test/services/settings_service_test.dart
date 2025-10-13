import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/models/settings.dart';
import 'package:tic_tac_toe/services/settings_service.dart';

void main() {
  group('SettingsService', () {
    late SettingsService settingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
    });

    test('loadSettings returns defaults when no settings stored', () {
      final settings = settingsService.loadSettings();

      expect(settings.soundEnabled, true);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.aiDifficulty, AiDifficulty.medium);
    });

    test('saveSettings persists settings', () async {
      final settings = const Settings(
        soundEnabled: false,
        themeMode: ThemeMode.dark,
        aiDifficulty: AiDifficulty.hard,
      );

      await settingsService.saveSettings(settings);
      final loaded = settingsService.loadSettings();

      expect(loaded, settings);
    });

    test('loadSettings handles corrupted JSON gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_settings', 'invalid json');

      final settings = settingsService.loadSettings();

      expect(settings, Settings.defaults());
    });

    test('setSoundEnabled updates only sound setting', () async {
      await settingsService.setSoundEnabled(false);

      final settings = settingsService.loadSettings();

      expect(settings.soundEnabled, false);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.aiDifficulty, AiDifficulty.medium);
    });

    test('setThemeMode updates only theme setting', () async {
      await settingsService.setThemeMode(ThemeMode.dark);

      final settings = settingsService.loadSettings();

      expect(settings.soundEnabled, true);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.aiDifficulty, AiDifficulty.medium);
    });

    test('setAiDifficulty updates only AI difficulty setting', () async {
      await settingsService.setAiDifficulty(AiDifficulty.hard);

      final settings = settingsService.loadSettings();

      expect(settings.soundEnabled, true);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.aiDifficulty, AiDifficulty.hard);
    });

    test('clearSettings removes stored settings', () async {
      final settings = const Settings(
        soundEnabled: false,
        themeMode: ThemeMode.dark,
        aiDifficulty: AiDifficulty.easy,
      );

      await settingsService.saveSettings(settings);
      await settingsService.clearSettings();

      final loaded = settingsService.loadSettings();

      expect(loaded, Settings.defaults());
    });

    test('multiple updates persist correctly', () async {
      await settingsService.setSoundEnabled(false);
      await settingsService.setThemeMode(ThemeMode.light);
      await settingsService.setAiDifficulty(AiDifficulty.easy);

      final settings = settingsService.loadSettings();

      expect(settings.soundEnabled, false);
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.aiDifficulty, AiDifficulty.easy);
    });

    test('settings persist across service instances', () async {
      final settings = const Settings(
        soundEnabled: false,
        themeMode: ThemeMode.dark,
        aiDifficulty: AiDifficulty.hard,
      );

      await settingsService.saveSettings(settings);

      // Create new service instance
      final prefs = await SharedPreferences.getInstance();
      final newService = SettingsService(prefs);
      final loaded = newService.loadSettings();

      expect(loaded, settings);
    });
  });
}
