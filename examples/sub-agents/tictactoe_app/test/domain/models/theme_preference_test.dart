import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/domain/models/theme_preference.dart';

void main() {
  group('ThemePreference', () {
    test('should serialize to JSON correctly', () {
      expect(ThemePreference.system.toJson(), 'system');
      expect(ThemePreference.light.toJson(), 'light');
      expect(ThemePreference.dark.toJson(), 'dark');
    });

    test('should deserialize from JSON correctly', () {
      expect(ThemePreference.fromJson('system'), ThemePreference.system);
      expect(ThemePreference.fromJson('light'), ThemePreference.light);
      expect(ThemePreference.fromJson('dark'), ThemePreference.dark);
    });

    test('should fallback to system for invalid JSON', () {
      expect(ThemePreference.fromJson('invalid'), ThemePreference.system);
      expect(ThemePreference.fromJson(''), ThemePreference.system);
    });

    test('should have all three values', () {
      expect(ThemePreference.values.length, 3);
      expect(ThemePreference.values, contains(ThemePreference.system));
      expect(ThemePreference.values, contains(ThemePreference.light));
      expect(ThemePreference.values, contains(ThemePreference.dark));
    });
  });

  group('ThemeSettings', () {
    test('should have system as default preference', () {
      const settings = ThemeSettings();
      expect(settings.preference, ThemePreference.system);
    });

    test('should serialize to JSON correctly', () {
      const settings = ThemeSettings(preference: ThemePreference.dark);
      final json = settings.toJson();

      expect(json['preference'], 'dark');
    });

    test('should deserialize from JSON correctly', () {
      final json = {'preference': 'light'};
      final settings = ThemeSettings.fromJson(json);

      expect(settings.preference, ThemePreference.light);
    });

    test('should deserialize with default when preference is null', () {
      final json = <String, dynamic>{};
      final settings = ThemeSettings.fromJson(json);

      expect(settings.preference, ThemePreference.system);
    });

    test('should support copyWith for preference', () {
      const settings1 = ThemeSettings(preference: ThemePreference.system);
      final settings2 = settings1.copyWith(preference: ThemePreference.dark);

      expect(settings2.preference, ThemePreference.dark);
      expect(
        settings1.preference,
        ThemePreference.system,
      ); // Original unchanged
    });

    test('should return same instance when copyWith with no changes', () {
      const settings1 = ThemeSettings(preference: ThemePreference.light);
      final settings2 = settings1.copyWith();

      expect(settings2.preference, settings1.preference);
    });

    test('should support equality comparison', () {
      const settings1 = ThemeSettings(preference: ThemePreference.dark);
      const settings2 = ThemeSettings(preference: ThemePreference.dark);
      const settings3 = ThemeSettings(preference: ThemePreference.light);

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });

    test('should have correct props for Equatable', () {
      const settings = ThemeSettings(preference: ThemePreference.system);
      expect(settings.props, [ThemePreference.system]);
    });

    test('should round-trip through JSON correctly', () {
      const original = ThemeSettings(preference: ThemePreference.light);
      final json = original.toJson();
      final reconstructed = ThemeSettings.fromJson(json);

      expect(reconstructed, equals(original));
    });
  });
}
