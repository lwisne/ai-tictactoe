import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe_app/data/repositories/game_mode_repository.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';

void main() {
  late GameModeRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = GameModeRepository();
  });

  group('GameModeRepository', () {
    group('saveLastPlayedMode', () {
      test('should save vsAi mode to SharedPreferences', () async {
        await repository.saveLastPlayedMode(GameMode.vsAi);

        final prefs = await SharedPreferences.getInstance();
        final savedMode = prefs.getString('last_played_game_mode');
        expect(savedMode, isNotNull);
        expect(savedMode, equals('vsAi'));
      });

      test('should save twoPlayer mode to SharedPreferences', () async {
        await repository.saveLastPlayedMode(GameMode.twoPlayer);

        final prefs = await SharedPreferences.getInstance();
        final savedMode = prefs.getString('last_played_game_mode');
        expect(savedMode, isNotNull);
        expect(savedMode, equals('twoPlayer'));
      });

      test('should overwrite existing mode', () async {
        await repository.saveLastPlayedMode(GameMode.vsAi);
        await repository.saveLastPlayedMode(GameMode.twoPlayer);

        final loaded = await repository.loadLastPlayedMode();
        expect(loaded, equals(GameMode.twoPlayer));
      });
    });

    group('loadLastPlayedMode', () {
      test('should load saved vsAi mode', () async {
        await repository.saveLastPlayedMode(GameMode.vsAi);

        final loaded = await repository.loadLastPlayedMode();

        expect(loaded, equals(GameMode.vsAi));
      });

      test('should load saved twoPlayer mode', () async {
        await repository.saveLastPlayedMode(GameMode.twoPlayer);

        final loaded = await repository.loadLastPlayedMode();

        expect(loaded, equals(GameMode.twoPlayer));
      });

      test('should return null when no saved mode exists', () async {
        final loaded = await repository.loadLastPlayedMode();

        expect(loaded, isNull);
      });

      test('should return null and clean up corrupted data', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_played_game_mode', 'invalid_mode');

        final loaded = await repository.loadLastPlayedMode();

        expect(loaded, isNull);
        expect(await repository.hasLastPlayedMode(), isFalse);
      });

      test('should return null for empty string', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_played_game_mode', '');

        final loaded = await repository.loadLastPlayedMode();

        expect(loaded, isNull);
      });
    });

    group('hasLastPlayedMode', () {
      test('should return true when mode exists', () async {
        await repository.saveLastPlayedMode(GameMode.vsAi);

        final exists = await repository.hasLastPlayedMode();

        expect(exists, isTrue);
      });

      test('should return false when no mode exists', () async {
        final exists = await repository.hasLastPlayedMode();

        expect(exists, isFalse);
      });

      test('should return false after mode is deleted', () async {
        await repository.saveLastPlayedMode(GameMode.twoPlayer);
        await repository.deleteLastPlayedMode();

        final exists = await repository.hasLastPlayedMode();

        expect(exists, isFalse);
      });
    });

    group('deleteLastPlayedMode', () {
      test('should delete saved mode', () async {
        await repository.saveLastPlayedMode(GameMode.vsAi);

        await repository.deleteLastPlayedMode();

        expect(await repository.hasLastPlayedMode(), isFalse);
        expect(await repository.loadLastPlayedMode(), isNull);
      });

      test('should not throw when deleting non-existent mode', () async {
        expect(() => repository.deleteLastPlayedMode(), returnsNormally);
      });

      test('should return null after deletion', () async {
        await repository.saveLastPlayedMode(GameMode.twoPlayer);
        await repository.deleteLastPlayedMode();

        final loaded = await repository.loadLastPlayedMode();

        expect(loaded, isNull);
      });
    });

    group('Integration Tests', () {
      test('should persist all game modes correctly', () async {
        for (final mode in GameMode.values) {
          await repository.saveLastPlayedMode(mode);

          final loaded = await repository.loadLastPlayedMode();
          expect(loaded, equals(mode));
        }
      });

      test(
        'should maintain data integrity across multiple operations',
        () async {
          // Save
          await repository.saveLastPlayedMode(GameMode.vsAi);
          expect(await repository.hasLastPlayedMode(), isTrue);

          // Load
          var loaded = await repository.loadLastPlayedMode();
          expect(loaded, equals(GameMode.vsAi));

          // Update
          await repository.saveLastPlayedMode(GameMode.twoPlayer);
          loaded = await repository.loadLastPlayedMode();
          expect(loaded, equals(GameMode.twoPlayer));

          // Delete
          await repository.deleteLastPlayedMode();
          expect(await repository.hasLastPlayedMode(), isFalse);
          loaded = await repository.loadLastPlayedMode();
          expect(loaded, isNull);
        },
      );

      test('should handle rapid sequential operations', () async {
        // Rapidly save different modes
        await repository.saveLastPlayedMode(GameMode.vsAi);
        await repository.saveLastPlayedMode(GameMode.twoPlayer);
        await repository.saveLastPlayedMode(GameMode.vsAi);

        final loaded = await repository.loadLastPlayedMode();
        expect(loaded, equals(GameMode.vsAi));
      });
    });
  });
}
