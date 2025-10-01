import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/models/score.dart';

void main() {
  group('Score', () {
    test('should create instance with required fields', () {
      // Arrange & Act
      const score = Score(wins: 5, losses: 3, draws: 2);

      // Assert
      expect(score.wins, equals(5));
      expect(score.losses, equals(3));
      expect(score.draws, equals(2));
    });

    test('should create instance with default values', () {
      // Arrange & Act
      const score = Score();

      // Assert
      expect(score.wins, equals(0));
      expect(score.losses, equals(0));
      expect(score.draws, equals(0));
    });

    group('copyWith', () {
      test('should update only specified fields', () {
        // Arrange
        const original = Score(wins: 5, losses: 3, draws: 2);

        // Act
        final updated = original.copyWith(wins: 10);

        // Assert
        expect(updated.wins, equals(10));
        expect(updated.losses, equals(3)); // Unchanged
        expect(updated.draws, equals(2)); // Unchanged
      });

      test('should update multiple fields', () {
        // Arrange
        const original = Score(wins: 5, losses: 3, draws: 2);

        // Act
        final updated = original.copyWith(wins: 8, draws: 5);

        // Assert
        expect(updated.wins, equals(8));
        expect(updated.losses, equals(3)); // Unchanged
        expect(updated.draws, equals(5));
      });

      test('should return same values when no fields specified', () {
        // Arrange
        const original = Score(wins: 5, losses: 3, draws: 2);

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.wins, equals(original.wins));
        expect(copy.losses, equals(original.losses));
        expect(copy.draws, equals(original.draws));
      });

      test('should allow setting fields to zero', () {
        // Arrange
        const original = Score(wins: 5, losses: 3, draws: 2);

        // Act
        final updated = original.copyWith(wins: 0, losses: 0, draws: 0);

        // Assert
        expect(updated.wins, equals(0));
        expect(updated.losses, equals(0));
        expect(updated.draws, equals(0));
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        // Arrange
        const score1 = Score(wins: 5, losses: 3, draws: 2);
        const score2 = Score(wins: 5, losses: 3, draws: 2);

        // Assert
        expect(score1, equals(score2));
        expect(score1.hashCode, equals(score2.hashCode));
      });

      test('should not be equal with different wins', () {
        // Arrange
        const score1 = Score(wins: 5, losses: 3, draws: 2);
        const score2 = Score(wins: 6, losses: 3, draws: 2);

        // Assert
        expect(score1, isNot(equals(score2)));
      });

      test('should not be equal with different losses', () {
        // Arrange
        const score1 = Score(wins: 5, losses: 3, draws: 2);
        const score2 = Score(wins: 5, losses: 4, draws: 2);

        // Assert
        expect(score1, isNot(equals(score2)));
      });

      test('should not be equal with different draws', () {
        // Arrange
        const score1 = Score(wins: 5, losses: 3, draws: 2);
        const score2 = Score(wins: 5, losses: 3, draws: 3);

        // Assert
        expect(score1, isNot(equals(score2)));
      });

      test('empty scores should be equal', () {
        // Arrange
        const score1 = Score();
        const score2 = Score();

        // Assert
        expect(score1, equals(score2));
      });
    });

    group('totalGames', () {
      test('should calculate total games correctly', () {
        // Arrange
        const score = Score(wins: 5, losses: 3, draws: 2);

        // Act
        final total = score.totalGames;

        // Assert
        expect(total, equals(10));
      });

      test('should return zero for empty score', () {
        // Arrange
        const score = Score();

        // Act
        final total = score.totalGames;

        // Assert
        expect(total, equals(0));
      });

      test('should handle large numbers', () {
        // Arrange
        const score = Score(wins: 1000, losses: 500, draws: 250);

        // Act
        final total = score.totalGames;

        // Assert
        expect(total, equals(1750));
      });
    });

    group('winRate', () {
      test('should calculate win rate correctly', () {
        // Arrange
        const score = Score(wins: 5, losses: 3, draws: 2);

        // Act
        final rate = score.winRate;

        // Assert
        expect(rate, equals(0.5)); // 5 wins out of 10 total games
      });

      test('should return zero for empty score', () {
        // Arrange
        const score = Score();

        // Act
        final rate = score.winRate;

        // Assert
        expect(rate, equals(0.0));
      });

      test('should calculate 100% win rate', () {
        // Arrange
        const score = Score(wins: 10, losses: 0, draws: 0);

        // Act
        final rate = score.winRate;

        // Assert
        expect(rate, equals(1.0));
      });

      test('should calculate 0% win rate', () {
        // Arrange
        const score = Score(wins: 0, losses: 10, draws: 0);

        // Act
        final rate = score.winRate;

        // Assert
        expect(rate, equals(0.0));
      });

      test('should handle draws in win rate calculation', () {
        // Arrange
        const score = Score(wins: 3, losses: 2, draws: 5);

        // Act
        final rate = score.winRate;

        // Assert
        expect(rate, equals(0.3)); // 3 wins out of 10 total games
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON', () {
        // Arrange
        const score = Score(wins: 5, losses: 3, draws: 2);

        // Act
        final json = score.toJson();

        // Assert
        expect(json['wins'], equals(5));
        expect(json['losses'], equals(3));
        expect(json['draws'], equals(2));
      });

      test('should serialize empty score to JSON', () {
        // Arrange
        const score = Score();

        // Act
        final json = score.toJson();

        // Assert
        expect(json['wins'], equals(0));
        expect(json['losses'], equals(0));
        expect(json['draws'], equals(0));
      });

      test('should deserialize from JSON', () {
        // Arrange
        final json = {
          'wins': 5,
          'losses': 3,
          'draws': 2,
        };

        // Act
        final score = Score.fromJson(json);

        // Assert
        expect(score.wins, equals(5));
        expect(score.losses, equals(3));
        expect(score.draws, equals(2));
      });

      test('should deserialize from JSON with missing fields', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final score = Score.fromJson(json);

        // Assert
        expect(score.wins, equals(0));
        expect(score.losses, equals(0));
        expect(score.draws, equals(0));
      });

      test('should deserialize from JSON with null values', () {
        // Arrange
        final json = {
          'wins': null,
          'losses': null,
          'draws': null,
        };

        // Act
        final score = Score.fromJson(json);

        // Assert
        expect(score.wins, equals(0));
        expect(score.losses, equals(0));
        expect(score.draws, equals(0));
      });

      test('should round-trip serialize and deserialize', () {
        // Arrange
        const original = Score(wins: 10, losses: 5, draws: 3);

        // Act
        final json = original.toJson();
        final restored = Score.fromJson(json);

        // Assert
        expect(restored, equals(original));
        expect(restored.wins, equals(original.wins));
        expect(restored.losses, equals(original.losses));
        expect(restored.draws, equals(original.draws));
      });

      test('should handle large numbers in JSON', () {
        // Arrange
        const score = Score(wins: 999, losses: 888, draws: 777);

        // Act
        final json = score.toJson();
        final restored = Score.fromJson(json);

        // Assert
        expect(restored, equals(score));
        expect(restored.totalGames, equals(2664));
      });
    });

    group('props', () {
      test('should return correct properties for equality', () {
        // Arrange
        const score = Score(wins: 5, losses: 3, draws: 2);

        // Act
        final props = score.props;

        // Assert
        expect(props, equals([5, 3, 2]));
      });
    });
  });
}
