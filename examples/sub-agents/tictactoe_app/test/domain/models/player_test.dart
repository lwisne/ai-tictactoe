import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/domain/models/player.dart';

void main() {
  group('Player', () {
    group('opponent', () {
      test('should return O when player is X', () {
        expect(Player.x.opponent, equals(Player.o));
      });

      test('should return X when player is O', () {
        expect(Player.o.opponent, equals(Player.x));
      });

      test('should return none when player is none', () {
        expect(Player.none.opponent, equals(Player.none));
      });
    });

    group('fromString', () {
      test('should convert "x" to Player.x', () {
        expect(Player.fromString('x'), equals(Player.x));
      });

      test('should convert "o" to Player.o', () {
        expect(Player.fromString('o'), equals(Player.o));
      });

      test('should convert "none" to Player.none', () {
        expect(Player.fromString('none'), equals(Player.none));
      });

      test('should return null for invalid string', () {
        expect(Player.fromString('invalid'), isNull);
      });

      test('should return null for empty string', () {
        expect(Player.fromString(''), isNull);
      });

      test('should return null for null value', () {
        expect(Player.fromString(null), isNull);
      });
    });

    group('toStorageString', () {
      test('should convert Player.x to "x"', () {
        expect(Player.x.toStorageString(), equals('x'));
      });

      test('should convert Player.o to "o"', () {
        expect(Player.o.toStorageString(), equals('o'));
      });

      test('should convert Player.none to "none"', () {
        expect(Player.none.toStorageString(), equals('none'));
      });
    });

    group('round-trip serialization', () {
      test('should serialize and deserialize Player.x correctly', () {
        final serialized = Player.x.toStorageString();
        final deserialized = Player.fromString(serialized);
        expect(deserialized, equals(Player.x));
      });

      test('should serialize and deserialize Player.o correctly', () {
        final serialized = Player.o.toStorageString();
        final deserialized = Player.fromString(serialized);
        expect(deserialized, equals(Player.o));
      });

      test('should serialize and deserialize Player.none correctly', () {
        final serialized = Player.none.toStorageString();
        final deserialized = Player.fromString(serialized);
        expect(deserialized, equals(Player.none));
      });
    });
  });
}
