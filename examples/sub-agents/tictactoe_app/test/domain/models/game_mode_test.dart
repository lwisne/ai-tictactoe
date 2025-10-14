import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';

void main() {
  group('GameMode', () {
    group('fromString', () {
      test('should parse "vsAi" string to vsAi mode', () {
        final result = GameMode.fromString('vsAi');
        expect(result, GameMode.vsAi);
      });

      test('should parse "twoPlayer" string to twoPlayer mode', () {
        final result = GameMode.fromString('twoPlayer');
        expect(result, GameMode.twoPlayer);
      });

      test('should return null for invalid string', () {
        final result = GameMode.fromString('invalid');
        expect(result, isNull);
      });

      test('should return null for empty string', () {
        final result = GameMode.fromString('');
        expect(result, isNull);
      });

      test('should return null for null input', () {
        final result = GameMode.fromString(null);
        expect(result, isNull);
      });

      test('should return null for case-sensitive mismatch', () {
        final result = GameMode.fromString('VsAi'); // Wrong case
        expect(result, isNull);
      });

      test('should return null for whitespace string', () {
        final result = GameMode.fromString('   ');
        expect(result, isNull);
      });
    });

    group('toStorageString', () {
      test('should convert vsAi mode to "vsAi" string', () {
        expect(GameMode.vsAi.toStorageString(), 'vsAi');
      });

      test('should convert twoPlayer mode to "twoPlayer" string', () {
        expect(GameMode.twoPlayer.toStorageString(), 'twoPlayer');
      });
    });

    group('enum values', () {
      test('should have exactly two values', () {
        expect(GameMode.values.length, 2);
      });

      test('should contain vsAi and twoPlayer', () {
        expect(GameMode.values, contains(GameMode.vsAi));
        expect(GameMode.values, contains(GameMode.twoPlayer));
      });
    });

    group('round-trip serialization', () {
      test('should correctly round-trip vsAi mode', () {
        final storageString = GameMode.vsAi.toStorageString();
        final parsed = GameMode.fromString(storageString);
        expect(parsed, GameMode.vsAi);
      });

      test('should correctly round-trip twoPlayer mode', () {
        final storageString = GameMode.twoPlayer.toStorageString();
        final parsed = GameMode.fromString(storageString);
        expect(parsed, GameMode.twoPlayer);
      });

      test('should handle all enum values in round-trip', () {
        for (final mode in GameMode.values) {
          final storageString = mode.toStorageString();
          final parsed = GameMode.fromString(storageString);
          expect(parsed, mode);
        }
      });
    });
  });
}
