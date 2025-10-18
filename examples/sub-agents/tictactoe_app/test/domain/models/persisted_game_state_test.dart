import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/domain/models/game_config.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/domain/models/game_result.dart';
import 'package:tictactoe_app/domain/models/game_state.dart';
import 'package:tictactoe_app/domain/models/persisted_game_state.dart';
import 'package:tictactoe_app/domain/models/player.dart';

void main() {
  late GameState testGameState;
  late DateTime testTime;

  setUp(() {
    testTime = DateTime(2024, 1, 1, 12, 0, 0);
    testGameState = GameState(
      board: [
        [Player.x, Player.none, Player.none],
        [Player.none, Player.o, Player.none],
        [Player.none, Player.none, Player.none],
      ],
      currentPlayer: Player.x,
      result: GameResult.ongoing,
      config: const GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      ),
      startTime: testTime,
    );
  });

  group('PersistedGameState', () {
    group('constructor', () {
      test('should create instance with all required fields', () {
        final persistedState = PersistedGameState(
          gameState: testGameState,
          playerWins: 3,
          aiWins: 2,
          draws: 1,
          savedAt: testTime,
        );

        expect(persistedState.gameState, testGameState);
        expect(persistedState.playerWins, 3);
        expect(persistedState.aiWins, 2);
        expect(persistedState.draws, 1);
        expect(persistedState.savedAt, testTime);
      });

      test('should use default values for optional score fields', () {
        final persistedState = PersistedGameState(
          gameState: testGameState,
          savedAt: testTime,
        );

        expect(persistedState.playerWins, 0);
        expect(persistedState.aiWins, 0);
        expect(persistedState.draws, 0);
      });
    });

    group('toJson', () {
      test('should convert to JSON with all fields', () {
        final persistedState = PersistedGameState(
          gameState: testGameState,
          playerWins: 5,
          aiWins: 3,
          draws: 2,
          savedAt: testTime,
        );

        final json = persistedState.toJson();

        expect(json['gameState'], isA<Map<String, dynamic>>());
        expect(json['playerWins'], 5);
        expect(json['aiWins'], 3);
        expect(json['draws'], 2);
        expect(json['savedAt'], testTime.toIso8601String());
      });

      test('should include nested game state JSON', () {
        final persistedState = PersistedGameState(
          gameState: testGameState,
          savedAt: testTime,
        );

        final json = persistedState.toJson();
        final gameStateJson = json['gameState'] as Map<String, dynamic>;

        expect(gameStateJson['board'], isA<List>());
        expect(gameStateJson['currentPlayer'], isA<String>());
        expect(gameStateJson['config'], isA<Map<String, dynamic>>());
      });
    });

    group('fromJson', () {
      test('should create instance from valid JSON', () {
        final json = {
          'gameState': testGameState.toJson(),
          'playerWins': 7,
          'aiWins': 4,
          'draws': 3,
          'savedAt': testTime.toIso8601String(),
        };

        final persistedState = PersistedGameState.fromJson(json);

        expect(persistedState.playerWins, 7);
        expect(persistedState.aiWins, 4);
        expect(persistedState.draws, 3);
        expect(persistedState.savedAt, testTime);
        expect(persistedState.gameState.currentPlayer, Player.x);
      });

      test('should handle missing optional score fields with defaults', () {
        final json = {
          'gameState': testGameState.toJson(),
          'savedAt': testTime.toIso8601String(),
        };

        final persistedState = PersistedGameState.fromJson(json);

        expect(persistedState.playerWins, 0);
        expect(persistedState.aiWins, 0);
        expect(persistedState.draws, 0);
      });

      test('should round-trip through JSON correctly', () {
        final original = PersistedGameState(
          gameState: testGameState,
          playerWins: 10,
          aiWins: 8,
          draws: 5,
          savedAt: testTime,
        );

        final json = original.toJson();
        final restored = PersistedGameState.fromJson(json);

        expect(restored.playerWins, original.playerWins);
        expect(restored.aiWins, original.aiWins);
        expect(restored.draws, original.draws);
        expect(restored.savedAt, original.savedAt);
        expect(
          restored.gameState.currentPlayer,
          original.gameState.currentPlayer,
        );
      });
    });

    group('copyWith', () {
      test('should create copy with modified game state', () {
        final original = PersistedGameState(
          gameState: testGameState,
          playerWins: 3,
          savedAt: testTime,
        );

        final newGameState = testGameState.copyWith(currentPlayer: Player.o);
        final copy = original.copyWith(gameState: newGameState);

        expect(copy.gameState.currentPlayer, Player.o);
        expect(copy.playerWins, 3);
        expect(copy, isNot(equals(original)));
      });

      test('should create copy with modified scores', () {
        final original = PersistedGameState(
          gameState: testGameState,
          playerWins: 3,
          aiWins: 2,
          draws: 1,
          savedAt: testTime,
        );

        final copy = original.copyWith(playerWins: 5, draws: 3);

        expect(copy.playerWins, 5);
        expect(copy.aiWins, 2); // Unchanged
        expect(copy.draws, 3);
      });

      test('should create copy with modified savedAt', () {
        final original = PersistedGameState(
          gameState: testGameState,
          savedAt: testTime,
        );

        final newTime = DateTime(2024, 1, 2);
        final copy = original.copyWith(savedAt: newTime);

        expect(copy.savedAt, newTime);
        expect(copy.gameState, original.gameState);
      });

      test('should not modify original when copying', () {
        final original = PersistedGameState(
          gameState: testGameState,
          playerWins: 3,
          savedAt: testTime,
        );

        final copy = original.copyWith(playerWins: 10);

        expect(original.playerWins, 3);
        expect(copy.playerWins, 10);
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        final state1 = PersistedGameState(
          gameState: testGameState,
          playerWins: 3,
          aiWins: 2,
          draws: 1,
          savedAt: testTime,
        );

        final state2 = PersistedGameState(
          gameState: testGameState,
          playerWins: 3,
          aiWins: 2,
          draws: 1,
          savedAt: testTime,
        );

        expect(state1, equals(state2));
      });

      test('should not be equal for different scores', () {
        final state1 = PersistedGameState(
          gameState: testGameState,
          playerWins: 3,
          savedAt: testTime,
        );

        final state2 = PersistedGameState(
          gameState: testGameState,
          playerWins: 5,
          savedAt: testTime,
        );

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal for different timestamps', () {
        final state1 = PersistedGameState(
          gameState: testGameState,
          savedAt: testTime,
        );

        final state2 = PersistedGameState(
          gameState: testGameState,
          savedAt: DateTime(2024, 1, 2),
        );

        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
