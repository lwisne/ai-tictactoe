import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/board_position.dart';
import 'package:tic_tac_toe/models/game_state.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/services/game_service.dart';

void main() {
  group('GameService', () {
    late GameService service;

    setUp(() {
      service = GameService();
    });

    group('isValidMove', () {
      test('returns true for empty position on fresh board', () {
        final state = GameState.initial();
        expect(service.isValidMove(state, BoardPosition(0)), isTrue);
      });

      test('returns false for occupied position', () {
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;
        final state = GameState(board: board, currentPlayer: Player.o);

        expect(service.isValidMove(state, BoardPosition(0)), isFalse);
      });

      test('returns false when game is over', () {
        final state = GameState.initial().copyWith(isGameOver: true);
        expect(service.isValidMove(state, BoardPosition(0)), isFalse);
      });

      test('returns true for all empty positions', () {
        final state = GameState.initial();
        for (int i = 0; i < 9; i++) {
          expect(
            service.isValidMove(state, BoardPosition(i)),
            isTrue,
            reason: 'Position $i should be valid',
          );
        }
      });
    });

    group('makeMove', () {
      test('places X on empty board at position 0', () {
        final state = GameState.initial();
        final newState = service.makeMove(state, BoardPosition(0));

        expect(newState.board[0], Player.x);
        expect(newState.currentPlayer, Player.o);
      });

      test('switches current player after move', () {
        final state = GameState.initial();
        final newState = service.makeMove(state, BoardPosition(0));

        expect(newState.currentPlayer, Player.o);
      });

      test('preserves previous moves', () {
        var state = GameState.initial();
        state = service.makeMove(state, BoardPosition(0)); // X
        state = service.makeMove(state, BoardPosition(1)); // O

        expect(state.board[0], Player.x);
        expect(state.board[1], Player.o);
        expect(state.currentPlayer, Player.x);
      });

      test('throws ArgumentError for invalid move on occupied position', () {
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;
        final state = GameState(board: board, currentPlayer: Player.o);

        expect(
          () => service.makeMove(state, BoardPosition(0)),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError when game is over', () {
        final state = GameState.initial().copyWith(isGameOver: true);

        expect(
          () => service.makeMove(state, BoardPosition(0)),
          throwsArgumentError,
        );
      });

      test('does not modify original state', () {
        final original = GameState.initial();
        final _ = service.makeMove(original, BoardPosition(0));

        expect(original.board[0], isNull);
        expect(original.currentPlayer, Player.x);
      });
    });

    group('resetGame', () {
      test('returns initial state', () {
        final state = service.resetGame();

        expect(state.board.every((cell) => cell == null), isTrue);
        expect(state.currentPlayer, Player.x);
        expect(state.isGameOver, isFalse);
      });
    });

    group('getEmptyPositions', () {
      test('returns all positions for empty board', () {
        final state = GameState.initial();
        final emptyPositions = service.getEmptyPositions(state);

        expect(emptyPositions.length, 9);
        for (int i = 0; i < 9; i++) {
          expect(
            emptyPositions.any((pos) => pos.index == i),
            isTrue,
            reason: 'Position $i should be in empty positions',
          );
        }
      });

      test('returns empty list for full board', () {
        final board = [
          Player.x, Player.o, Player.x,
          Player.o, Player.x, Player.o,
          Player.x, Player.o, Player.x,
        ];
        final state = GameState(board: board, currentPlayer: Player.o);

        final emptyPositions = service.getEmptyPositions(state);
        expect(emptyPositions, isEmpty);
      });

      test('returns correct positions for partially filled board', () {
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;
        board[4] = Player.o;
        board[8] = Player.x;

        final state = GameState(board: board, currentPlayer: Player.o);
        final emptyPositions = service.getEmptyPositions(state);

        expect(emptyPositions.length, 6);
        expect(emptyPositions.any((pos) => pos.index == 0), isFalse);
        expect(emptyPositions.any((pos) => pos.index == 4), isFalse);
        expect(emptyPositions.any((pos) => pos.index == 8), isFalse);
        expect(emptyPositions.any((pos) => pos.index == 1), isTrue);
      });
    });

    group('isBoardFull', () {
      test('returns false for empty board', () {
        final state = GameState.initial();
        expect(service.isBoardFull(state), isFalse);
      });

      test('returns true for full board', () {
        final board = [
          Player.x, Player.o, Player.x,
          Player.o, Player.x, Player.o,
          Player.x, Player.o, Player.x,
        ];
        final state = GameState(board: board, currentPlayer: Player.o);

        expect(service.isBoardFull(state), isTrue);
      });

      test('returns false for partially filled board', () {
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;

        final state = GameState(board: board, currentPlayer: Player.o);
        expect(service.isBoardFull(state), isFalse);
      });
    });

    group('checkWinner', () {
      test('returns null for empty board', () {
        final board = List<Player?>.filled(9, null);
        expect(service.checkWinner(board), isNull);
      });

      test('detects X win in row 0', () {
        final board = [
          Player.x, Player.x, Player.x,
          null, null, null,
          null, null, null,
        ];
        expect(service.checkWinner(board), Player.x);
      });

      test('detects O win in row 1', () {
        final board = [
          null, null, null,
          Player.o, Player.o, Player.o,
          null, null, null,
        ];
        expect(service.checkWinner(board), Player.o);
      });

      test('detects X win in row 2', () {
        final board = [
          null, null, null,
          null, null, null,
          Player.x, Player.x, Player.x,
        ];
        expect(service.checkWinner(board), Player.x);
      });

      test('detects O win in column 0', () {
        final board = [
          Player.o, null, null,
          Player.o, null, null,
          Player.o, null, null,
        ];
        expect(service.checkWinner(board), Player.o);
      });

      test('detects X win in column 1', () {
        final board = [
          null, Player.x, null,
          null, Player.x, null,
          null, Player.x, null,
        ];
        expect(service.checkWinner(board), Player.x);
      });

      test('detects O win in column 2', () {
        final board = [
          null, null, Player.o,
          null, null, Player.o,
          null, null, Player.o,
        ];
        expect(service.checkWinner(board), Player.o);
      });

      test('detects X win in diagonal top-left to bottom-right', () {
        final board = [
          Player.x, null, null,
          null, Player.x, null,
          null, null, Player.x,
        ];
        expect(service.checkWinner(board), Player.x);
      });

      test('detects O win in diagonal top-right to bottom-left', () {
        final board = [
          null, null, Player.o,
          null, Player.o, null,
          Player.o, null, null,
        ];
        expect(service.checkWinner(board), Player.o);
      });

      test('returns null for no winner', () {
        final board = [
          Player.x, Player.o, Player.x,
          Player.o, Player.x, Player.o,
          Player.o, Player.x, Player.o,
        ];
        expect(service.checkWinner(board), isNull);
      });
    });

    group('getWinner', () {
      test('returns winner from state', () {
        final board = [
          Player.x, Player.x, Player.x,
          null, null, null,
          null, null, null,
        ];
        final state = GameState(board: board, currentPlayer: Player.o);

        expect(service.getWinner(state), Player.x);
      });

      test('returns null when no winner', () {
        final state = GameState.initial();
        expect(service.getWinner(state), isNull);
      });
    });

    group('isDraw', () {
      test('returns true for full board with no winner', () {
        final board = [
          Player.x, Player.o, Player.x,
          Player.o, Player.x, Player.o,
          Player.o, Player.x, Player.o,
        ];
        final state = GameState(
          board: board,
          currentPlayer: Player.x,
          isGameOver: true,
        );

        expect(service.isDraw(state), isTrue);
      });

      test('returns false when there is a winner', () {
        final board = [
          Player.x, Player.x, Player.x,
          Player.o, Player.o, null,
          null, null, null,
        ];
        final state = GameState(
          board: board,
          currentPlayer: Player.o,
          isGameOver: true,
        );

        expect(service.isDraw(state), isFalse);
      });

      test('returns false when game is not over', () {
        final state = GameState.initial();
        expect(service.isDraw(state), isFalse);
      });
    });

    group('makeMove with win/draw detection', () {
      test('detects win and sets isGameOver', () {
        var state = GameState.initial();
        // X plays: 0, 1
        state = service.makeMove(state, BoardPosition(0)); // X
        state = service.makeMove(state, BoardPosition(3)); // O
        state = service.makeMove(state, BoardPosition(1)); // X
        state = service.makeMove(state, BoardPosition(4)); // O

        // X wins with position 2
        state = service.makeMove(state, BoardPosition(2)); // X

        expect(state.isGameOver, isTrue);
        expect(service.getWinner(state), Player.x);
      });

      test('detects draw and sets isGameOver', () {
        var state = GameState.initial();
        // Play out a draw game:
        // X O X
        // O X O
        // O X X
        state = service.makeMove(state, BoardPosition(4)); // X center
        state = service.makeMove(state, BoardPosition(0)); // O
        state = service.makeMove(state, BoardPosition(8)); // X
        state = service.makeMove(state, BoardPosition(6)); // O (block diagonal)
        state = service.makeMove(state, BoardPosition(2)); // X (other diagonal blocked by O at 0)
        state = service.makeMove(state, BoardPosition(1)); // O (block top row)
        state = service.makeMove(state, BoardPosition(7)); // X
        state = service.makeMove(state, BoardPosition(5)); // O (block right col)
        state = service.makeMove(state, BoardPosition(3)); // X (block left col)

        expect(state.isGameOver, isTrue);
        expect(service.getWinner(state), isNull);
        expect(service.isDraw(state), isTrue);
      });

      test('cannot make moves after game is over', () {
        var state = GameState.initial();
        // X wins
        state = service.makeMove(state, BoardPosition(0));
        state = service.makeMove(state, BoardPosition(3));
        state = service.makeMove(state, BoardPosition(1));
        state = service.makeMove(state, BoardPosition(4));
        state = service.makeMove(state, BoardPosition(2)); // X wins

        expect(state.isGameOver, isTrue);

        // Try to make another move
        expect(
          () => service.makeMove(state, BoardPosition(5)),
          throwsArgumentError,
        );
      });
    });
  });
}
