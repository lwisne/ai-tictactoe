import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe_app/data/repositories/theme_repository.dart';
import 'package:tictactoe_app/domain/models/theme_preference.dart';

void main() {
  late ThemeRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = ThemeRepository();
  });

  group('ThemeRepository', () {
    group('saveThemeSettings', () {
      test('should save theme settings to SharedPreferences', () async {
        const settings = ThemeSettings(preference: ThemePreference.dark);

        await repository.saveThemeSettings(settings);

        final prefs = await SharedPreferences.getInstance();
        final savedJson = prefs.getString('theme_settings');
        expect(savedJson, isNotNull);
        expect(savedJson, contains('dark'));
      });

      test('should overwrite existing settings', () async {
        const settings1 = ThemeSettings(preference: ThemePreference.light);
        const settings2 = ThemeSettings(preference: ThemePreference.dark);

        await repository.saveThemeSettings(settings1);
        await repository.saveThemeSettings(settings2);

        final loaded = await repository.loadThemeSettings();
        expect(loaded.preference, ThemePreference.dark);
      });
    });

    group('loadThemeSettings', () {
      test('should load saved theme settings', () async {
        const settings = ThemeSettings(preference: ThemePreference.light);
        await repository.saveThemeSettings(settings);

        final loaded = await repository.loadThemeSettings();

        expect(loaded, equals(settings));
        expect(loaded.preference, ThemePreference.light);
      });

      test(
        'should return default settings when no saved settings exist',
        () async {
          final loaded = await repository.loadThemeSettings();

          expect(loaded.preference, ThemePreference.system);
        },
      );

      test(
        'should return default settings and clean up corrupted data',
        () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('theme_settings', 'invalid json');

          final loaded = await repository.loadThemeSettings();

          expect(loaded.preference, ThemePreference.system);
          expect(await repository.hasThemeSettings(), isFalse);
        },
      );

      test('should handle corrupted JSON gracefully', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('theme_settings', '{invalid}');

        final loaded = await repository.loadThemeSettings();

        expect(loaded.preference, ThemePreference.system);
      });
    });

    group('hasThemeSettings', () {
      test('should return true when settings exist', () async {
        const settings = ThemeSettings(preference: ThemePreference.dark);
        await repository.saveThemeSettings(settings);

        final exists = await repository.hasThemeSettings();

        expect(exists, isTrue);
      });

      test('should return false when no settings exist', () async {
        final exists = await repository.hasThemeSettings();

        expect(exists, isFalse);
      });

      test('should return false after settings are deleted', () async {
        const settings = ThemeSettings(preference: ThemePreference.light);
        await repository.saveThemeSettings(settings);
        await repository.deleteThemeSettings();

        final exists = await repository.hasThemeSettings();

        expect(exists, isFalse);
      });
    });

    group('deleteThemeSettings', () {
      test('should delete saved settings', () async {
        const settings = ThemeSettings(preference: ThemePreference.dark);
        await repository.saveThemeSettings(settings);

        await repository.deleteThemeSettings();

        expect(await repository.hasThemeSettings(), isFalse);
      });

      test('should not throw when deleting non-existent settings', () async {
        expect(() => repository.deleteThemeSettings(), returnsNormally);
      });

      test('should return default settings after deletion', () async {
        const settings = ThemeSettings(preference: ThemePreference.light);
        await repository.saveThemeSettings(settings);
        await repository.deleteThemeSettings();

        final loaded = await repository.loadThemeSettings();

        expect(loaded.preference, ThemePreference.system);
      });
    });

    group('Integration Tests', () {
      test('should persist all theme preferences correctly', () async {
        for (final preference in ThemePreference.values) {
          final settings = ThemeSettings(preference: preference);
          await repository.saveThemeSettings(settings);

          final loaded = await repository.loadThemeSettings();
          expect(loaded.preference, preference);
        }
      });

      test(
        'should maintain data integrity across multiple operations',
        () async {
          // Save
          const settings1 = ThemeSettings(preference: ThemePreference.dark);
          await repository.saveThemeSettings(settings1);
          expect(await repository.hasThemeSettings(), isTrue);

          // Load
          var loaded = await repository.loadThemeSettings();
          expect(loaded.preference, ThemePreference.dark);

          // Update
          const settings2 = ThemeSettings(preference: ThemePreference.light);
          await repository.saveThemeSettings(settings2);
          loaded = await repository.loadThemeSettings();
          expect(loaded.preference, ThemePreference.light);

          // Delete
          await repository.deleteThemeSettings();
          expect(await repository.hasThemeSettings(), isFalse);
          loaded = await repository.loadThemeSettings();
          expect(loaded.preference, ThemePreference.system);
        },
      );
    });
  });
}
