import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/board_position.dart';
import 'package:tic_tac_toe/models/game_state.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/services/ai_service.dart';

/// Mock Random for deterministic testing
class MockRandom implements Random {
  final int _fixedValue;

  MockRandom(this._fixedValue);

  @override
  int nextInt(int max) => _fixedValue.clamp(0, max - 1);

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

void main() {
  group('AIService', () {
    late AIService service;

    setUp(() {
      service = AIService();
    });

    group('getEasyMove', () {
      test('returns null when no empty positions available', () {
        final state = GameState.initial();
        final emptyPositions = <BoardPosition>[];

        final move = service.getEasyMove(state, emptyPositions);

        expect(move, isNull);
      });

      test('returns the only available position', () {
        final state = GameState.initial();
        final emptyPositions = [BoardPosition(4)];

        final move = service.getEasyMove(state, emptyPositions);

        expect(move, isNotNull);
        expect(move!.index, equals(4));
      });

      test('returns a position from available empty positions', () {
        final state = GameState.initial();
        final emptyPositions = [
          BoardPosition(0),
          BoardPosition(3),
          BoardPosition(8),
        ];

        final move = service.getEasyMove(state, emptyPositions);

        expect(move, isNotNull);
        expect(emptyPositions.contains(move), isTrue);
      });

      test('uses random selection with deterministic Random', () {
        final mockRandom = MockRandom(1);
        final serviceWithMock = AIService(random: mockRandom);
        final state = GameState.initial();
        final emptyPositions = [
          BoardPosition(0),
          BoardPosition(4),
          BoardPosition(8),
        ];

        final move = serviceWithMock.getEasyMove(state, emptyPositions);

        expect(move, isNotNull);
        expect(move!.index, equals(4)); // Index 1 in emptyPositions list
      });

      test('selects first position when random returns 0', () {
        final mockRandom = MockRandom(0);
        final serviceWithMock = AIService(random: mockRandom);
        final state = GameState.initial();
        final emptyPositions = [
          BoardPosition(2),
          BoardPosition(5),
          BoardPosition(7),
        ];

        final move = serviceWithMock.getEasyMove(state, emptyPositions);

        expect(move, isNotNull);
        expect(move!.index, equals(2)); // First in emptyPositions list
      });

      test('selects last position when random returns max index', () {
        final mockRandom = MockRandom(2);
        final serviceWithMock = AIService(random: mockRandom);
        final state = GameState.initial();
        final emptyPositions = [
          BoardPosition(1),
          BoardPosition(3),
          BoardPosition(6),
        ];

        final move = serviceWithMock.getEasyMove(state, emptyPositions);

        expect(move, isNotNull);
        expect(move!.index, equals(6)); // Last in emptyPositions list
      });

      test('works with partially filled board', () {
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;
        board[1] = Player.o;
        board[4] = Player.x;
        board[8] = Player.o;

        final state = GameState(board: board, currentPlayer: Player.x);
        final emptyPositions = [
          BoardPosition(2),
          BoardPosition(3),
          BoardPosition(5),
          BoardPosition(6),
          BoardPosition(7),
        ];

        final move = service.getEasyMove(state, emptyPositions);

        expect(move, isNotNull);
        expect(emptyPositions.contains(move), isTrue);
      });

      test('performance: completes quickly with many positions', () {
        final state = GameState.initial();
        final emptyPositions = List.generate(
          9,
          (index) => BoardPosition(index),
        );

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          service.getEasyMove(state, emptyPositions);
        }

        stopwatch.stop();

        // Should complete 1000 moves in well under 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}
