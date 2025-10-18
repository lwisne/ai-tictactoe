import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/domain/models/game_result.dart';

void main() {
  group('GameResult', () {
    group('fromString', () {
      test('should convert "ongoing" to GameResult.ongoing', () {
        expect(GameResult.fromString('ongoing'), equals(GameResult.ongoing));
      });

      test('should convert "win" to GameResult.win', () {
        expect(GameResult.fromString('win'), equals(GameResult.win));
      });

      test('should convert "loss" to GameResult.loss', () {
        expect(GameResult.fromString('loss'), equals(GameResult.loss));
      });

      test('should convert "draw" to GameResult.draw', () {
        expect(GameResult.fromString('draw'), equals(GameResult.draw));
      });

      test('should return null for invalid string', () {
        expect(GameResult.fromString('invalid'), isNull);
      });

      test('should return null for empty string', () {
        expect(GameResult.fromString(''), isNull);
      });

      test('should return null for null value', () {
        expect(GameResult.fromString(null), isNull);
      });
    });

    group('toStorageString', () {
      test('should convert GameResult.ongoing to "ongoing"', () {
        expect(GameResult.ongoing.toStorageString(), equals('ongoing'));
      });

      test('should convert GameResult.win to "win"', () {
        expect(GameResult.win.toStorageString(), equals('win'));
      });

      test('should convert GameResult.loss to "loss"', () {
        expect(GameResult.loss.toStorageString(), equals('loss'));
      });

      test('should convert GameResult.draw to "draw"', () {
        expect(GameResult.draw.toStorageString(), equals('draw'));
      });
    });

    group('round-trip serialization', () {
      test('should serialize and deserialize GameResult.ongoing correctly', () {
        final serialized = GameResult.ongoing.toStorageString();
        final deserialized = GameResult.fromString(serialized);
        expect(deserialized, equals(GameResult.ongoing));
      });

      test('should serialize and deserialize GameResult.win correctly', () {
        final serialized = GameResult.win.toStorageString();
        final deserialized = GameResult.fromString(serialized);
        expect(deserialized, equals(GameResult.win));
      });

      test('should serialize and deserialize GameResult.loss correctly', () {
        final serialized = GameResult.loss.toStorageString();
        final deserialized = GameResult.fromString(serialized);
        expect(deserialized, equals(GameResult.loss));
      });

      test('should serialize and deserialize GameResult.draw correctly', () {
        final serialized = GameResult.draw.toStorageString();
        final deserialized = GameResult.fromString(serialized);
        expect(deserialized, equals(GameResult.draw));
      });
    });
  });
}
