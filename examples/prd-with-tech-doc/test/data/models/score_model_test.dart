import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/data/models/score_model.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';

void main() {
  group('ScoreModel', () {
    group('fromJson', () {
      test('should create ScoreModel from valid JSON', () {
        // Arrange
        final json = {
          'wins': 10,
          'losses': 5,
          'draws': 3,
        };

        // Act
        final model = ScoreModel.fromJson(json);

        // Assert
        expect(model.wins, equals(10));
        expect(model.losses, equals(5));
        expect(model.draws, equals(3));
      });

      test('should use default values for missing fields', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final model = ScoreModel.fromJson(json);

        // Assert
        expect(model.wins, equals(0));
        expect(model.losses, equals(0));
        expect(model.draws, equals(0));
      });

      test('should handle partial JSON', () {
        // Arrange
        final json = {
          'wins': 7,
        };

        // Act
        final model = ScoreModel.fromJson(json);

        // Assert
        expect(model.wins, equals(7));
        expect(model.losses, equals(0));
        expect(model.draws, equals(0));
      });

      test('should handle null values', () {
        // Arrange
        final json = {
          'wins': null,
          'losses': null,
          'draws': null,
        };

        // Act
        final model = ScoreModel.fromJson(json);

        // Assert
        expect(model.wins, equals(0));
        expect(model.losses, equals(0));
        expect(model.draws, equals(0));
      });
    });

    group('toJson', () {
      test('should convert ScoreModel to JSON', () {
        // Arrange
        const model = ScoreModel(
          wins: 12,
          losses: 7,
          draws: 4,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['wins'], equals(12));
        expect(json['losses'], equals(7));
        expect(json['draws'], equals(4));
      });

      test('should convert zero values to JSON', () {
        // Arrange
        const model = ScoreModel(
          wins: 0,
          losses: 0,
          draws: 0,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['wins'], equals(0));
        expect(json['losses'], equals(0));
        expect(json['draws'], equals(0));
      });
    });

    group('fromEntity', () {
      test('should create ScoreModel from Score entity', () {
        // Arrange
        const score = Score(wins: 8, losses: 4, draws: 2);

        // Act
        final model = ScoreModel.fromEntity(score);

        // Assert
        expect(model.wins, equals(8));
        expect(model.losses, equals(4));
        expect(model.draws, equals(2));
      });

      test('should create ScoreModel from empty Score entity', () {
        // Arrange
        const score = Score();

        // Act
        final model = ScoreModel.fromEntity(score);

        // Assert
        expect(model.wins, equals(0));
        expect(model.losses, equals(0));
        expect(model.draws, equals(0));
      });
    });

    group('toEntity', () {
      test('should convert ScoreModel to Score entity', () {
        // Arrange
        const model = ScoreModel(
          wins: 15,
          losses: 8,
          draws: 5,
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.wins, equals(15));
        expect(entity.losses, equals(8));
        expect(entity.draws, equals(5));
      });

      test('should convert zero values to Score entity', () {
        // Arrange
        const model = ScoreModel(
          wins: 0,
          losses: 0,
          draws: 0,
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.wins, equals(0));
        expect(entity.losses, equals(0));
        expect(entity.draws, equals(0));
      });

      test('should create Score entity with computed properties', () {
        // Arrange
        const model = ScoreModel(
          wins: 10,
          losses: 5,
          draws: 5,
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.totalGames, equals(20));
        expect(entity.winRate, equals(0.5));
      });
    });

    group('empty', () {
      test('should create empty ScoreModel', () {
        // Act
        final model = ScoreModel.empty();

        // Assert
        expect(model.wins, equals(0));
        expect(model.losses, equals(0));
        expect(model.draws, equals(0));
      });
    });

    group('JSON round-trip', () {
      test('should maintain data through JSON serialization round-trip', () {
        // Arrange
        const original = ScoreModel(
          wins: 20,
          losses: 10,
          draws: 5,
        );

        // Act
        final json = original.toJson();
        final restored = ScoreModel.fromJson(json);

        // Assert
        expect(restored.wins, equals(original.wins));
        expect(restored.losses, equals(original.losses));
        expect(restored.draws, equals(original.draws));
      });
    });

    group('Entity conversion round-trip', () {
      test('should maintain data through entity conversion round-trip', () {
        // Arrange
        const originalEntity = Score(wins: 25, losses: 15, draws: 10);

        // Act
        final model = ScoreModel.fromEntity(originalEntity);
        final restoredEntity = model.toEntity();

        // Assert
        expect(restoredEntity.wins, equals(originalEntity.wins));
        expect(restoredEntity.losses, equals(originalEntity.losses));
        expect(restoredEntity.draws, equals(originalEntity.draws));
      });
    });

    group('Integration scenarios', () {
      test('should handle full workflow: Entity -> Model -> JSON -> Model -> Entity', () {
        // Arrange
        const originalEntity = Score(wins: 30, losses: 20, draws: 15);

        // Act
        final model1 = ScoreModel.fromEntity(originalEntity);
        final json = model1.toJson();
        final model2 = ScoreModel.fromJson(json);
        final finalEntity = model2.toEntity();

        // Assert
        expect(finalEntity.wins, equals(originalEntity.wins));
        expect(finalEntity.losses, equals(originalEntity.losses));
        expect(finalEntity.draws, equals(originalEntity.draws));
        expect(finalEntity.totalGames, equals(originalEntity.totalGames));
        expect(finalEntity.winRate, equals(originalEntity.winRate));
      });
    });
  });
}
