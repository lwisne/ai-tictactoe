import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/domain/models/game_config.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/domain/models/game_result.dart';
import 'package:tictactoe_app/domain/models/player.dart';
import 'package:tictactoe_app/domain/models/position.dart';
import 'package:tictactoe_app/domain/services/game_service.dart';

void main() {
  group('GameService', () {
    late GameService gameService;
    late GameConfig testConfig;

    setUp(() {
      gameService = GameService();
      testConfig = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
    });

    group('createNewGame', () {
      test('should create empty board with all cells as Player.none', () {
        final state = gameService.createNewGame(testConfig);

        expect(state.board.length, equals(3));
        for (final row in state.board) {
          expect(row.length, equals(3));
          for (final cell in row) {
            expect(cell, equals(Player.none));
          }
        }
      });

      test('should set currentPlayer to config.firstPlayer', () {
        final configX = testConfig.copyWith(firstPlayer: Player.x);
        final stateX = gameService.createNewGame(configX);
        expect(stateX.currentPlayer, equals(Player.x));

        final configO = testConfig.copyWith(firstPlayer: Player.o);
        final stateO = gameService.createNewGame(configO);
        expect(stateO.currentPlayer, equals(Player.o));
      });

      test('should set result to GameResult.ongoing', () {
        final state = gameService.createNewGame(testConfig);
        expect(state.result, equals(GameResult.ongoing));
      });

      test('should set startTime to approximately now', () {
        final before = DateTime.now();
        final state = gameService.createNewGame(testConfig);
        final after = DateTime.now();

        expect(
          state.startTime.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(
          state.startTime.isBefore(after.add(const Duration(seconds: 1))),
          isTrue,
        );
      });

      test('should initialize with empty move history', () {
        final state = gameService.createNewGame(testConfig);
        expect(state.moveHistory, isEmpty);
      });

      test('should store the provided config', () {
        final state = gameService.createNewGame(testConfig);
        expect(state.config, equals(testConfig));
      });
    });

    group('isValidMove', () {
      test('should return true for valid move on empty cell', () {
        final state = gameService.createNewGame(testConfig);
        final isValid = gameService.isValidMove(
          state,
          const Position(row: 0, col: 0),
        );

        expect(isValid, isTrue);
      });

      test('should return false when game is finished', () {
        final state = gameService.createNewGame(testConfig);
        final finishedState = state.copyWith(result: GameResult.win);

        final isValid = gameService.isValidMove(
          finishedState,
          const Position(row: 0, col: 0),
        );

        expect(isValid, isFalse);
      });

      test('should return false for position out of bounds (row < 0)', () {
        final state = gameService.createNewGame(testConfig);
        final isValid = gameService.isValidMove(
          state,
          const Position(row: -1, col: 0),
        );

        expect(isValid, isFalse);
      });

      test('should return false for position out of bounds (row > 2)', () {
        final state = gameService.createNewGame(testConfig);
        final isValid = gameService.isValidMove(
          state,
          const Position(row: 3, col: 0),
        );

        expect(isValid, isFalse);
      });

      test('should return false for position out of bounds (col < 0)', () {
        final state = gameService.createNewGame(testConfig);
        final isValid = gameService.isValidMove(
          state,
          const Position(row: 0, col: -1),
        );

        expect(isValid, isFalse);
      });

      test('should return false for position out of bounds (col > 2)', () {
        final state = gameService.createNewGame(testConfig);
        final isValid = gameService.isValidMove(
          state,
          const Position(row: 0, col: 3),
        );

        expect(isValid, isFalse);
      });

      test('should return false for occupied cell', () {
        var state = gameService.createNewGame(testConfig);
        // Make a move to occupy a cell
        state = gameService.makeMove(state, const Position(row: 1, col: 1));

        // Try to move on same cell
        final isValid = gameService.isValidMove(
          state,
          const Position(row: 1, col: 1),
        );

        expect(isValid, isFalse);
      });

      test('should validate all board positions correctly', () {
        final state = gameService.createNewGame(testConfig);

        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            final isValid = gameService.isValidMove(
              state,
              Position(row: row, col: col),
            );
            expect(
              isValid,
              isTrue,
              reason: 'Position ($row,$col) should be valid',
            );
          }
        }
      });
    });

    group('makeMove', () {
      test('should update board with current player mark', () {
        var state = gameService.createNewGame(testConfig);
        state = gameService.makeMove(state, const Position(row: 0, col: 0));

        expect(state.board[0][0], equals(Player.x));
      });

      test('should switch players after valid move', () {
        var state = gameService.createNewGame(testConfig);
        expect(state.currentPlayer, equals(Player.x));

        state = gameService.makeMove(state, const Position(row: 0, col: 0));
        expect(state.currentPlayer, equals(Player.o));

        state = gameService.makeMove(state, const Position(row: 0, col: 1));
        expect(state.currentPlayer, equals(Player.x));
      });

      test('should add move to history', () {
        var state = gameService.createNewGame(testConfig);
        const position = Position(row: 1, col: 1);

        state = gameService.makeMove(state, position);

        expect(state.moveHistory.length, equals(1));
        expect(state.moveHistory[0], equals(position));
      });

      test('should accumulate moves in history', () {
        var state = gameService.createNewGame(testConfig);

        state = gameService.makeMove(state, const Position(row: 0, col: 0));
        state = gameService.makeMove(state, const Position(row: 0, col: 1));
        state = gameService.makeMove(state, const Position(row: 1, col: 0));

        expect(state.moveHistory.length, equals(3));
        expect(state.moveHistory[0], equals(const Position(row: 0, col: 0)));
        expect(state.moveHistory[1], equals(const Position(row: 0, col: 1)));
        expect(state.moveHistory[2], equals(const Position(row: 1, col: 0)));
      });

      test('should return same state for invalid move', () {
        var state = gameService.createNewGame(testConfig);
        state = gameService.makeMove(state, const Position(row: 0, col: 0));

        final previousState = state;
        // Try to move on occupied cell
        state = gameService.makeMove(state, const Position(row: 0, col: 0));

        expect(state, equals(previousState));
      });

      test('should update elapsedTime', () {
        final state = gameService.createNewGame(testConfig);

        final newState = gameService.makeMove(
          state,
          const Position(row: 0, col: 0),
        );

        // Verify elapsedTime is calculated and non-negative
        expect(newState.elapsedTime.inMicroseconds, greaterThanOrEqualTo(0));
        // Verify elapsedTime is reasonable (less than 1 second for this test)
        expect(newState.elapsedTime.inSeconds, lessThan(1));
      });

      test('should not switch players when game ends', () {
        var state = gameService.createNewGame(testConfig);

        // Create a winning scenario for X
        // X | X | _
        // O | O | _
        // _ | _ | _
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 0),
        ); // X
        state = gameService.makeMove(
          state,
          const Position(row: 1, col: 0),
        ); // O
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 1),
        ); // X
        state = gameService.makeMove(
          state,
          const Position(row: 1, col: 1),
        ); // O

        expect(state.currentPlayer, equals(Player.x));

        // X wins
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 2),
        ); // X wins

        expect(state.result, equals(GameResult.win));
        expect(state.currentPlayer, equals(Player.x)); // Should stay X (winner)
      });

      test('should not modify original board (immutability)', () {
        final state = gameService.createNewGame(testConfig);
        final originalBoard = state.board;

        gameService.makeMove(state, const Position(row: 0, col: 0));

        // Original board should remain unchanged
        expect(originalBoard[0][0], equals(Player.none));
      });
    });

    group('isBoardFull', () {
      test('should return false for empty board', () {
        final state = gameService.createNewGame(testConfig);
        expect(gameService.isBoardFull(state.board), isFalse);
      });

      test('should return false for partially filled board', () {
        var state = gameService.createNewGame(testConfig);
        state = gameService.makeMove(state, const Position(row: 0, col: 0));
        state = gameService.makeMove(state, const Position(row: 1, col: 1));

        expect(gameService.isBoardFull(state.board), isFalse);
      });

      test('should return true for completely filled board', () {
        final board = [
          [Player.x, Player.o, Player.x],
          [Player.x, Player.o, Player.o],
          [Player.o, Player.x, Player.x],
        ];

        expect(gameService.isBoardFull(board), isTrue);
      });

      test('should return false when one cell is empty', () {
        final board = [
          [Player.x, Player.o, Player.x],
          [Player.x, Player.o, Player.o],
          [Player.o, Player.x, Player.none],
        ];

        expect(gameService.isBoardFull(board), isFalse);
      });
    });

    group('checkWinner - horizontal', () {
      test('should detect winner in top row', () {
        final board = [
          [Player.x, Player.x, Player.x],
          [Player.o, Player.o, Player.none],
          [Player.none, Player.none, Player.none],
        ];

        final result = gameService.checkWinner(board);

        expect(result, isNotNull);
        expect(result!.winner, equals(Player.x));
        expect(result.line.length, equals(3));
        expect(result.line[0], equals(const Position(row: 0, col: 0)));
        expect(result.line[1], equals(const Position(row: 0, col: 1)));
        expect(result.line[2], equals(const Position(row: 0, col: 2)));
      });

      test('should detect winner in middle row', () {
        final board = [
          [Player.x, Player.o, Player.none],
          [Player.o, Player.o, Player.o],
          [Player.x, Player.none, Player.none],
        ];

        final result = gameService.checkWinner(board);

        expect(result, isNotNull);
        expect(result!.winner, equals(Player.o));
        expect(result.line[0], equals(const Position(row: 1, col: 0)));
      });

      test('should detect winner in bottom row', () {
        final board = [
          [Player.o, Player.x, Player.none],
          [Player.o, Player.x, Player.none],
          [Player.x, Player.x, Player.x],
        ];

        final result = gameService.checkWinner(board);

        expect(result, isNotNull);
        expect(result!.winner, equals(Player.x));
        expect(result.line[0], equals(const Position(row: 2, col: 0)));
      });
    });

    group('checkWinner - vertical', () {
      test('should detect winner in left column', () {
        final board = [
          [Player.x, Player.o, Player.none],
          [Player.x, Player.o, Player.none],
          [Player.x, Player.none, Player.none],
        ];

        final result = gameService.checkWinner(board);

        expect(result, isNotNull);
        expect(result!.winner, equals(Player.x));
        expect(result.line[0], equals(const Position(row: 0, col: 0)));
        expect(result.line[1], equals(const Position(row: 1, col: 0)));
        expect(result.line[2], equals(const Position(row: 2, col: 0)));
      });

      test('should detect winner in middle column', () {
        final board = [
          [Player.x, Player.o, Player.none],
          [Player.none, Player.o, Player.x],
          [Player.x, Player.o, Player.none],
        ];

        final result = gameService.checkWinner(board);

        expect(result, isNotNull);
        expect(result!.winner, equals(Player.o));
        expect(result.line[0], equals(const Position(row: 0, col: 1)));
      });

      test('should detect winner in right column', () {
        final board = [
          [Player.o, Player.none, Player.x],
          [Player.o, Player.none, Player.x],
          [Player.none, Player.none, Player.x],
        ];

        final result = gameService.checkWinner(board);

        expect(result, isNotNull);
        expect(result!.winner, equals(Player.x));
        expect(result.line[0], equals(const Position(row: 0, col: 2)));
      });
    });

    group('checkWinner - diagonal', () {
      test('should detect winner in top-left to bottom-right diagonal', () {
        final board = [
          [Player.x, Player.o, Player.none],
          [Player.o, Player.x, Player.none],
          [Player.none, Player.o, Player.x],
        ];

        final result = gameService.checkWinner(board);

        expect(result, isNotNull);
        expect(result!.winner, equals(Player.x));
        expect(result.line.length, equals(3));
        expect(result.line[0], equals(const Position(row: 0, col: 0)));
        expect(result.line[1], equals(const Position(row: 1, col: 1)));
        expect(result.line[2], equals(const Position(row: 2, col: 2)));
      });

      test('should detect winner in top-right to bottom-left diagonal', () {
        final board = [
          [Player.x, Player.o, Player.o],
          [Player.x, Player.o, Player.none],
          [Player.o, Player.none, Player.x],
        ];

        final result = gameService.checkWinner(board);

        expect(result, isNotNull);
        expect(result!.winner, equals(Player.o));
        expect(result.line.length, equals(3));
        expect(result.line[0], equals(const Position(row: 0, col: 2)));
        expect(result.line[1], equals(const Position(row: 1, col: 1)));
        expect(result.line[2], equals(const Position(row: 2, col: 0)));
      });
    });

    group('checkWinner - no winner', () {
      test('should return null for empty board', () {
        final state = gameService.createNewGame(testConfig);
        final result = gameService.checkWinner(state.board);

        expect(result, isNull);
      });

      test('should return null for board with no winning lines', () {
        final board = [
          [Player.x, Player.o, Player.x],
          [Player.x, Player.o, Player.o],
          [Player.o, Player.x, Player.none],
        ];

        final result = gameService.checkWinner(board);

        expect(result, isNull);
      });
    });

    group('makeMove - game completion', () {
      test('should set result to win when player wins', () {
        var state = gameService.createNewGame(testConfig);

        // Create winning scenario: X gets top row
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 0),
        ); // X
        state = gameService.makeMove(
          state,
          const Position(row: 1, col: 0),
        ); // O
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 1),
        ); // X
        state = gameService.makeMove(
          state,
          const Position(row: 1, col: 1),
        ); // O
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 2),
        ); // X wins

        expect(state.result, equals(GameResult.win));
        expect(state.winner, equals(Player.x));
        expect(state.winningLine, isNotNull);
        expect(state.winningLine!.length, equals(3));
      });

      test('should set result to draw when board fills with no winner', () {
        var state = gameService.createNewGame(testConfig);

        // Create draw scenario
        // X | X | O
        // O | O | X
        // X | O | X
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 0),
        ); // X
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 2),
        ); // O
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 1),
        ); // X
        state = gameService.makeMove(
          state,
          const Position(row: 1, col: 0),
        ); // O
        state = gameService.makeMove(
          state,
          const Position(row: 1, col: 2),
        ); // X
        state = gameService.makeMove(
          state,
          const Position(row: 1, col: 1),
        ); // O
        state = gameService.makeMove(
          state,
          const Position(row: 2, col: 0),
        ); // X
        state = gameService.makeMove(
          state,
          const Position(row: 2, col: 1),
        ); // O

        // At this point:
        // X | X | O
        // O | O | X
        // X | O | _
        // Last move is X
        state = gameService.makeMove(
          state,
          const Position(row: 2, col: 2),
        ); // X

        // Final board:
        // X | X | O
        // O | O | X
        // X | O | X

        expect(state.result, equals(GameResult.draw));
        expect(state.winner, isNull);
        expect(state.winningLine, isNull);
      });
    });

    group('getAvailableMoves', () {
      test('should return all positions for empty board', () {
        final state = gameService.createNewGame(testConfig);
        final availableMoves = gameService.getAvailableMoves(state.board);

        expect(availableMoves.length, equals(9));
      });

      test('should return empty list for full board', () {
        final board = [
          [Player.x, Player.o, Player.x],
          [Player.o, Player.x, Player.o],
          [Player.o, Player.x, Player.o],
        ];

        final availableMoves = gameService.getAvailableMoves(board);

        expect(availableMoves, isEmpty);
      });

      test('should return only empty positions', () {
        var state = gameService.createNewGame(testConfig);
        state = gameService.makeMove(state, const Position(row: 0, col: 0));
        state = gameService.makeMove(state, const Position(row: 1, col: 1));

        final availableMoves = gameService.getAvailableMoves(state.board);

        expect(availableMoves.length, equals(7));
        expect(
          availableMoves.any((pos) => pos.row == 0 && pos.col == 0),
          isFalse,
        );
        expect(
          availableMoves.any((pos) => pos.row == 1 && pos.col == 1),
          isFalse,
        );
      });
    });

    group('undoLastMove', () {
      test('should return null when no moves to undo', () {
        final state = gameService.createNewGame(testConfig);
        final previousState = gameService.undoLastMove(state);

        expect(previousState, isNull);
      });

      test('should revert to initial state after one move', () {
        var state = gameService.createNewGame(testConfig);
        state = gameService.makeMove(state, const Position(row: 1, col: 1));

        final undoneState = gameService.undoLastMove(state);

        expect(undoneState, isNotNull);
        expect(undoneState!.board[1][1], equals(Player.none));
        expect(undoneState.moveHistory, isEmpty);
        expect(undoneState.currentPlayer, equals(Player.x));
      });

      test('should revert to previous state after multiple moves', () {
        var state = gameService.createNewGame(testConfig);
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 0),
        ); // X
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 1),
        ); // O
        state = gameService.makeMove(
          state,
          const Position(row: 1, col: 0),
        ); // X

        final undoneState = gameService.undoLastMove(state);

        expect(undoneState, isNotNull);
        expect(undoneState!.board[0][0], equals(Player.x));
        expect(undoneState.board[0][1], equals(Player.o));
        expect(undoneState.board[1][0], equals(Player.none)); // Undone
        expect(undoneState.moveHistory.length, equals(2));
        expect(undoneState.currentPlayer, equals(Player.x)); // X's turn again
      });

      test('should handle multiple undos correctly', () {
        var state = gameService.createNewGame(testConfig);
        state = gameService.makeMove(
          state,
          const Position(row: 0, col: 0),
        ); // X
        state = gameService.makeMove(
          state,
          const Position(row: 1, col: 1),
        ); // O

        // Undo once
        state = gameService.undoLastMove(state)!;
        expect(state.board[1][1], equals(Player.none));
        expect(state.moveHistory.length, equals(1));

        // Undo again
        state = gameService.undoLastMove(state)!;
        expect(state.board[0][0], equals(Player.none));
        expect(state.moveHistory.length, equals(0));

        // Can't undo anymore
        final finalUndo = gameService.undoLastMove(state);
        expect(finalUndo, isNull);
      });
    });

    group('resetGame', () {
      test('should create new game with same config', () {
        var state = gameService.createNewGame(testConfig);
        state = gameService.makeMove(state, const Position(row: 0, col: 0));
        state = gameService.makeMove(state, const Position(row: 1, col: 1));

        final resetState = gameService.resetGame(state);

        expect(resetState.config, equals(state.config));
        expect(resetState.board[0][0], equals(Player.none));
        expect(resetState.board[1][1], equals(Player.none));
        expect(resetState.moveHistory, isEmpty);
        expect(resetState.currentPlayer, equals(testConfig.firstPlayer));
        expect(resetState.result, equals(GameResult.ongoing));
      });

      test('should create new start time', () {
        final state = gameService.createNewGame(testConfig);
        final originalStartTime = state.startTime;

        final resetState = gameService.resetGame(state);

        // Verify new start time is set (should be >= original since reset happens after creation)
        expect(
          resetState.startTime.isAtSameMomentAs(originalStartTime) ||
              resetState.startTime.isAfter(originalStartTime),
          isTrue,
        );
      });
    });
  });
}
