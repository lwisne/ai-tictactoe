import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/models/game_config.dart';
import 'package:tic_tac_toe/domain/models/game_mode.dart';
import 'package:tic_tac_toe/domain/models/game_result.dart';
import 'package:tic_tac_toe/domain/models/game_state.dart';
import 'package:tic_tac_toe/domain/models/player.dart';
import 'package:tic_tac_toe/domain/models/position.dart';
import 'package:tic_tac_toe/domain/models/difficulty_level.dart';

void main() {
  group('GameState', () {
    late GameState testState;
    late DateTime testStartTime;

    setUp(() {
      testStartTime = DateTime(2024, 1, 1, 12, 0, 0);
      testState = GameState(
        board: [
          [Player.x, Player.none, Player.none],
          [Player.none, Player.o, Player.none],
          [Player.none, Player.none, Player.none],
        ],
        currentPlayer: Player.x,
        result: GameResult.ongoing,
        winner: null,
        winningLine: null,
        moveHistory: [
          const Position(row: 0, col: 0),
          const Position(row: 1, col: 1),
        ],
        config: const GameConfig(
          gameMode: GameMode.singlePlayer,
          difficultyLevel: DifficultyLevel.medium,
          firstPlayer: Player.x,
        ),
        startTime: testStartTime,
        elapsedTime: const Duration(seconds: 30),
      );
    });

    test('should create instance with all fields', () {
      expect(testState.board.length, equals(3));
      expect(testState.currentPlayer, equals(Player.x));
      expect(testState.result, equals(GameResult.ongoing));
      expect(testState.winner, isNull);
      expect(testState.winningLine, isNull);
      expect(testState.moveHistory.length, equals(2));
      expect(testState.config.gameMode, equals(GameMode.singlePlayer));
      expect(testState.startTime, equals(testStartTime));
      expect(testState.elapsedTime, equals(const Duration(seconds: 30)));
    });

    test('copyWith should update only specified fields', () {
      final updated = testState.copyWith(
        result: GameResult.win,
        winner: Player.x,
        winningLine: [
          const Position(row: 0, col: 0),
          const Position(row: 1, col: 1),
          const Position(row: 2, col: 2),
        ],
      );

      expect(updated.result, equals(GameResult.win));
      expect(updated.winner, equals(Player.x));
      expect(updated.winningLine?.length, equals(3));
      expect(updated.board, equals(testState.board));
      expect(updated.currentPlayer, equals(testState.currentPlayer));
      expect(updated.moveHistory, equals(testState.moveHistory));
    });

    test('copyWith should preserve unchanged fields', () {
      final updated = testState.copyWith(currentPlayer: Player.o);

      expect(updated.currentPlayer, equals(Player.o));
      expect(updated.board, equals(testState.board));
      expect(updated.result, equals(testState.result));
      expect(updated.config, equals(testState.config));
      expect(updated.startTime, equals(testState.startTime));
    });

    test('should serialize to JSON', () {
      final json = testState.toJson();

      expect(json['currentPlayer'], equals('x'));
      expect(json['result'], equals('ongoing'));
      expect(json['winner'], isNull);
      expect(json['winningLine'], isNull);
      expect(json['board'], isA<List>());
      expect((json['board'] as List).length, equals(3));
      expect((json['board'] as List)[0], equals(['x', 'none', 'none']));
      expect((json['board'] as List)[1], equals(['none', 'o', 'none']));
      expect(json['moveHistory'], isA<List>());
      expect((json['moveHistory'] as List).length, equals(2));
      expect((json['moveHistory'] as List)[0], equals({'row': 0, 'col': 0}));
      expect(json['config'], isA<Map>());
      expect(json['startTime'], isA<String>());
      expect(json['elapsedTimeMs'], equals(30000));
    });

    test('should deserialize from JSON', () {
      final json = testState.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.board.length, equals(3));
      expect(restored.board[0][0], equals(Player.x));
      expect(restored.board[1][1], equals(Player.o));
      expect(restored.currentPlayer, equals(Player.x));
      expect(restored.result, equals(GameResult.ongoing));
      expect(restored.winner, isNull);
      expect(restored.winningLine, isNull);
      expect(restored.moveHistory.length, equals(2));
      expect(restored.moveHistory[0].row, equals(0));
      expect(restored.moveHistory[0].col, equals(0));
      expect(restored.config.gameMode, equals(GameMode.singlePlayer));
      expect(restored.elapsedTime, equals(const Duration(seconds: 30)));
    });

    test('should serialize and deserialize with winner and winning line', () {
      final stateWithWin = testState.copyWith(
        result: GameResult.win,
        winner: Player.x,
        winningLine: [
          const Position(row: 0, col: 0),
          const Position(row: 1, col: 1),
          const Position(row: 2, col: 2),
        ],
      );

      final json = stateWithWin.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.result, equals(GameResult.win));
      expect(restored.winner, equals(Player.x));
      expect(restored.winningLine?.length, equals(3));
      expect(restored.winningLine?[0].row, equals(0));
      expect(restored.winningLine?[0].col, equals(0));
      expect(restored.winningLine?[2].row, equals(2));
      expect(restored.winningLine?[2].col, equals(2));
    });

    test('should correctly convert Player enum to string', () {
      final json = testState.toJson();
      expect(json['currentPlayer'], equals('x'));

      final stateWithO = testState.copyWith(currentPlayer: Player.o);
      final jsonO = stateWithO.toJson();
      expect(jsonO['currentPlayer'], equals('o'));

      final emptyBoard = testState.copyWith(
        board: [
          [Player.none, Player.none, Player.none],
          [Player.none, Player.none, Player.none],
          [Player.none, Player.none, Player.none],
        ],
      );
      final jsonEmpty = emptyBoard.toJson();
      expect((jsonEmpty['board'] as List)[0], equals(['none', 'none', 'none']));
    });

    test('should correctly convert string to Player enum', () {
      final json = {
        'board': [
          ['x', 'o', 'none'],
          ['none', 'x', 'o'],
          ['o', 'none', 'x'],
        ],
        'currentPlayer': 'o',
        'result': 'ongoing',
        'winner': null,
        'winningLine': null,
        'moveHistory': [],
        'config': {
          'gameMode': 'twoPlayer',
          'difficultyLevel': null,
          'firstPlayer': 'x',
          'soundEnabled': true,
          'vibrationEnabled': true,
        },
        'startTime': '2024-01-01T12:00:00.000',
        'elapsedTimeMs': 0,
      };

      final state = GameState.fromJson(json);
      expect(state.board[0][0], equals(Player.x));
      expect(state.board[0][1], equals(Player.o));
      expect(state.board[0][2], equals(Player.none));
      expect(state.currentPlayer, equals(Player.o));
    });

    test('should correctly convert GameResult enum to string', () {
      final ongoing = testState.toJson();
      expect(ongoing['result'], equals('ongoing'));

      final win = testState.copyWith(result: GameResult.win).toJson();
      expect(win['result'], equals('win'));

      final loss = testState.copyWith(result: GameResult.loss).toJson();
      expect(loss['result'], equals('loss'));

      final draw = testState.copyWith(result: GameResult.draw).toJson();
      expect(draw['result'], equals('draw'));
    });

    test('should correctly convert string to GameResult enum', () {
      final baseJson = testState.toJson();

      final ongoing = GameState.fromJson({...baseJson, 'result': 'ongoing'});
      expect(ongoing.result, equals(GameResult.ongoing));

      final win = GameState.fromJson({...baseJson, 'result': 'win'});
      expect(win.result, equals(GameResult.win));

      final loss = GameState.fromJson({...baseJson, 'result': 'loss'});
      expect(loss.result, equals(GameResult.loss));

      final draw = GameState.fromJson({...baseJson, 'result': 'draw'});
      expect(draw.result, equals(GameResult.draw));
    });

    test('should handle default values for invalid enums', () {
      final json = testState.toJson();
      json['currentPlayer'] = 'invalid';
      json['result'] = 'invalid';

      final state = GameState.fromJson(json);
      expect(state.currentPlayer, equals(Player.none));
      expect(state.result, equals(GameResult.ongoing));
    });

    test('equality should work correctly', () {
      final state1 = GameState(
        board: [
          [Player.none, Player.none, Player.none],
          [Player.none, Player.none, Player.none],
          [Player.none, Player.none, Player.none],
        ],
        currentPlayer: Player.x,
        config: const GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
        ),
        startTime: DateTime(2024, 1, 1),
      );

      final state2 = GameState(
        board: [
          [Player.none, Player.none, Player.none],
          [Player.none, Player.none, Player.none],
          [Player.none, Player.none, Player.none],
        ],
        currentPlayer: Player.x,
        config: const GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
        ),
        startTime: DateTime(2024, 1, 1),
      );

      final state3 = state1.copyWith(currentPlayer: Player.o);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('should serialize DateTime to ISO8601 string', () {
      final json = testState.toJson();
      expect(json['startTime'], isA<String>());
      expect(json['startTime'], contains('2024-01-01'));
      expect(json['startTime'], contains('12:00:00'));
    });

    test('should deserialize ISO8601 string to DateTime', () {
      final json = testState.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.startTime.year, equals(2024));
      expect(restored.startTime.month, equals(1));
      expect(restored.startTime.day, equals(1));
      expect(restored.startTime.hour, equals(12));
    });

    test('should serialize Duration to milliseconds', () {
      final json = testState.toJson();
      expect(json['elapsedTimeMs'], equals(30000));

      final longGame = testState.copyWith(
        elapsedTime: const Duration(minutes: 5, seconds: 30),
      );
      final jsonLong = longGame.toJson();
      expect(jsonLong['elapsedTimeMs'], equals(330000));
    });

    test('should deserialize milliseconds to Duration', () {
      final json = testState.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.elapsedTime, equals(const Duration(seconds: 30)));
    });

    test('should handle empty move history', () {
      final stateNoMoves = testState.copyWith(moveHistory: []);
      final json = stateNoMoves.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.moveHistory, isEmpty);
    });

    test('should handle multiple moves in history', () {
      final positions = [
        const Position(row: 0, col: 0),
        const Position(row: 1, col: 1),
        const Position(row: 2, col: 2),
        const Position(row: 0, col: 1),
        const Position(row: 0, col: 2),
      ];
      final stateWithMoves = testState.copyWith(moveHistory: positions);
      final json = stateWithMoves.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.moveHistory.length, equals(5));
      expect(restored.moveHistory[0].row, equals(0));
      expect(restored.moveHistory[0].col, equals(0));
      expect(restored.moveHistory[4].row, equals(0));
      expect(restored.moveHistory[4].col, equals(2));
    });
  });
}
