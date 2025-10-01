import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/blocs/game_cubit.dart';
import 'package:tic_tac_toe/models/board_position.dart';
import 'package:tic_tac_toe/models/game_state.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/services/game_service.dart';

void main() {
  group('GameCubit', () {
    late GameService gameService;
    late GameCubit cubit;

    setUp(() {
      gameService = GameService();
      cubit = GameCubit(gameService);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is GameState.initial()', () {
      expect(cubit.state, GameState.initial());
    });

    group('makeMove', () {
      blocTest<GameCubit, GameState>(
        'emits new state with move at position 0',
        build: () => GameCubit(gameService),
        act: (cubit) => cubit.makeMove(BoardPosition(0)),
        expect: () => [
          isA<GameState>()
              .having((s) => s.board[0], 'board[0]', Player.x)
              .having((s) => s.currentPlayer, 'currentPlayer', Player.o),
        ],
      );

      blocTest<GameCubit, GameState>(
        'emits states for sequence of moves',
        build: () => GameCubit(gameService),
        act: (cubit) {
          cubit.makeMove(BoardPosition(0)); // X
          cubit.makeMove(BoardPosition(1)); // O
          cubit.makeMove(BoardPosition(2)); // X
        },
        expect: () => [
          // After first move
          isA<GameState>()
              .having((s) => s.board[0], 'board[0]', Player.x)
              .having((s) => s.currentPlayer, 'currentPlayer', Player.o),
          // After second move
          isA<GameState>()
              .having((s) => s.board[0], 'board[0]', Player.x)
              .having((s) => s.board[1], 'board[1]', Player.o)
              .having((s) => s.currentPlayer, 'currentPlayer', Player.x),
          // After third move
          isA<GameState>()
              .having((s) => s.board[0], 'board[0]', Player.x)
              .having((s) => s.board[1], 'board[1]', Player.o)
              .having((s) => s.board[2], 'board[2]', Player.x)
              .having((s) => s.currentPlayer, 'currentPlayer', Player.o),
        ],
      );

      blocTest<GameCubit, GameState>(
        'does not emit when move is invalid (occupied position)',
        build: () => GameCubit(gameService),
        act: (cubit) {
          cubit.makeMove(BoardPosition(0)); // Valid move
          cubit.makeMove(BoardPosition(0)); // Invalid - already occupied
        },
        expect: () => [
          // Only first move should emit
          isA<GameState>()
              .having((s) => s.board[0], 'board[0]', Player.x)
              .having((s) => s.currentPlayer, 'currentPlayer', Player.o),
        ],
      );
    });

    group('resetGame', () {
      blocTest<GameCubit, GameState>(
        'emits initial state',
        build: () => GameCubit(gameService),
        seed: () {
          // Create a state with some moves
          final board = List<Player?>.filled(9, null);
          board[0] = Player.x;
          board[1] = Player.o;
          return GameState(board: board, currentPlayer: Player.x);
        },
        act: (cubit) => cubit.resetGame(),
        expect: () => [GameState.initial()],
      );

      blocTest<GameCubit, GameState>(
        'resets game after multiple moves',
        build: () => GameCubit(gameService),
        act: (cubit) {
          cubit.makeMove(BoardPosition(0));
          cubit.makeMove(BoardPosition(1));
          cubit.resetGame();
        },
        skip: 2, // Skip the move emissions
        expect: () => [GameState.initial()],
      );
    });

    group('isValidMove', () {
      test('returns true for empty position', () {
        expect(cubit.isValidMove(BoardPosition(0)), isTrue);
      });

      test('returns false for occupied position', () {
        cubit.makeMove(BoardPosition(0));
        expect(cubit.isValidMove(BoardPosition(0)), isFalse);
      });

      test('reflects current state', () {
        expect(cubit.isValidMove(BoardPosition(4)), isTrue);
        cubit.makeMove(BoardPosition(4));
        expect(cubit.isValidMove(BoardPosition(4)), isFalse);
      });
    });
  });
}
