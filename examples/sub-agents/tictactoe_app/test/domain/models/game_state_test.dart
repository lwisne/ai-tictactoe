import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/domain/models/game_config.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/domain/models/game_result.dart';
import 'package:tictactoe_app/domain/models/game_state.dart';
import 'package:tictactoe_app/domain/models/player.dart';
import 'package:tictactoe_app/domain/models/position.dart';

void main() {
  group('GameState', () {
    late GameConfig testConfig;
    late DateTime testStartTime;
    late List<List<Player>> emptyBoard;

    setUp(() {
      testConfig = const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      testStartTime = DateTime.now();
      emptyBoard = List.generate(
        3,
        (_) => List.generate(3, (_) => Player.none),
      );
    });

    test('should create state with all required fields', () {
      final state = GameState(
        board: emptyBoard,
        currentPlayer: Player.x,
        config: testConfig,
        startTime: testStartTime,
      );

      expect(state.board, equals(emptyBoard));
      expect(state.currentPlayer, equals(Player.x));
      expect(state.result, equals(GameResult.ongoing));
      expect(state.winner, isNull);
      expect(state.winningLine, isNull);
      expect(state.moveHistory, isEmpty);
      expect(state.config, equals(testConfig));
      expect(state.startTime, equals(testStartTime));
      expect(state.elapsedTime, equals(Duration.zero));
    });

    test('should create state with optional fields', () {
      final winningLine = [
        const Position(row: 0, col: 0),
        const Position(row: 0, col: 1),
        const Position(row: 0, col: 2),
      ];
      final moveHistory = [
        const Position(row: 0, col: 0),
        const Position(row: 1, col: 0),
      ];

      final state = GameState(
        board: emptyBoard,
        currentPlayer: Player.x,
        result: GameResult.win,
        winner: Player.x,
        winningLine: winningLine,
        moveHistory: moveHistory,
        config: testConfig,
        startTime: testStartTime,
        elapsedTime: const Duration(minutes: 2),
      );

      expect(state.result, equals(GameResult.win));
      expect(state.winner, equals(Player.x));
      expect(state.winningLine, equals(winningLine));
      expect(state.moveHistory, equals(moveHistory));
      expect(state.elapsedTime, equals(const Duration(minutes: 2)));
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        final state1 = GameState(
          board: emptyBoard,
          currentPlayer: Player.x,
          config: testConfig,
          startTime: testStartTime,
        );
        final state2 = GameState(
          board: emptyBoard,
          currentPlayer: Player.x,
          config: testConfig,
          startTime: testStartTime,
        );

        expect(state1, equals(state2));
      });

      test('should not be equal when board differs', () {
        final board2 = List.generate(
          3,
          (_) => List.generate(3, (_) => Player.none),
        );
        board2[0][0] = Player.x;

        final state1 = GameState(
          board: emptyBoard,
          currentPlayer: Player.x,
          config: testConfig,
          startTime: testStartTime,
        );
        final state2 = GameState(
          board: board2,
          currentPlayer: Player.x,
          config: testConfig,
          startTime: testStartTime,
        );

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when currentPlayer differs', () {
        final state1 = GameState(
          board: emptyBoard,
          currentPlayer: Player.x,
          config: testConfig,
          startTime: testStartTime,
        );
        final state2 = GameState(
          board: emptyBoard,
          currentPlayer: Player.o,
          config: testConfig,
          startTime: testStartTime,
        );

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when result differs', () {
        final state1 = GameState(
          board: emptyBoard,
          currentPlayer: Player.x,
          result: GameResult.ongoing,
          config: testConfig,
          startTime: testStartTime,
        );
        final state2 = GameState(
          board: emptyBoard,
          currentPlayer: Player.x,
          result: GameResult.win,
          config: testConfig,
          startTime: testStartTime,
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    group('copyWith', () {
      late GameState original;

      setUp(() {
        original = GameState(
          board: emptyBoard,
          currentPlayer: Player.x,
          result: GameResult.ongoing,
          config: testConfig,
          startTime: testStartTime,
        );
      });

      test('should create copy with updated currentPlayer', () {
        final updated = original.copyWith(currentPlayer: Player.o);

        expect(updated.currentPlayer, equals(Player.o));
        expect(updated.board, equals(original.board));
        expect(updated.result, equals(original.result));
        expect(updated.config, equals(original.config));
      });

      test('should create copy with updated result', () {
        final updated = original.copyWith(result: GameResult.win);

        expect(updated.result, equals(GameResult.win));
        expect(updated.currentPlayer, equals(original.currentPlayer));
      });

      test('should create copy with updated winner and winningLine', () {
        final winningLine = [
          const Position(row: 0, col: 0),
          const Position(row: 1, col: 1),
          const Position(row: 2, col: 2),
        ];

        final updated = original.copyWith(
          winner: Player.x,
          winningLine: winningLine,
        );

        expect(updated.winner, equals(Player.x));
        expect(updated.winningLine, equals(winningLine));
      });

      test('should create copy with updated board', () {
        final newBoard = List.generate(
          3,
          (_) => List.generate(3, (_) => Player.none),
        );
        newBoard[1][1] = Player.x;

        final updated = original.copyWith(board: newBoard);

        expect(updated.board, equals(newBoard));
        expect(updated.board[1][1], equals(Player.x));
      });

      test('should create copy with updated moveHistory', () {
        final moveHistory = [
          const Position(row: 0, col: 0),
          const Position(row: 1, col: 1),
        ];

        final updated = original.copyWith(moveHistory: moveHistory);

        expect(updated.moveHistory, equals(moveHistory));
        expect(updated.moveHistory.length, equals(2));
      });

      test('should create copy with updated elapsedTime', () {
        final updated = original.copyWith(
          elapsedTime: const Duration(seconds: 30),
        );

        expect(updated.elapsedTime, equals(const Duration(seconds: 30)));
      });

      test('should create copy with multiple updated fields', () {
        final newBoard = List.generate(
          3,
          (_) => List.generate(3, (_) => Player.none),
        );
        newBoard[0][0] = Player.x;

        final updated = original.copyWith(
          board: newBoard,
          currentPlayer: Player.o,
          result: GameResult.ongoing,
          moveHistory: [const Position(row: 0, col: 0)],
        );

        expect(updated.board, equals(newBoard));
        expect(updated.currentPlayer, equals(Player.o));
        expect(updated.result, equals(GameResult.ongoing));
        expect(updated.moveHistory.length, equals(1));
      });

      test('should return same values when no fields updated', () {
        final updated = original.copyWith();

        expect(updated, equals(original));
      });
    });

    group('JSON serialization', () {
      test('should serialize minimal state to JSON correctly', () {
        final state = GameState(
          board: emptyBoard,
          currentPlayer: Player.x,
          config: testConfig,
          startTime: testStartTime,
        );

        final json = state.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['board'], isA<List>());
        expect(json['currentPlayer'], equals('x'));
        expect(json['result'], equals('ongoing'));
        expect(json['winner'], isNull);
        expect(json['winningLine'], isNull);
        expect(json['moveHistory'], isA<List>());
        expect(json['config'], isA<Map>());
        expect(json['startTime'], isA<String>());
        expect(json['elapsedTime'], equals(0));
      });

      test('should serialize complete state to JSON correctly', () {
        final board = List.generate(
          3,
          (_) => List.generate(3, (_) => Player.none),
        );
        board[0][0] = Player.x;
        board[0][1] = Player.x;
        board[0][2] = Player.x;

        final winningLine = [
          const Position(row: 0, col: 0),
          const Position(row: 0, col: 1),
          const Position(row: 0, col: 2),
        ];

        final moveHistory = [
          const Position(row: 0, col: 0),
          const Position(row: 1, col: 0),
          const Position(row: 0, col: 1),
        ];

        final state = GameState(
          board: board,
          currentPlayer: Player.x,
          result: GameResult.win,
          winner: Player.x,
          winningLine: winningLine,
          moveHistory: moveHistory,
          config: testConfig,
          startTime: testStartTime,
          elapsedTime: const Duration(seconds: 45),
        );

        final json = state.toJson();

        expect(json['board'][0][0], equals('x'));
        expect(json['board'][0][1], equals('x'));
        expect(json['board'][0][2], equals('x'));
        expect(json['result'], equals('win'));
        expect(json['winner'], equals('x'));
        expect(json['winningLine'], isA<List>());
        expect(json['winningLine'].length, equals(3));
        expect(json['moveHistory'].length, equals(3));
        expect(json['elapsedTime'], equals(45000000)); // microseconds
      });

      test('should deserialize minimal state from JSON correctly', () {
        final json = {
          'board': [
            ['none', 'none', 'none'],
            ['none', 'none', 'none'],
            ['none', 'none', 'none'],
          ],
          'currentPlayer': 'x',
          'result': 'ongoing',
          'config': {
            'gameMode': 'twoPlayer',
            'firstPlayer': 'x',
            'soundEnabled': true,
            'vibrationEnabled': true,
          },
          'startTime': testStartTime.toIso8601String(),
        };

        final state = GameState.fromJson(json);

        expect(state.currentPlayer, equals(Player.x));
        expect(state.result, equals(GameResult.ongoing));
        expect(state.board.length, equals(3));
        expect(state.board[0].length, equals(3));
        expect(state.board[0][0], equals(Player.none));
      });

      test('should deserialize complete state from JSON correctly', () {
        final json = {
          'board': [
            ['x', 'x', 'x'],
            ['o', 'none', 'none'],
            ['none', 'none', 'none'],
          ],
          'currentPlayer': 'x',
          'result': 'win',
          'winner': 'x',
          'winningLine': [
            {'row': 0, 'col': 0},
            {'row': 0, 'col': 1},
            {'row': 0, 'col': 2},
          ],
          'moveHistory': [
            {'row': 0, 'col': 0},
            {'row': 1, 'col': 0},
          ],
          'config': {
            'gameMode': 'twoPlayer',
            'firstPlayer': 'x',
            'soundEnabled': true,
            'vibrationEnabled': true,
          },
          'startTime': testStartTime.toIso8601String(),
          'elapsedTime': 45000000,
        };

        final state = GameState.fromJson(json);

        expect(state.board[0][0], equals(Player.x));
        expect(state.board[0][1], equals(Player.x));
        expect(state.board[0][2], equals(Player.x));
        expect(state.result, equals(GameResult.win));
        expect(state.winner, equals(Player.x));
        expect(state.winningLine?.length, equals(3));
        expect(state.moveHistory.length, equals(2));
        expect(state.elapsedTime.inSeconds, equals(45));
      });

      test('should round-trip serialize and deserialize correctly', () {
        final board = List.generate(
          3,
          (_) => List.generate(3, (_) => Player.none),
        );
        board[1][1] = Player.x;

        final original = GameState(
          board: board,
          currentPlayer: Player.o,
          result: GameResult.ongoing,
          moveHistory: [const Position(row: 1, col: 1)],
          config: testConfig,
          startTime: testStartTime,
          elapsedTime: const Duration(seconds: 30),
        );

        final json = original.toJson();
        final deserialized = GameState.fromJson(json);

        expect(deserialized.currentPlayer, equals(original.currentPlayer));
        expect(deserialized.result, equals(original.result));
        expect(deserialized.board[1][1], equals(Player.x));
        expect(deserialized.moveHistory.length, equals(1));
        expect(deserialized.elapsedTime.inSeconds, equals(30));
      });
    });

    group('props', () {
      test('should include all fields in props for equality', () {
        final state = GameState(
          board: emptyBoard,
          currentPlayer: Player.x,
          result: GameResult.ongoing,
          config: testConfig,
          startTime: testStartTime,
        );

        expect(state.props.length, equals(9));
        expect(state.props, contains(emptyBoard));
        expect(state.props, contains(Player.x));
        expect(state.props, contains(GameResult.ongoing));
        expect(state.props, contains(testConfig));
        expect(state.props, contains(testStartTime));
      });
    });
  });
}
