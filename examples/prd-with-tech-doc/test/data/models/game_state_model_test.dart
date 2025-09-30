import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/data/models/game_state_model.dart';
import 'package:tic_tac_toe/domain/entities/difficulty_level.dart';
import 'package:tic_tac_toe/domain/entities/game_config.dart';
import 'package:tic_tac_toe/domain/entities/game_mode.dart';
import 'package:tic_tac_toe/domain/entities/game_result.dart';
import 'package:tic_tac_toe/domain/entities/game_state.dart';
import 'package:tic_tac_toe/domain/entities/player.dart';
import 'package:tic_tac_toe/domain/entities/position.dart';

void main() {
  group('GameConfigModel', () {
    group('fromJson', () {
      test('should create GameConfigModel from valid JSON', () {
        // Arrange
        final json = {
          'gameMode': 'singlePlayer',
          'difficultyLevel': 'medium',
          'firstPlayer': 'x',
          'soundEnabled': true,
          'vibrationEnabled': false,
        };

        // Act
        final model = GameConfigModel.fromJson(json);

        // Assert
        expect(model.gameMode, equals('singlePlayer'));
        expect(model.difficultyLevel, equals('medium'));
        expect(model.firstPlayer, equals('x'));
        expect(model.soundEnabled, isTrue);
        expect(model.vibrationEnabled, isFalse);
      });

      test('should handle null difficultyLevel', () {
        // Arrange
        final json = {
          'gameMode': 'twoPlayer',
          'difficultyLevel': null,
          'firstPlayer': 'o',
          'soundEnabled': false,
          'vibrationEnabled': true,
        };

        // Act
        final model = GameConfigModel.fromJson(json);

        // Assert
        expect(model.gameMode, equals('twoPlayer'));
        expect(model.difficultyLevel, isNull);
        expect(model.firstPlayer, equals('o'));
      });
    });

    group('toJson', () {
      test('should convert GameConfigModel to JSON', () {
        // Arrange
        const model = GameConfigModel(
          gameMode: 'singlePlayer',
          difficultyLevel: 'hard',
          firstPlayer: 'x',
          soundEnabled: true,
          vibrationEnabled: true,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['gameMode'], equals('singlePlayer'));
        expect(json['difficultyLevel'], equals('hard'));
        expect(json['firstPlayer'], equals('x'));
        expect(json['soundEnabled'], isTrue);
        expect(json['vibrationEnabled'], isTrue);
      });

      test('should handle null difficultyLevel in JSON', () {
        // Arrange
        const model = GameConfigModel(
          gameMode: 'twoPlayer',
          difficultyLevel: null,
          firstPlayer: 'o',
          soundEnabled: false,
          vibrationEnabled: false,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['difficultyLevel'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create GameConfigModel from GameConfig entity', () {
        // Arrange
        const config = GameConfig(
          gameMode: GameMode.singlePlayer,
          difficultyLevel: DifficultyLevel.easy,
          firstPlayer: Player.x,
          soundEnabled: true,
          vibrationEnabled: false,
        );

        // Act
        final model = GameConfigModel.fromEntity(config);

        // Assert
        expect(model.gameMode, equals('singlePlayer'));
        expect(model.difficultyLevel, equals('easy'));
        expect(model.firstPlayer, equals('x'));
        expect(model.soundEnabled, isTrue);
        expect(model.vibrationEnabled, isFalse);
      });

      test('should handle null difficultyLevel from entity', () {
        // Arrange
        const config = GameConfig(
          gameMode: GameMode.twoPlayer,
          difficultyLevel: null,
          firstPlayer: Player.o,
        );

        // Act
        final model = GameConfigModel.fromEntity(config);

        // Assert
        expect(model.difficultyLevel, isNull);
      });
    });

    group('toEntity', () {
      test('should convert GameConfigModel to GameConfig entity', () {
        // Arrange
        const model = GameConfigModel(
          gameMode: 'singlePlayer',
          difficultyLevel: 'medium',
          firstPlayer: 'o',
          soundEnabled: false,
          vibrationEnabled: true,
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.gameMode, equals(GameMode.singlePlayer));
        expect(entity.difficultyLevel, equals(DifficultyLevel.medium));
        expect(entity.firstPlayer, equals(Player.o));
        expect(entity.soundEnabled, isFalse);
        expect(entity.vibrationEnabled, isTrue);
      });
    });

    group('JSON round-trip', () {
      test('should maintain data through JSON serialization round-trip', () {
        // Arrange
        const original = GameConfigModel(
          gameMode: 'singlePlayer',
          difficultyLevel: 'hard',
          firstPlayer: 'x',
          soundEnabled: true,
          vibrationEnabled: false,
        );

        // Act
        final json = original.toJson();
        final restored = GameConfigModel.fromJson(json);

        // Assert
        expect(restored.gameMode, equals(original.gameMode));
        expect(restored.difficultyLevel, equals(original.difficultyLevel));
        expect(restored.firstPlayer, equals(original.firstPlayer));
        expect(restored.soundEnabled, equals(original.soundEnabled));
        expect(restored.vibrationEnabled, equals(original.vibrationEnabled));
      });
    });

    group('Entity conversion round-trip', () {
      test('should maintain data through entity conversion round-trip', () {
        // Arrange
        const originalEntity = GameConfig(
          gameMode: GameMode.twoPlayer,
          difficultyLevel: DifficultyLevel.medium,
          firstPlayer: Player.o,
          soundEnabled: false,
          vibrationEnabled: true,
        );

        // Act
        final model = GameConfigModel.fromEntity(originalEntity);
        final restoredEntity = model.toEntity();

        // Assert
        expect(restoredEntity.gameMode, equals(originalEntity.gameMode));
        expect(restoredEntity.difficultyLevel, equals(originalEntity.difficultyLevel));
        expect(restoredEntity.firstPlayer, equals(originalEntity.firstPlayer));
        expect(restoredEntity.soundEnabled, equals(originalEntity.soundEnabled));
        expect(restoredEntity.vibrationEnabled, equals(originalEntity.vibrationEnabled));
      });
    });
  });

  group('GameStateModel', () {
    late DateTime testStartTime;

    setUp(() {
      testStartTime = DateTime(2024, 1, 15, 10, 30, 0);
    });

    group('fromJson', () {
      test('should create GameStateModel from valid JSON', () {
        // Arrange
        final json = {
          'board': [
            ['x', 'o', 'none'],
            ['none', 'x', 'none'],
            ['none', 'none', 'o'],
          ],
          'currentPlayer': 'x',
          'result': 'ongoing',
          'winner': null,
          'winningLine': null,
          'moveHistory': [
            {'row': 0, 'col': 0},
            {'row': 0, 'col': 1},
          ],
          'config': {
            'gameMode': 'singlePlayer',
            'difficultyLevel': 'easy',
            'firstPlayer': 'x',
            'soundEnabled': true,
            'vibrationEnabled': true,
          },
          'startTime': '2024-01-15T10:30:00.000',
          'elapsedTimeMs': 5000,
        };

        // Act
        final model = GameStateModel.fromJson(json);

        // Assert
        expect(model.board.length, equals(3));
        expect(model.board[0][0], equals('x'));
        expect(model.currentPlayer, equals('x'));
        expect(model.result, equals('ongoing'));
        expect(model.winner, isNull);
        expect(model.winningLine, isNull);
        expect(model.moveHistory.length, equals(2));
        expect(model.config.gameMode, equals('singlePlayer'));
        expect(model.elapsedTimeMs, equals(5000));
      });

      test('should handle game with winner and winning line', () {
        // Arrange
        final json = {
          'board': [
            ['x', 'x', 'x'],
            ['o', 'o', 'none'],
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
          'moveHistory': [],
          'config': {
            'gameMode': 'twoPlayer',
            'difficultyLevel': null,
            'firstPlayer': 'x',
            'soundEnabled': false,
            'vibrationEnabled': false,
          },
          'startTime': '2024-01-15T10:30:00.000',
          'elapsedTimeMs': 10000,
        };

        // Act
        final model = GameStateModel.fromJson(json);

        // Assert
        expect(model.result, equals('win'));
        expect(model.winner, equals('x'));
        expect(model.winningLine, isNotNull);
        expect(model.winningLine!.length, equals(3));
      });
    });

    group('toJson', () {
      test('should convert GameStateModel to JSON', () {
        // Arrange
        final model = GameStateModel(
          board: [
            ['x', 'o', 'none'],
            ['none', 'x', 'none'],
            ['none', 'none', 'o'],
          ],
          currentPlayer: 'x',
          result: 'ongoing',
          winner: null,
          winningLine: null,
          moveHistory: [
            {'row': 0, 'col': 0},
          ],
          config: const GameConfigModel(
            gameMode: 'singlePlayer',
            difficultyLevel: 'medium',
            firstPlayer: 'x',
            soundEnabled: true,
            vibrationEnabled: true,
          ),
          startTime: '2024-01-15T10:30:00.000',
          elapsedTimeMs: 3000,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['board'], isA<List>());
        expect(json['currentPlayer'], equals('x'));
        expect(json['result'], equals('ongoing'));
        expect(json['winner'], isNull);
        expect(json['config'], isA<Map>());
        expect(json['elapsedTimeMs'], equals(3000));
      });
    });

    group('fromEntity', () {
      test('should create GameStateModel from GameState entity', () {
        // Arrange
        final state = GameState(
          board: [
            [Player.x, Player.o, Player.none],
            [Player.none, Player.x, Player.none],
            [Player.none, Player.none, Player.o],
          ],
          currentPlayer: Player.x,
          result: GameResult.ongoing,
          moveHistory: const [
            Position(row: 0, col: 0),
            Position(row: 0, col: 1),
          ],
          config: const GameConfig(
            gameMode: GameMode.singlePlayer,
            difficultyLevel: DifficultyLevel.easy,
          ),
          startTime: testStartTime,
          elapsedTime: const Duration(milliseconds: 5000),
        );

        // Act
        final model = GameStateModel.fromEntity(state);

        // Assert
        expect(model.board[0][0], equals('x'));
        expect(model.board[0][1], equals('o'));
        expect(model.board[0][2], equals('none'));
        expect(model.currentPlayer, equals('x'));
        expect(model.result, equals('ongoing'));
        expect(model.moveHistory.length, equals(2));
        expect(model.elapsedTimeMs, equals(5000));
      });

      test('should handle game with winner', () {
        // Arrange
        final state = GameState(
          board: [
            [Player.x, Player.x, Player.x],
            [Player.o, Player.o, Player.none],
            [Player.none, Player.none, Player.none],
          ],
          currentPlayer: Player.x,
          result: GameResult.win,
          winner: Player.x,
          winningLine: const [
            Position(row: 0, col: 0),
            Position(row: 0, col: 1),
            Position(row: 0, col: 2),
          ],
          config: const GameConfig(gameMode: GameMode.twoPlayer),
          startTime: testStartTime,
        );

        // Act
        final model = GameStateModel.fromEntity(state);

        // Assert
        expect(model.winner, equals('x'));
        expect(model.winningLine, isNotNull);
        expect(model.winningLine!.length, equals(3));
        expect(model.winningLine![0]['row'], equals(0));
        expect(model.winningLine![0]['col'], equals(0));
      });
    });

    group('toEntity', () {
      test('should convert GameStateModel to GameState entity', () {
        // Arrange
        final model = GameStateModel(
          board: [
            ['x', 'o', 'none'],
            ['none', 'x', 'none'],
            ['none', 'none', 'o'],
          ],
          currentPlayer: 'o',
          result: 'ongoing',
          winner: null,
          winningLine: null,
          moveHistory: [
            {'row': 0, 'col': 0},
            {'row': 0, 'col': 1},
            {'row': 1, 'col': 1},
          ],
          config: const GameConfigModel(
            gameMode: 'singlePlayer',
            difficultyLevel: 'hard',
            firstPlayer: 'x',
            soundEnabled: true,
            vibrationEnabled: false,
          ),
          startTime: '2024-01-15T10:30:00.000',
          elapsedTimeMs: 7500,
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.board[0][0], equals(Player.x));
        expect(entity.board[0][1], equals(Player.o));
        expect(entity.board[0][2], equals(Player.none));
        expect(entity.currentPlayer, equals(Player.o));
        expect(entity.result, equals(GameResult.ongoing));
        expect(entity.moveHistory.length, equals(3));
        expect(entity.moveHistory[2].row, equals(1));
        expect(entity.moveHistory[2].col, equals(1));
        expect(entity.elapsedTime.inMilliseconds, equals(7500));
        expect(entity.config.gameMode, equals(GameMode.singlePlayer));
        expect(entity.config.difficultyLevel, equals(DifficultyLevel.hard));
      });
    });

    group('JSON round-trip', () {
      test('should maintain data through JSON serialization round-trip', () {
        // Arrange
        final original = GameStateModel(
          board: [
            ['x', 'o', 'x'],
            ['o', 'x', 'o'],
            ['none', 'none', 'none'],
          ],
          currentPlayer: 'x',
          result: 'ongoing',
          winner: null,
          winningLine: null,
          moveHistory: [
            {'row': 0, 'col': 0},
          ],
          config: const GameConfigModel(
            gameMode: 'twoPlayer',
            difficultyLevel: null,
            firstPlayer: 'x',
            soundEnabled: false,
            vibrationEnabled: true,
          ),
          startTime: '2024-01-15T10:30:00.000',
          elapsedTimeMs: 12000,
        );

        // Act
        final json = original.toJson();
        final restored = GameStateModel.fromJson(json);

        // Assert
        expect(restored.board.length, equals(original.board.length));
        expect(restored.board[0][0], equals(original.board[0][0]));
        expect(restored.currentPlayer, equals(original.currentPlayer));
        expect(restored.result, equals(original.result));
        expect(restored.elapsedTimeMs, equals(original.elapsedTimeMs));
      });
    });

    group('Entity conversion round-trip', () {
      test('should maintain data through entity conversion round-trip', () {
        // Arrange
        final originalEntity = GameState(
          board: [
            [Player.x, Player.o, Player.x],
            [Player.o, Player.x, Player.o],
            [Player.none, Player.none, Player.none],
          ],
          currentPlayer: Player.o,
          result: GameResult.ongoing,
          moveHistory: const [
            Position(row: 0, col: 0),
            Position(row: 0, col: 1),
          ],
          config: const GameConfig(
            gameMode: GameMode.singlePlayer,
            difficultyLevel: DifficultyLevel.medium,
          ),
          startTime: testStartTime,
          elapsedTime: const Duration(milliseconds: 8500),
        );

        // Act
        final model = GameStateModel.fromEntity(originalEntity);
        final restoredEntity = model.toEntity();

        // Assert
        expect(restoredEntity.board[0][0], equals(originalEntity.board[0][0]));
        expect(restoredEntity.currentPlayer, equals(originalEntity.currentPlayer));
        expect(restoredEntity.result, equals(originalEntity.result));
        expect(restoredEntity.moveHistory.length, equals(originalEntity.moveHistory.length));
        expect(restoredEntity.elapsedTime, equals(originalEntity.elapsedTime));
      });
    });

    group('Integration scenarios', () {
      test('should handle full workflow: Entity -> Model -> JSON -> Model -> Entity', () {
        // Arrange
        final originalEntity = GameState(
          board: [
            [Player.x, Player.x, Player.o],
            [Player.o, Player.o, Player.x],
            [Player.x, Player.none, Player.none],
          ],
          currentPlayer: Player.o,
          result: GameResult.ongoing,
          moveHistory: const [
            Position(row: 0, col: 0),
            Position(row: 0, col: 2),
            Position(row: 0, col: 1),
          ],
          config: const GameConfig(
            gameMode: GameMode.singlePlayer,
            difficultyLevel: DifficultyLevel.hard,
            firstPlayer: Player.x,
            soundEnabled: true,
            vibrationEnabled: false,
          ),
          startTime: testStartTime,
          elapsedTime: const Duration(milliseconds: 15000),
        );

        // Act
        final model1 = GameStateModel.fromEntity(originalEntity);
        final json = model1.toJson();
        final model2 = GameStateModel.fromJson(json);
        final finalEntity = model2.toEntity();

        // Assert
        expect(finalEntity.board[0][0], equals(originalEntity.board[0][0]));
        expect(finalEntity.board[2][2], equals(originalEntity.board[2][2]));
        expect(finalEntity.currentPlayer, equals(originalEntity.currentPlayer));
        expect(finalEntity.result, equals(originalEntity.result));
        expect(finalEntity.moveHistory.length, equals(originalEntity.moveHistory.length));
        expect(finalEntity.config.gameMode, equals(originalEntity.config.gameMode));
        expect(finalEntity.config.difficultyLevel, equals(originalEntity.config.difficultyLevel));
        expect(finalEntity.elapsedTime, equals(originalEntity.elapsedTime));
        expect(finalEntity.startTime.toIso8601String(), equals(originalEntity.startTime.toIso8601String()));
      });
    });
  });
}
