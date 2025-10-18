import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe_app/data/repositories/game_state_persistence_repository.dart';
import 'package:tictactoe_app/domain/models/game_config.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/domain/models/game_result.dart';
import 'package:tictactoe_app/domain/models/game_state.dart';
import 'package:tictactoe_app/domain/models/persisted_game_state.dart';
import 'package:tictactoe_app/domain/models/player.dart';

void main() {
  late GameStatePersistenceRepository repository;
  late PersistedGameState testPersistedState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = GameStatePersistenceRepository();

    final gameState = GameState(
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
      startTime: DateTime(2024, 1, 1, 12, 0, 0),
    );

    testPersistedState = PersistedGameState(
      gameState: gameState,
      playerWins: 3,
      aiWins: 2,
      draws: 1,
      savedAt: DateTime(2024, 1, 1, 12, 30, 0),
    );
  });

  group('GameStatePersistenceRepository', () {
    group('saveGameState', () {
      test('should save game state to SharedPreferences', () async {
        await repository.saveGameState(testPersistedState);

        final prefs = await SharedPreferences.getInstance();
        final savedJson = prefs.getString('current_game_state');
        expect(savedJson, isNotNull);
        expect(savedJson, contains('"playerWins":3'));
        expect(savedJson, contains('"aiWins":2'));
      });

      test('should overwrite existing saved state', () async {
        await repository.saveGameState(testPersistedState);

        final newPersistedState = testPersistedState.copyWith(playerWins: 10);
        await repository.saveGameState(newPersistedState);

        final loaded = await repository.loadGameState();
        expect(loaded?.playerWins, 10);
      });

      test('should save complete game state with all fields', () async {
        await repository.saveGameState(testPersistedState);

        final loaded = await repository.loadGameState();
        expect(loaded, isNotNull);
        expect(loaded!.playerWins, testPersistedState.playerWins);
        expect(loaded.aiWins, testPersistedState.aiWins);
        expect(loaded.draws, testPersistedState.draws);
        expect(
          loaded.gameState.currentPlayer,
          testPersistedState.gameState.currentPlayer,
        );
      });
    });

    group('loadGameState', () {
      test('should load saved game state', () async {
        await repository.saveGameState(testPersistedState);

        final loaded = await repository.loadGameState();

        expect(loaded, isNotNull);
        expect(loaded!.playerWins, 3);
        expect(loaded.aiWins, 2);
        expect(loaded.draws, 1);
        expect(loaded.gameState.currentPlayer, Player.x);
        expect(loaded.gameState.result, GameResult.ongoing);
      });

      test('should return null when no saved state exists', () async {
        final loaded = await repository.loadGameState();

        expect(loaded, isNull);
      });

      test('should return null and clean up corrupted data', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_game_state', 'invalid json');

        final loaded = await repository.loadGameState();

        expect(loaded, isNull);
        expect(await repository.hasGameState(), isFalse);
      });

      test('should handle corrupted JSON gracefully', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_game_state', '{invalid}');

        final loaded = await repository.loadGameState();

        expect(loaded, isNull);
      });

      test('should handle malformed game state data', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'current_game_state',
          '{"playerWins": "not a number"}',
        );

        final loaded = await repository.loadGameState();

        expect(loaded, isNull);
      });

      test('should preserve session scores across save/load', () async {
        final state = testPersistedState.copyWith(
          playerWins: 15,
          aiWins: 10,
          draws: 5,
        );
        await repository.saveGameState(state);

        final loaded = await repository.loadGameState();

        expect(loaded?.playerWins, 15);
        expect(loaded?.aiWins, 10);
        expect(loaded?.draws, 5);
      });
    });

    group('hasGameState', () {
      test('should return true when saved state exists', () async {
        await repository.saveGameState(testPersistedState);

        final exists = await repository.hasGameState();

        expect(exists, isTrue);
      });

      test('should return false when no saved state exists', () async {
        final exists = await repository.hasGameState();

        expect(exists, isFalse);
      });

      test('should return false after state is cleared', () async {
        await repository.saveGameState(testPersistedState);
        await repository.clearGameState();

        final exists = await repository.hasGameState();

        expect(exists, isFalse);
      });
    });

    group('clearGameState', () {
      test('should remove saved game state', () async {
        await repository.saveGameState(testPersistedState);
        expect(await repository.hasGameState(), isTrue);

        await repository.clearGameState();

        expect(await repository.hasGameState(), isFalse);
        expect(await repository.loadGameState(), isNull);
      });

      test('should not throw when clearing non-existent state', () async {
        expect(() async => await repository.clearGameState(), returnsNormally);
      });

      test('should remove data from SharedPreferences', () async {
        await repository.saveGameState(testPersistedState);
        await repository.clearGameState();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.containsKey('current_game_state'), isFalse);
      });
    });

    group('round-trip persistence', () {
      test('should preserve all data through save/load cycle', () async {
        await repository.saveGameState(testPersistedState);

        final loaded = await repository.loadGameState();

        expect(loaded, equals(testPersistedState));
      });

      test('should handle multiple save/load cycles', () async {
        for (var i = 0; i < 5; i++) {
          final state = testPersistedState.copyWith(playerWins: i);
          await repository.saveGameState(state);

          final loaded = await repository.loadGameState();
          expect(loaded?.playerWins, i);
        }
      });

      test('should preserve game board state correctly', () async {
        await repository.saveGameState(testPersistedState);

        final loaded = await repository.loadGameState();

        expect(loaded?.gameState.board[0][0], Player.x);
        expect(loaded?.gameState.board[1][1], Player.o);
        expect(loaded?.gameState.board[2][2], Player.none);
      });

      test('should preserve timestamp accurately', () async {
        final savedAt = DateTime(2024, 6, 15, 14, 30, 45);
        final state = testPersistedState.copyWith(savedAt: savedAt);

        await repository.saveGameState(state);
        final loaded = await repository.loadGameState();

        expect(loaded?.savedAt, savedAt);
      });
    });

    group('edge cases', () {
      test('should handle state with all zeros for scores', () async {
        final state = testPersistedState.copyWith(
          playerWins: 0,
          aiWins: 0,
          draws: 0,
        );
        await repository.saveGameState(state);

        final loaded = await repository.loadGameState();

        expect(loaded?.playerWins, 0);
        expect(loaded?.aiWins, 0);
        expect(loaded?.draws, 0);
      });

      test('should handle state with very large score values', () async {
        final state = testPersistedState.copyWith(
          playerWins: 99999,
          aiWins: 88888,
          draws: 77777,
        );
        await repository.saveGameState(state);

        final loaded = await repository.loadGameState();

        expect(loaded?.playerWins, 99999);
        expect(loaded?.aiWins, 88888);
        expect(loaded?.draws, 77777);
      });

      test('should handle different game modes', () async {
        final vsAiState = GameState(
          board: [
            [Player.x, Player.none, Player.none],
            [Player.none, Player.none, Player.none],
            [Player.none, Player.none, Player.none],
          ],
          currentPlayer: Player.o,
          result: GameResult.ongoing,
          config: const GameConfig(
            gameMode: GameMode.vsAi,
            firstPlayer: Player.x,
          ),
          startTime: DateTime.now(),
        );

        final persistedVsAi = PersistedGameState(
          gameState: vsAiState,
          savedAt: DateTime.now(),
        );

        await repository.saveGameState(persistedVsAi);
        final loaded = await repository.loadGameState();

        expect(loaded?.gameState.config.gameMode, GameMode.vsAi);
      });
    });
  });
}
