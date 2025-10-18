import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/domain/models/position.dart';

void main() {
  group('Position', () {
    test('should create a position with row and col', () {
      const position = Position(row: 1, col: 2);
      expect(position.row, equals(1));
      expect(position.col, equals(2));
    });

    group('equality', () {
      test('should be equal when row and col match', () {
        const position1 = Position(row: 1, col: 2);
        const position2 = Position(row: 1, col: 2);
        expect(position1, equals(position2));
      });

      test('should not be equal when row differs', () {
        const position1 = Position(row: 1, col: 2);
        const position2 = Position(row: 0, col: 2);
        expect(position1, isNot(equals(position2)));
      });

      test('should not be equal when col differs', () {
        const position1 = Position(row: 1, col: 2);
        const position2 = Position(row: 1, col: 0);
        expect(position1, isNot(equals(position2)));
      });

      test('should not be equal when both row and col differ', () {
        const position1 = Position(row: 1, col: 2);
        const position2 = Position(row: 0, col: 0);
        expect(position1, isNot(equals(position2)));
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        const position = Position(row: 1, col: 2);
        final json = position.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['row'], equals(1));
        expect(json['col'], equals(2));
      });

      test('should deserialize from JSON correctly', () {
        final json = {'row': 1, 'col': 2};
        final position = Position.fromJson(json);

        expect(position.row, equals(1));
        expect(position.col, equals(2));
      });

      test('should round-trip serialize and deserialize correctly', () {
        const original = Position(row: 2, col: 1);
        final json = original.toJson();
        final deserialized = Position.fromJson(json);

        expect(deserialized, equals(original));
      });

      test('should handle all board positions (0-2, 0-2)', () {
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            final original = Position(row: row, col: col);
            final json = original.toJson();
            final deserialized = Position.fromJson(json);

            expect(deserialized, equals(original));
            expect(deserialized.row, equals(row));
            expect(deserialized.col, equals(col));
          }
        }
      });
    });

    group('toString', () {
      test('should provide readable string representation', () {
        const position = Position(row: 1, col: 2);
        expect(position.toString(), equals('Position(row: 1, col: 2)'));
      });
    });

    group('props', () {
      test('should include row and col in props for equality', () {
        const position = Position(row: 1, col: 2);
        expect(position.props, equals([1, 2]));
      });
    });
  });
}
