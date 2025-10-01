import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/board_position.dart';

void main() {
  group('BoardPosition', () {
    group('constructor', () {
      test('creates position with valid index', () {
        for (int i = 0; i < 9; i++) {
          expect(() => BoardPosition(i), returnsNormally);
        }
      });

      test('throws assertion error for negative index', () {
        expect(() => BoardPosition(-1), throwsA(isA<AssertionError>()));
      });

      test('throws assertion error for index >= 9', () {
        expect(() => BoardPosition(9), throwsA(isA<AssertionError>()));
      });
    });

    group('row and col getters', () {
      test('returns correct row and col for position 0 (top-left)', () {
        final pos = BoardPosition(0);
        expect(pos.row, 0);
        expect(pos.col, 0);
      });

      test('returns correct row and col for position 4 (center)', () {
        final pos = BoardPosition(4);
        expect(pos.row, 1);
        expect(pos.col, 1);
      });

      test('returns correct row and col for position 8 (bottom-right)', () {
        final pos = BoardPosition(8);
        expect(pos.row, 2);
        expect(pos.col, 2);
      });

      test('returns correct row and col for all positions', () {
        final expected = [
          (0, 0), (0, 1), (0, 2),
          (1, 0), (1, 1), (1, 2),
          (2, 0), (2, 1), (2, 2),
        ];

        for (int i = 0; i < 9; i++) {
          final pos = BoardPosition(i);
          expect(pos.row, expected[i].$1, reason: 'Index $i row');
          expect(pos.col, expected[i].$2, reason: 'Index $i col');
        }
      });
    });

    group('fromRowCol factory', () {
      test('creates position from valid row and col', () {
        final pos = BoardPosition.fromRowCol(1, 2);
        expect(pos.index, 5);
        expect(pos.row, 1);
        expect(pos.col, 2);
      });

      test('throws assertion for invalid row', () {
        expect(() => BoardPosition.fromRowCol(-1, 0), throwsA(isA<AssertionError>()));
        expect(() => BoardPosition.fromRowCol(3, 0), throwsA(isA<AssertionError>()));
      });

      test('throws assertion for invalid col', () {
        expect(() => BoardPosition.fromRowCol(0, -1), throwsA(isA<AssertionError>()));
        expect(() => BoardPosition.fromRowCol(0, 3), throwsA(isA<AssertionError>()));
      });

      test('round trip conversion works', () {
        for (int i = 0; i < 9; i++) {
          final pos1 = BoardPosition(i);
          final pos2 = BoardPosition.fromRowCol(pos1.row, pos1.col);
          expect(pos2.index, i);
        }
      });
    });

    group('equality', () {
      test('same index positions are equal', () {
        expect(BoardPosition(3), BoardPosition(3));
      });

      test('different index positions are not equal', () {
        expect(BoardPosition(3), isNot(BoardPosition(4)));
      });
    });
  });
}
