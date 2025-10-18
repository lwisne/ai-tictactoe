import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/domain/models/game_config.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/domain/models/player.dart';

void main() {
  group('GameConfig', () {
    test('should create config with all fields', () {
      const config = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
        soundEnabled: true,
        vibrationEnabled: false,
      );

      expect(config.gameMode, equals(GameMode.twoPlayer));
      expect(config.firstPlayer, equals(Player.x));
      expect(config.soundEnabled, isTrue);
      expect(config.vibrationEnabled, isFalse);
    });

    test('should use default values for optional fields', () {
      const config = GameConfig(gameMode: GameMode.vsAi, firstPlayer: Player.o);

      expect(config.soundEnabled, isTrue);
      expect(config.vibrationEnabled, isTrue);
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        const config1 = GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
          soundEnabled: true,
          vibrationEnabled: false,
        );
        const config2 = GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
          soundEnabled: true,
          vibrationEnabled: false,
        );

        expect(config1, equals(config2));
      });

      test('should not be equal when gameMode differs', () {
        const config1 = GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
        );
        const config2 = GameConfig(
          gameMode: GameMode.vsAi,
          firstPlayer: Player.x,
        );

        expect(config1, isNot(equals(config2)));
      });

      test('should not be equal when firstPlayer differs', () {
        const config1 = GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
        );
        const config2 = GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.o,
        );

        expect(config1, isNot(equals(config2)));
      });

      test('should not be equal when soundEnabled differs', () {
        const config1 = GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
          soundEnabled: true,
        );
        const config2 = GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
          soundEnabled: false,
        );

        expect(config1, isNot(equals(config2)));
      });

      test('should not be equal when vibrationEnabled differs', () {
        const config1 = GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
          vibrationEnabled: true,
        );
        const config2 = GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
          vibrationEnabled: false,
        );

        expect(config1, isNot(equals(config2)));
      });
    });

    group('copyWith', () {
      const original = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
        soundEnabled: true,
        vibrationEnabled: true,
      );

      test('should create copy with updated gameMode', () {
        final updated = original.copyWith(gameMode: GameMode.vsAi);

        expect(updated.gameMode, equals(GameMode.vsAi));
        expect(updated.firstPlayer, equals(Player.x));
        expect(updated.soundEnabled, isTrue);
        expect(updated.vibrationEnabled, isTrue);
      });

      test('should create copy with updated firstPlayer', () {
        final updated = original.copyWith(firstPlayer: Player.o);

        expect(updated.gameMode, equals(GameMode.twoPlayer));
        expect(updated.firstPlayer, equals(Player.o));
        expect(updated.soundEnabled, isTrue);
        expect(updated.vibrationEnabled, isTrue);
      });

      test('should create copy with updated soundEnabled', () {
        final updated = original.copyWith(soundEnabled: false);

        expect(updated.gameMode, equals(GameMode.twoPlayer));
        expect(updated.firstPlayer, equals(Player.x));
        expect(updated.soundEnabled, isFalse);
        expect(updated.vibrationEnabled, isTrue);
      });

      test('should create copy with updated vibrationEnabled', () {
        final updated = original.copyWith(vibrationEnabled: false);

        expect(updated.gameMode, equals(GameMode.twoPlayer));
        expect(updated.firstPlayer, equals(Player.x));
        expect(updated.soundEnabled, isTrue);
        expect(updated.vibrationEnabled, isFalse);
      });

      test('should create copy with multiple updated fields', () {
        final updated = original.copyWith(
          gameMode: GameMode.vsAi,
          firstPlayer: Player.o,
          soundEnabled: false,
        );

        expect(updated.gameMode, equals(GameMode.vsAi));
        expect(updated.firstPlayer, equals(Player.o));
        expect(updated.soundEnabled, isFalse);
        expect(updated.vibrationEnabled, isTrue);
      });

      test('should return same values when no fields updated', () {
        final updated = original.copyWith();

        expect(updated, equals(original));
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        const config = GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
          soundEnabled: true,
          vibrationEnabled: false,
        );

        final json = config.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['gameMode'], equals('twoPlayer'));
        expect(json['firstPlayer'], equals('x'));
        expect(json['soundEnabled'], isTrue);
        expect(json['vibrationEnabled'], isFalse);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'gameMode': 'vsAi',
          'firstPlayer': 'o',
          'soundEnabled': false,
          'vibrationEnabled': true,
        };

        final config = GameConfig.fromJson(json);

        expect(config.gameMode, equals(GameMode.vsAi));
        expect(config.firstPlayer, equals(Player.o));
        expect(config.soundEnabled, isFalse);
        expect(config.vibrationEnabled, isTrue);
      });

      test('should use defaults for missing optional fields in JSON', () {
        final json = {'gameMode': 'twoPlayer', 'firstPlayer': 'x'};

        final config = GameConfig.fromJson(json);

        expect(config.soundEnabled, isTrue);
        expect(config.vibrationEnabled, isTrue);
      });

      test('should use defaults for invalid enum values in JSON', () {
        final json = {
          'gameMode': 'invalid',
          'firstPlayer': 'invalid',
          'soundEnabled': true,
          'vibrationEnabled': false,
        };

        final config = GameConfig.fromJson(json);

        expect(config.gameMode, equals(GameMode.twoPlayer)); // Default
        expect(config.firstPlayer, equals(Player.x)); // Default
      });

      test('should round-trip serialize and deserialize correctly', () {
        const original = GameConfig(
          gameMode: GameMode.vsAi,
          firstPlayer: Player.o,
          soundEnabled: false,
          vibrationEnabled: true,
        );

        final json = original.toJson();
        final deserialized = GameConfig.fromJson(json);

        expect(deserialized, equals(original));
      });
    });

    group('props', () {
      test('should include all fields in props for equality', () {
        const config = GameConfig(
          gameMode: GameMode.twoPlayer,
          firstPlayer: Player.x,
          soundEnabled: true,
          vibrationEnabled: false,
        );

        expect(
          config.props,
          equals([GameMode.twoPlayer, Player.x, true, false]),
        );
      });
    });
  });
}
