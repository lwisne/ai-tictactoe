import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/models/difficulty_level.dart';
import 'package:tic_tac_toe/domain/models/game_config.dart';
import 'package:tic_tac_toe/domain/models/game_mode.dart';
import 'package:tic_tac_toe/domain/models/player.dart';

void main() {
  group('GameConfig', () {
    test('should create instance with required fields', () {
      const config = GameConfig(
        gameMode: GameMode.singlePlayer,
        difficultyLevel: DifficultyLevel.medium,
        firstPlayer: Player.x,
      );

      expect(config.gameMode, equals(GameMode.singlePlayer));
      expect(config.difficultyLevel, equals(DifficultyLevel.medium));
      expect(config.firstPlayer, equals(Player.x));
      expect(config.soundEnabled, isTrue);
      expect(config.vibrationEnabled, isTrue);
    });

    test('should create instance with custom settings', () {
      const config = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.o,
        soundEnabled: false,
        vibrationEnabled: false,
      );

      expect(config.gameMode, equals(GameMode.twoPlayer));
      expect(config.difficultyLevel, isNull);
      expect(config.firstPlayer, equals(Player.o));
      expect(config.soundEnabled, isFalse);
      expect(config.vibrationEnabled, isFalse);
    });

    test('copyWith should update only specified fields', () {
      const config = GameConfig(
        gameMode: GameMode.singlePlayer,
        difficultyLevel: DifficultyLevel.easy,
        firstPlayer: Player.x,
      );

      final updated = config.copyWith(
        difficultyLevel: DifficultyLevel.hard,
        soundEnabled: false,
      );

      expect(updated.difficultyLevel, equals(DifficultyLevel.hard));
      expect(updated.soundEnabled, isFalse);
      expect(updated.gameMode, equals(config.gameMode));
      expect(updated.firstPlayer, equals(config.firstPlayer));
      expect(updated.vibrationEnabled, equals(config.vibrationEnabled));
    });

    test('should serialize to JSON', () {
      const config = GameConfig(
        gameMode: GameMode.singlePlayer,
        difficultyLevel: DifficultyLevel.medium,
        firstPlayer: Player.x,
        soundEnabled: true,
        vibrationEnabled: false,
      );

      final json = config.toJson();

      expect(json['gameMode'], equals('singlePlayer'));
      expect(json['difficultyLevel'], equals('medium'));
      expect(json['firstPlayer'], equals('x'));
      expect(json['soundEnabled'], isTrue);
      expect(json['vibrationEnabled'], isFalse);
    });

    test('should serialize to JSON without difficulty level', () {
      const config = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.o,
      );

      final json = config.toJson();

      expect(json['gameMode'], equals('twoPlayer'));
      expect(json['difficultyLevel'], isNull);
      expect(json['firstPlayer'], equals('o'));
    });

    test('should deserialize from JSON', () {
      final json = {
        'gameMode': 'singlePlayer',
        'difficultyLevel': 'hard',
        'firstPlayer': 'o',
        'soundEnabled': false,
        'vibrationEnabled': true,
      };

      final config = GameConfig.fromJson(json);

      expect(config.gameMode, equals(GameMode.singlePlayer));
      expect(config.difficultyLevel, equals(DifficultyLevel.hard));
      expect(config.firstPlayer, equals(Player.o));
      expect(config.soundEnabled, isFalse);
      expect(config.vibrationEnabled, isTrue);
    });

    test('should deserialize from JSON with null difficulty', () {
      final json = {
        'gameMode': 'twoPlayer',
        'difficultyLevel': null,
        'firstPlayer': 'x',
        'soundEnabled': true,
        'vibrationEnabled': true,
      };

      final config = GameConfig.fromJson(json);

      expect(config.gameMode, equals(GameMode.twoPlayer));
      expect(config.difficultyLevel, isNull);
      expect(config.firstPlayer, equals(Player.x));
    });

    test('should use default values for missing optional fields', () {
      final json = {
        'gameMode': 'singlePlayer',
        'difficultyLevel': 'easy',
        'firstPlayer': 'x',
      };

      final config = GameConfig.fromJson(json);

      expect(config.soundEnabled, isTrue);
      expect(config.vibrationEnabled, isTrue);
    });

    test('should correctly convert GameMode enum to string', () {
      const single = GameConfig(
        gameMode: GameMode.singlePlayer,
        firstPlayer: Player.x,
      );
      expect(single.toJson()['gameMode'], equals('singlePlayer'));

      const two = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      expect(two.toJson()['gameMode'], equals('twoPlayer'));
    });

    test('should correctly convert string to GameMode enum', () {
      final single = GameConfig.fromJson({
        'gameMode': 'singlePlayer',
        'difficultyLevel': null,
        'firstPlayer': 'x',
        'soundEnabled': true,
        'vibrationEnabled': true,
      });
      expect(single.gameMode, equals(GameMode.singlePlayer));

      final two = GameConfig.fromJson({
        'gameMode': 'twoPlayer',
        'difficultyLevel': null,
        'firstPlayer': 'x',
        'soundEnabled': true,
        'vibrationEnabled': true,
      });
      expect(two.gameMode, equals(GameMode.twoPlayer));
    });

    test('should use default for invalid GameMode string', () {
      final config = GameConfig.fromJson({
        'gameMode': 'invalid',
        'difficultyLevel': null,
        'firstPlayer': 'x',
        'soundEnabled': true,
        'vibrationEnabled': true,
      });
      expect(config.gameMode, equals(GameMode.singlePlayer));
    });

    test('should correctly convert DifficultyLevel enum to string', () {
      const easy = GameConfig(
        gameMode: GameMode.singlePlayer,
        difficultyLevel: DifficultyLevel.easy,
        firstPlayer: Player.x,
      );
      expect(easy.toJson()['difficultyLevel'], equals('easy'));

      const medium = GameConfig(
        gameMode: GameMode.singlePlayer,
        difficultyLevel: DifficultyLevel.medium,
        firstPlayer: Player.x,
      );
      expect(medium.toJson()['difficultyLevel'], equals('medium'));

      const hard = GameConfig(
        gameMode: GameMode.singlePlayer,
        difficultyLevel: DifficultyLevel.hard,
        firstPlayer: Player.x,
      );
      expect(hard.toJson()['difficultyLevel'], equals('hard'));
    });

    test('should correctly convert string to DifficultyLevel enum', () {
      final easy = GameConfig.fromJson({
        'gameMode': 'singlePlayer',
        'difficultyLevel': 'easy',
        'firstPlayer': 'x',
        'soundEnabled': true,
        'vibrationEnabled': true,
      });
      expect(easy.difficultyLevel, equals(DifficultyLevel.easy));

      final medium = GameConfig.fromJson({
        'gameMode': 'singlePlayer',
        'difficultyLevel': 'medium',
        'firstPlayer': 'x',
        'soundEnabled': true,
        'vibrationEnabled': true,
      });
      expect(medium.difficultyLevel, equals(DifficultyLevel.medium));

      final hard = GameConfig.fromJson({
        'gameMode': 'singlePlayer',
        'difficultyLevel': 'hard',
        'firstPlayer': 'x',
        'soundEnabled': true,
        'vibrationEnabled': true,
      });
      expect(hard.difficultyLevel, equals(DifficultyLevel.hard));
    });

    test('should use default for invalid DifficultyLevel string', () {
      final config = GameConfig.fromJson({
        'gameMode': 'singlePlayer',
        'difficultyLevel': 'invalid',
        'firstPlayer': 'x',
        'soundEnabled': true,
        'vibrationEnabled': true,
      });
      expect(config.difficultyLevel, equals(DifficultyLevel.easy));
    });

    test('should correctly convert Player enum to string', () {
      const configX = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      expect(configX.toJson()['firstPlayer'], equals('x'));

      const configO = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.o,
      );
      expect(configO.toJson()['firstPlayer'], equals('o'));
    });

    test('should correctly convert string to Player enum', () {
      final configX = GameConfig.fromJson({
        'gameMode': 'twoPlayer',
        'difficultyLevel': null,
        'firstPlayer': 'x',
        'soundEnabled': true,
        'vibrationEnabled': true,
      });
      expect(configX.firstPlayer, equals(Player.x));

      final configO = GameConfig.fromJson({
        'gameMode': 'twoPlayer',
        'difficultyLevel': null,
        'firstPlayer': 'o',
        'soundEnabled': true,
        'vibrationEnabled': true,
      });
      expect(configO.firstPlayer, equals(Player.o));
    });

    test('should use default for invalid Player string', () {
      final config = GameConfig.fromJson({
        'gameMode': 'twoPlayer',
        'difficultyLevel': null,
        'firstPlayer': 'invalid',
        'soundEnabled': true,
        'vibrationEnabled': true,
      });
      expect(config.firstPlayer, equals(Player.none));
    });

    test('equality should work correctly', () {
      const config1 = GameConfig(
        gameMode: GameMode.singlePlayer,
        difficultyLevel: DifficultyLevel.medium,
        firstPlayer: Player.x,
      );

      const config2 = GameConfig(
        gameMode: GameMode.singlePlayer,
        difficultyLevel: DifficultyLevel.medium,
        firstPlayer: Player.x,
      );

      const config3 = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('round-trip serialization should preserve all fields', () {
      const original = GameConfig(
        gameMode: GameMode.singlePlayer,
        difficultyLevel: DifficultyLevel.hard,
        firstPlayer: Player.o,
        soundEnabled: false,
        vibrationEnabled: true,
      );

      final json = original.toJson();
      final restored = GameConfig.fromJson(json);

      expect(restored, equals(original));
      expect(restored.gameMode, equals(original.gameMode));
      expect(restored.difficultyLevel, equals(original.difficultyLevel));
      expect(restored.firstPlayer, equals(original.firstPlayer));
      expect(restored.soundEnabled, equals(original.soundEnabled));
      expect(restored.vibrationEnabled, equals(original.vibrationEnabled));
    });
  });
}
