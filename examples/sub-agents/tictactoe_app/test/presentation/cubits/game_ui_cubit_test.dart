import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/presentation/cubits/game_ui_cubit.dart';

void main() {
  late GameUICubit gameUICubit;

  setUp(() {
    gameUICubit = GameUICubit();
  });

  tearDown(() {
    gameUICubit.close();
  });

  group('GameUIState', () {
    test('initial state should have empty board and X as first player', () {
      const state = GameUIState.initial();

      expect(state.board, equals(['', '', '', '', '', '', '', '', '']));
      expect(state.currentPlayer, equals('X'));
      expect(state.isGameOver, isFalse);
    });

    test('should support copyWith with board', () {
      const state1 = GameUIState.initial();
      final newBoard = ['X', '', '', '', '', '', '', '', ''];
      final state2 = state1.copyWith(board: newBoard);

      expect(state2.board, equals(newBoard));
      expect(state2.currentPlayer, equals('X'));
      expect(state2.isGameOver, isFalse);
    });

    test('should support copyWith with currentPlayer', () {
      const state1 = GameUIState.initial();
      final state2 = state1.copyWith(currentPlayer: 'O');

      expect(state2.board, equals(['', '', '', '', '', '', '', '', '']));
      expect(state2.currentPlayer, equals('O'));
      expect(state2.isGameOver, isFalse);
    });

    test('should support copyWith with isGameOver', () {
      const state1 = GameUIState.initial();
      final state2 = state1.copyWith(isGameOver: true);

      expect(state2.board, equals(['', '', '', '', '', '', '', '', '']));
      expect(state2.currentPlayer, equals('X'));
      expect(state2.isGameOver, isTrue);
    });

    test('should support copyWith with multiple fields', () {
      const state1 = GameUIState.initial();
      final newBoard = ['X', 'O', 'X', '', '', '', '', '', ''];
      final state2 = state1.copyWith(
        board: newBoard,
        currentPlayer: 'O',
        isGameOver: true,
      );

      expect(state2.board, equals(newBoard));
      expect(state2.currentPlayer, equals('O'));
      expect(state2.isGameOver, isTrue);
    });

    test('should support equality comparison', () {
      const state1 = GameUIState.initial();
      const state2 = GameUIState.initial();
      final state3 = state1.copyWith(currentPlayer: 'O');
      final state4 = state1.copyWith(
        board: ['X', '', '', '', '', '', '', '', ''],
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
      expect(state1, isNot(equals(state4)));
    });

    test('should have immutable properties', () {
      const state = GameUIState.initial();
      final board1 = state.board;
      final board2 = state.board;

      // Verify that board is a different list instance
      expect(identical(board1, board2), isTrue);
    });

    test(
      'should support equality with same board values but different instance',
      () {
        final state1 = GameUIState(
          board: ['X', '', '', '', '', '', '', '', ''],
          currentPlayer: 'O',
        );
        final state2 = GameUIState(
          board: ['X', '', '', '', '', '', '', '', ''],
          currentPlayer: 'O',
        );

        expect(state1, equals(state2));
      },
    );
  });

  group('GameUICubit', () {
    test('initial state should have empty board and X as first player', () {
      expect(
        gameUICubit.state.board,
        equals(['', '', '', '', '', '', '', '', '']),
      );
      expect(gameUICubit.state.currentPlayer, equals('X'));
      expect(gameUICubit.state.isGameOver, isFalse);
    });

    blocTest<GameUICubit, GameUIState>(
      'handleCellTap should place X mark in empty cell',
      build: () => GameUICubit(),
      act: (cubit) => cubit.handleCellTap(0),
      expect: () => [
        GameUIState(
          board: ['X', '', '', '', '', '', '', '', ''],
          currentPlayer: 'O',
        ),
      ],
    );

    blocTest<GameUICubit, GameUIState>(
      'handleCellTap should place O mark when O is current player',
      build: () => GameUICubit(),
      seed: () => GameUIState(
        board: ['X', '', '', '', '', '', '', '', ''],
        currentPlayer: 'O',
      ),
      act: (cubit) => cubit.handleCellTap(1),
      expect: () => [
        GameUIState(
          board: ['X', 'O', '', '', '', '', '', '', ''],
          currentPlayer: 'X',
        ),
      ],
    );

    blocTest<GameUICubit, GameUIState>(
      'handleCellTap should switch players after each move',
      build: () => GameUICubit(),
      act: (cubit) async {
        cubit.handleCellTap(0); // X at index 0
        cubit.handleCellTap(1); // O at index 1
        cubit.handleCellTap(2); // X at index 2
      },
      expect: () => [
        // First move: X at 0, switch to O
        GameUIState(
          board: ['X', '', '', '', '', '', '', '', ''],
          currentPlayer: 'O',
        ),
        // Second move: O at 1, switch to X
        GameUIState(
          board: ['X', 'O', '', '', '', '', '', '', ''],
          currentPlayer: 'X',
        ),
        // Third move: X at 2, switch to O
        GameUIState(
          board: ['X', 'O', 'X', '', '', '', '', '', ''],
          currentPlayer: 'O',
        ),
      ],
    );

    blocTest<GameUICubit, GameUIState>(
      'handleCellTap should not update if cell is already filled',
      build: () => GameUICubit(),
      seed: () => GameUIState(
        board: ['X', '', '', '', '', '', '', '', ''],
        currentPlayer: 'O',
      ),
      act: (cubit) => cubit.handleCellTap(0), // Try to tap already filled cell
      expect: () => [], // No state change
    );

    blocTest<GameUICubit, GameUIState>(
      'handleCellTap should not update if game is over',
      build: () => GameUICubit(),
      seed: () => GameUIState(
        board: ['X', 'O', '', '', '', '', '', '', ''],
        currentPlayer: 'X',
        isGameOver: true,
      ),
      act: (cubit) => cubit.handleCellTap(2), // Try to tap when game is over
      expect: () => [], // No state change
    );

    blocTest<GameUICubit, GameUIState>(
      'handleCellTap should work for all valid cell indices',
      build: () => GameUICubit(),
      act: (cubit) async {
        for (int i = 0; i < 9; i++) {
          cubit.handleCellTap(i);
        }
      },
      expect: () => [
        // Index 0: X
        GameUIState(
          board: ['X', '', '', '', '', '', '', '', ''],
          currentPlayer: 'O',
        ),
        // Index 1: O
        GameUIState(
          board: ['X', 'O', '', '', '', '', '', '', ''],
          currentPlayer: 'X',
        ),
        // Index 2: X
        GameUIState(
          board: ['X', 'O', 'X', '', '', '', '', '', ''],
          currentPlayer: 'O',
        ),
        // Index 3: O
        GameUIState(
          board: ['X', 'O', 'X', 'O', '', '', '', '', ''],
          currentPlayer: 'X',
        ),
        // Index 4: X
        GameUIState(
          board: ['X', 'O', 'X', 'O', 'X', '', '', '', ''],
          currentPlayer: 'O',
        ),
        // Index 5: O
        GameUIState(
          board: ['X', 'O', 'X', 'O', 'X', 'O', '', '', ''],
          currentPlayer: 'X',
        ),
        // Index 6: X
        GameUIState(
          board: ['X', 'O', 'X', 'O', 'X', 'O', 'X', '', ''],
          currentPlayer: 'O',
        ),
        // Index 7: O
        GameUIState(
          board: ['X', 'O', 'X', 'O', 'X', 'O', 'X', 'O', ''],
          currentPlayer: 'X',
        ),
        // Index 8: X
        GameUIState(
          board: ['X', 'O', 'X', 'O', 'X', 'O', 'X', 'O', 'X'],
          currentPlayer: 'O',
        ),
      ],
    );

    blocTest<GameUICubit, GameUIState>(
      'handleCellTap should not modify original board list',
      build: () => GameUICubit(),
      act: (cubit) {
        final originalBoard = cubit.state.board;
        cubit.handleCellTap(0);
        // Original board should remain unchanged
        expect(originalBoard, equals(['', '', '', '', '', '', '', '', '']));
      },
      expect: () => [
        GameUIState(
          board: ['X', '', '', '', '', '', '', '', ''],
          currentPlayer: 'O',
        ),
      ],
    );

    blocTest<GameUICubit, GameUIState>(
      'resetGame should clear board and reset to initial state',
      build: () => GameUICubit(),
      seed: () => GameUIState(
        board: ['X', 'O', 'X', 'O', 'X', 'O', 'X', 'O', 'X'],
        currentPlayer: 'O',
        isGameOver: true,
      ),
      act: (cubit) => cubit.resetGame(),
      expect: () => [const GameUIState.initial()],
    );

    blocTest<GameUICubit, GameUIState>(
      'resetGame should work from any state',
      build: () => GameUICubit(),
      seed: () => GameUIState(
        board: ['X', 'O', '', '', '', '', '', '', ''],
        currentPlayer: 'X',
      ),
      act: (cubit) => cubit.resetGame(),
      expect: () => [const GameUIState.initial()],
    );

    blocTest<GameUICubit, GameUIState>(
      'should handle multiple resets',
      build: () => GameUICubit(),
      act: (cubit) async {
        cubit.handleCellTap(0);
        cubit.resetGame();
        cubit.handleCellTap(1);
        cubit.resetGame();
      },
      expect: () => [
        // First move
        GameUIState(
          board: ['X', '', '', '', '', '', '', '', ''],
          currentPlayer: 'O',
        ),
        // First reset
        const GameUIState.initial(),
        // Second move
        GameUIState(
          board: ['', 'X', '', '', '', '', '', '', ''],
          currentPlayer: 'O',
        ),
        // Second reset
        const GameUIState.initial(),
      ],
    );

    blocTest<GameUICubit, GameUIState>(
      'should handle full game sequence with reset',
      build: () => GameUICubit(),
      act: (cubit) async {
        // Play some moves
        cubit.handleCellTap(0); // X
        cubit.handleCellTap(1); // O
        cubit.handleCellTap(2); // X
        // Reset
        cubit.resetGame();
        // Play again
        cubit.handleCellTap(4); // X at center
        cubit.handleCellTap(8); // O at corner
      },
      expect: () => [
        // Initial moves
        GameUIState(
          board: ['X', '', '', '', '', '', '', '', ''],
          currentPlayer: 'O',
        ),
        GameUIState(
          board: ['X', 'O', '', '', '', '', '', '', ''],
          currentPlayer: 'X',
        ),
        GameUIState(
          board: ['X', 'O', 'X', '', '', '', '', '', ''],
          currentPlayer: 'O',
        ),
        // Reset
        const GameUIState.initial(),
        // New moves
        GameUIState(
          board: ['', '', '', '', 'X', '', '', '', ''],
          currentPlayer: 'O',
        ),
        GameUIState(
          board: ['', '', '', '', 'X', '', '', '', 'O'],
          currentPlayer: 'X',
        ),
      ],
    );

    blocTest<GameUICubit, GameUIState>(
      'handleCellTap should handle edge case: index 0',
      build: () => GameUICubit(),
      act: (cubit) => cubit.handleCellTap(0),
      expect: () => [
        GameUIState(
          board: ['X', '', '', '', '', '', '', '', ''],
          currentPlayer: 'O',
        ),
      ],
    );

    blocTest<GameUICubit, GameUIState>(
      'handleCellTap should handle edge case: index 8 (last cell)',
      build: () => GameUICubit(),
      act: (cubit) => cubit.handleCellTap(8),
      expect: () => [
        GameUIState(
          board: ['', '', '', '', '', '', '', '', 'X'],
          currentPlayer: 'O',
        ),
      ],
    );

    blocTest<GameUICubit, GameUIState>(
      'handleCellTap should handle edge case: middle cell (index 4)',
      build: () => GameUICubit(),
      act: (cubit) => cubit.handleCellTap(4),
      expect: () => [
        GameUIState(
          board: ['', '', '', '', 'X', '', '', '', ''],
          currentPlayer: 'O',
        ),
      ],
    );

    blocTest<GameUICubit, GameUIState>(
      'should not allow overwriting opponent mark',
      build: () => GameUICubit(),
      seed: () => GameUIState(
        board: ['X', '', '', '', '', '', '', '', ''],
        currentPlayer: 'O',
      ),
      act: (cubit) => cubit.handleCellTap(0), // O tries to overwrite X
      expect: () => [], // No state change
    );

    blocTest<GameUICubit, GameUIState>(
      'should not allow overwriting own mark',
      build: () => GameUICubit(),
      seed: () => GameUIState(
        board: ['', 'O', '', '', '', '', '', '', ''],
        currentPlayer: 'O',
      ),
      act: (cubit) => cubit.handleCellTap(1), // O tries to overwrite own mark
      expect: () => [], // No state change
    );
  });
}
