import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/game_config.dart';
import 'package:tic_tac_toe/domain/entities/game_mode.dart';
import 'package:tic_tac_toe/domain/entities/game_result.dart';
import 'package:tic_tac_toe/domain/entities/player.dart';
import 'package:tic_tac_toe/domain/entities/position.dart';
import 'package:tic_tac_toe/domain/services/game_service.dart';

void main() {
  late GameService gameService;

  setUp(() {
    gameService = GameService();
  });

  group('GameService - createNewGame', () {
    test('initializes game with empty board', () {
      final config = const GameConfig(
        gameMode: GameMode.singlePlayer,
        firstPlayer: Player.x,
      );
      final state = gameService.createNewGame(config);

      expect(state.board.length, equals(3));
      expect(state.board[0].length, equals(3));
      expect(state.board.every((row) => row.every((cell) => cell == Player.none)), isTrue);
    });

    test('sets correct first player', () {
      final config = const GameConfig(
        gameMode: GameMode.singlePlayer,
        firstPlayer: Player.o,
      );
      final state = gameService.createNewGame(config);

      expect(state.currentPlayer, equals(Player.o));
    });

    test('initializes with ongoing result', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      final state = gameService.createNewGame(config);

      expect(state.result, equals(GameResult.ongoing));
      expect(state.winner, isNull);
      expect(state.winningLine, isNull);
    });
  });

  group('GameService - isValidMove', () {
    test('allows move on empty cell', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      final state = gameService.createNewGame(config);
      final position = const Position(row: 1, col: 1);

      expect(gameService.isValidMove(state, position), isTrue);
    });

    test('rejects move on occupied cell', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      var state = gameService.createNewGame(config);
      final position = const Position(row: 1, col: 1);

      state = gameService.makeMove(state, position);

      expect(gameService.isValidMove(state, position), isFalse);
    });

    test('rejects move out of bounds', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      final state = gameService.createNewGame(config);

      expect(gameService.isValidMove(state, const Position(row: -1, col: 0)), isFalse);
      expect(gameService.isValidMove(state, const Position(row: 0, col: -1)), isFalse);
      expect(gameService.isValidMove(state, const Position(row: 3, col: 0)), isFalse);
      expect(gameService.isValidMove(state, const Position(row: 0, col: 3)), isFalse);
    });

    test('rejects move when game is finished', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      var state = gameService.createNewGame(config);

      // Create winning scenario for X
      state = gameService.makeMove(state, const Position(row: 0, col: 0)); // X
      state = gameService.makeMove(state, const Position(row: 1, col: 0)); // O
      state = gameService.makeMove(state, const Position(row: 0, col: 1)); // X
      state = gameService.makeMove(state, const Position(row: 1, col: 1)); // O
      state = gameService.makeMove(state, const Position(row: 0, col: 2)); // X wins

      expect(state.result, equals(GameResult.win));
      expect(gameService.isValidMove(state, const Position(row: 2, col: 2)), isFalse);
    });
  });

  group('GameService - makeMove', () {
    test('places symbol on board', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      var state = gameService.createNewGame(config);
      final position = const Position(row: 1, col: 1);

      state = gameService.makeMove(state, position);

      expect(state.board[1][1], equals(Player.x));
    });

    test('switches current player', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      var state = gameService.createNewGame(config);

      expect(state.currentPlayer, equals(Player.x));

      state = gameService.makeMove(state, const Position(row: 0, col: 0));
      expect(state.currentPlayer, equals(Player.o));

      state = gameService.makeMove(state, const Position(row: 1, col: 1));
      expect(state.currentPlayer, equals(Player.x));
    });

    test('adds move to history', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      var state = gameService.createNewGame(config);
      final position = const Position(row: 1, col: 1);

      expect(state.moveHistory.length, equals(0));

      state = gameService.makeMove(state, position);
      expect(state.moveHistory.length, equals(1));
      expect(state.moveHistory[0], equals(position));
    });

    test('returns same state for invalid move', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      var state = gameService.createNewGame(config);
      state = gameService.makeMove(state, const Position(row: 0, col: 0));

      final beforeInvalid = state;
      state = gameService.makeMove(state, const Position(row: 0, col: 0)); // Same position

      expect(state, equals(beforeInvalid));
    });
  });

  group('GameService - checkWinner', () {
    test('detects horizontal win - row 0', () {
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

    test('detects vertical win - col 1', () {
      final board = [
        [Player.x, Player.o, Player.none],
        [Player.x, Player.o, Player.none],
        [Player.none, Player.o, Player.none],
      ];

      final result = gameService.checkWinner(board);

      expect(result, isNotNull);
      expect(result!.winner, equals(Player.o));
      expect(result.line[0], equals(const Position(row: 0, col: 1)));
      expect(result.line[1], equals(const Position(row: 1, col: 1)));
      expect(result.line[2], equals(const Position(row: 2, col: 1)));
    });

    test('detects diagonal win - top-left to bottom-right', () {
      final board = [
        [Player.x, Player.o, Player.none],
        [Player.o, Player.x, Player.none],
        [Player.none, Player.o, Player.x],
      ];

      final result = gameService.checkWinner(board);

      expect(result, isNotNull);
      expect(result!.winner, equals(Player.x));
      expect(result.line[0], equals(const Position(row: 0, col: 0)));
      expect(result.line[1], equals(const Position(row: 1, col: 1)));
      expect(result.line[2], equals(const Position(row: 2, col: 2)));
    });

    test('detects diagonal win - top-right to bottom-left', () {
      final board = [
        [Player.none, Player.x, Player.o],
        [Player.x, Player.o, Player.none],
        [Player.o, Player.none, Player.x],
      ];

      final result = gameService.checkWinner(board);

      expect(result, isNotNull);
      expect(result!.winner, equals(Player.o));
      expect(result.line[0], equals(const Position(row: 0, col: 2)));
      expect(result.line[1], equals(const Position(row: 1, col: 1)));
      expect(result.line[2], equals(const Position(row: 2, col: 0)));
    });

    test('returns null when no winner', () {
      final board = [
        [Player.x, Player.o, Player.none],
        [Player.o, Player.x, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final result = gameService.checkWinner(board);

      expect(result, isNull);
    });
  });

  group('GameService - isBoardFull', () {
    test('returns false for empty board', () {
      final board = [
        [Player.none, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      expect(gameService.isBoardFull(board), isFalse);
    });

    test('returns false for partially filled board', () {
      final board = [
        [Player.x, Player.o, Player.x],
        [Player.o, Player.x, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      expect(gameService.isBoardFull(board), isFalse);
    });

    test('returns true for completely filled board', () {
      final board = [
        [Player.x, Player.o, Player.x],
        [Player.o, Player.x, Player.o],
        [Player.o, Player.x, Player.o],
      ];

      expect(gameService.isBoardFull(board), isTrue);
    });
  });

  group('GameService - getAvailableMoves', () {
    test('returns all positions for empty board', () {
      final board = [
        [Player.none, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final moves = gameService.getAvailableMoves(board);

      expect(moves.length, equals(9));
    });

    test('returns only empty positions', () {
      final board = [
        [Player.x, Player.o, Player.none],
        [Player.none, Player.x, Player.none],
        [Player.none, Player.none, Player.o],
      ];

      final moves = gameService.getAvailableMoves(board);

      expect(moves.length, equals(5));
      expect(moves.contains(const Position(row: 0, col: 2)), isTrue);
      expect(moves.contains(const Position(row: 1, col: 0)), isTrue);
      expect(moves.contains(const Position(row: 1, col: 2)), isTrue);
      expect(moves.contains(const Position(row: 2, col: 0)), isTrue);
      expect(moves.contains(const Position(row: 2, col: 1)), isTrue);
    });

    test('returns empty list for full board', () {
      final board = [
        [Player.x, Player.o, Player.x],
        [Player.o, Player.x, Player.o],
        [Player.o, Player.x, Player.o],
      ];

      final moves = gameService.getAvailableMoves(board);

      expect(moves, isEmpty);
    });
  });

  group('GameService - undoLastMove', () {
    test('removes last move from history', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      var state = gameService.createNewGame(config);

      state = gameService.makeMove(state, const Position(row: 0, col: 0));
      state = gameService.makeMove(state, const Position(row: 1, col: 1));

      expect(state.moveHistory.length, equals(2));

      state = gameService.undoLastMove(state)!;
      expect(state.moveHistory.length, equals(1));
    });

    test('restores board to previous state', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      var state = gameService.createNewGame(config);

      state = gameService.makeMove(state, const Position(row: 0, col: 0));
      state = gameService.makeMove(state, const Position(row: 1, col: 1));

      expect(state.board[1][1], equals(Player.o));

      state = gameService.undoLastMove(state)!;
      expect(state.board[1][1], equals(Player.none));
      expect(state.board[0][0], equals(Player.x));
    });

    test('returns null when no moves to undo', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      final state = gameService.createNewGame(config);

      final result = gameService.undoLastMove(state);

      expect(result, isNull);
    });
  });

  group('GameService - resetGame', () {
    test('creates new game with same config', () {
      final config = const GameConfig(
        gameMode: GameMode.singlePlayer,
        firstPlayer: Player.x,
      );
      var state = gameService.createNewGame(config);

      state = gameService.makeMove(state, const Position(row: 0, col: 0));
      state = gameService.makeMove(state, const Position(row: 1, col: 1));

      state = gameService.resetGame(state);

      expect(state.board.every((row) => row.every((cell) => cell == Player.none)), isTrue);
      expect(state.moveHistory, isEmpty);
      expect(state.currentPlayer, equals(Player.x));
      expect(state.config, equals(config));
    });
  });

  group('GameService - Full Game Scenarios', () {
    test('X wins horizontally', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      var state = gameService.createNewGame(config);

      state = gameService.makeMove(state, const Position(row: 0, col: 0)); // X
      state = gameService.makeMove(state, const Position(row: 1, col: 0)); // O
      state = gameService.makeMove(state, const Position(row: 0, col: 1)); // X
      state = gameService.makeMove(state, const Position(row: 1, col: 1)); // O
      state = gameService.makeMove(state, const Position(row: 0, col: 2)); // X wins

      expect(state.result, equals(GameResult.win));
      expect(state.winner, equals(Player.x));
      expect(state.winningLine, isNotNull);
      expect(state.winningLine!.length, equals(3));
    });

    test('Draw game', () {
      final config = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      var state = gameService.createNewGame(config);

      // Create a draw scenario
      state = gameService.makeMove(state, const Position(row: 0, col: 0)); // X
      state = gameService.makeMove(state, const Position(row: 0, col: 1)); // O
      state = gameService.makeMove(state, const Position(row: 0, col: 2)); // X
      state = gameService.makeMove(state, const Position(row: 1, col: 0)); // O
      state = gameService.makeMove(state, const Position(row: 1, col: 1)); // X
      state = gameService.makeMove(state, const Position(row: 2, col: 0)); // O
      state = gameService.makeMove(state, const Position(row: 1, col: 2)); // X
      state = gameService.makeMove(state, const Position(row: 2, col: 2)); // O
      state = gameService.makeMove(state, const Position(row: 2, col: 1)); // X

      expect(state.result, equals(GameResult.draw));
      expect(state.winner, isNull);
    });
  });
}
