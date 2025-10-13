import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/settings.dart';

void main() {
  group('Settings', () {
    test('defaults() creates expected settings', () {
      final settings = Settings.defaults();

      expect(settings.soundEnabled, true);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.aiDifficulty, AiDifficulty.medium);
    });

    test('copyWith updates only specified fields', () {
      final original = Settings.defaults();
      final updated = original.copyWith(soundEnabled: false);

      expect(updated.soundEnabled, false);
      expect(updated.themeMode, ThemeMode.system);
      expect(updated.aiDifficulty, AiDifficulty.medium);
    });

    test('copyWith creates independent copy', () {
      final original = Settings.defaults();
      final updated = original.copyWith(themeMode: ThemeMode.dark);

      expect(original.themeMode, ThemeMode.system);
      expect(updated.themeMode, ThemeMode.dark);
    });

    test('toJson creates correct map', () {
      final settings = const Settings(
        soundEnabled: false,
        themeMode: ThemeMode.dark,
        aiDifficulty: AiDifficulty.hard,
      );

      final json = settings.toJson();

      expect(json['soundEnabled'], false);
      expect(json['themeMode'], 'dark');
      expect(json['aiDifficulty'], 'hard');
    });

    test('fromJson creates correct settings', () {
      final json = {
        'soundEnabled': false,
        'themeMode': 'dark',
        'aiDifficulty': 'hard',
      };

      final settings = Settings.fromJson(json);

      expect(settings.soundEnabled, false);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.aiDifficulty, AiDifficulty.hard);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final settings = Settings.fromJson(json);

      expect(settings.soundEnabled, true);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.aiDifficulty, AiDifficulty.medium);
    });

    test('fromJson handles invalid theme mode', () {
      final json = {
        'soundEnabled': false,
        'themeMode': 'invalid',
        'aiDifficulty': 'easy',
      };

      final settings = Settings.fromJson(json);

      expect(settings.soundEnabled, false);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.aiDifficulty, AiDifficulty.easy);
    });

    test('fromJson handles invalid AI difficulty', () {
      final json = {
        'soundEnabled': true,
        'themeMode': 'light',
        'aiDifficulty': 'invalid',
      };

      final settings = Settings.fromJson(json);

      expect(settings.soundEnabled, true);
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.aiDifficulty, AiDifficulty.medium);
    });

    test('equality works correctly', () {
      final settings1 = const Settings(
        soundEnabled: true,
        themeMode: ThemeMode.dark,
        aiDifficulty: AiDifficulty.easy,
      );

      final settings2 = const Settings(
        soundEnabled: true,
        themeMode: ThemeMode.dark,
        aiDifficulty: AiDifficulty.easy,
      );

      expect(settings1, settings2);
    });

    test('inequality works correctly', () {
      final settings1 = Settings.defaults();
      final settings2 = settings1.copyWith(soundEnabled: false);

      expect(settings1, isNot(settings2));
    });
  });
}
