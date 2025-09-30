import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/data/repositories/score_repository.dart';
import 'package:tic_tac_toe/domain/models/score.dart';

void main() {
  group('ScoreRepository Integration Tests', () {
    late ScoreRepository repository;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      repository = ScoreRepository();
    });

    group('loadScore', () {
      test('should return empty score when no data exists', () async {
        // Act
        final score = await repository.loadScore();

        // Assert
        expect(score.wins, equals(0));
        expect(score.losses, equals(0));
        expect(score.draws, equals(0));
      });

      test('should load previously saved score', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('wins', 5);
        await prefs.setInt('losses', 3);
        await prefs.setInt('draws', 2);

        // Act
        final score = await repository.loadScore();

        // Assert
        expect(score.wins, equals(5));
        expect(score.losses, equals(3));
        expect(score.draws, equals(2));
      });

      test('should handle missing individual fields', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('wins', 5);
        // losses and draws not set

        // Act
        final score = await repository.loadScore();

        // Assert
        expect(score.wins, equals(5));
        expect(score.losses, equals(0));
        expect(score.draws, equals(0));
      });
    });

    group('saveScore', () {
      test('should persist score to SharedPreferences', () async {
        // Arrange
        const score = Score(wins: 10, losses: 5, draws: 3);

        // Act
        await repository.saveScore(score);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('wins'), equals(10));
        expect(prefs.getInt('losses'), equals(5));
        expect(prefs.getInt('draws'), equals(3));
      });

      test('should overwrite existing score', () async {
        // Arrange
        await repository.saveScore(const Score(wins: 1, losses: 2, draws: 3));

        // Act
        await repository.saveScore(const Score(wins: 10, losses: 20, draws: 30));

        // Assert
        final loaded = await repository.loadScore();
        expect(loaded.wins, equals(10));
        expect(loaded.losses, equals(20));
        expect(loaded.draws, equals(30));
      });

      test('should save empty score', () async {
        // Arrange
        const score = Score();

        // Act
        await repository.saveScore(score);

        // Assert
        final loaded = await repository.loadScore();
        expect(loaded.wins, equals(0));
        expect(loaded.losses, equals(0));
        expect(loaded.draws, equals(0));
      });

      test('should save large numbers', () async {
        // Arrange
        const score = Score(wins: 999, losses: 888, draws: 777);

        // Act
        await repository.saveScore(score);

        // Assert
        final loaded = await repository.loadScore();
        expect(loaded.wins, equals(999));
        expect(loaded.losses, equals(888));
        expect(loaded.draws, equals(777));
      });

      test('should round-trip save and load preserving all data', () async {
        // Arrange
        const original = Score(wins: 42, losses: 13, draws: 7);

        // Act
        await repository.saveScore(original);
        final restored = await repository.loadScore();

        // Assert
        expect(restored, equals(original));
        expect(restored.wins, equals(original.wins));
        expect(restored.losses, equals(original.losses));
        expect(restored.draws, equals(original.draws));
      });
    });

    group('incrementWins', () {
      test('should increment wins from zero', () async {
        // Arrange
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementWins(currentScore);

        // Assert
        expect(newScore.wins, equals(1));
        expect(newScore.losses, equals(0));
        expect(newScore.draws, equals(0));

        final loaded = await repository.loadScore();
        expect(loaded.wins, equals(1));
      });

      test('should increment wins from existing score', () async {
        // Arrange
        await repository.saveScore(const Score(wins: 5, losses: 3, draws: 2));
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementWins(currentScore);

        // Assert
        expect(newScore.wins, equals(6));
        expect(newScore.losses, equals(3));
        expect(newScore.draws, equals(2));

        final loaded = await repository.loadScore();
        expect(loaded.wins, equals(6));
      });

      test('should increment wins multiple times', () async {
        // Act
        var score = await repository.loadScore();
        score = await repository.incrementWins(score);
        score = await repository.incrementWins(score);
        score = await repository.incrementWins(score);

        // Assert
        expect(score.wins, equals(3));

        final loaded = await repository.loadScore();
        expect(loaded.wins, equals(3));
      });

      test('should not affect losses or draws', () async {
        // Arrange
        await repository.saveScore(const Score(wins: 1, losses: 2, draws: 3));
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementWins(currentScore);

        // Assert
        expect(newScore.wins, equals(2));
        expect(newScore.losses, equals(2));
        expect(newScore.draws, equals(3));
      });

      test('should return updated score', () async {
        // Arrange
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementWins(currentScore);

        // Assert
        expect(newScore.wins, equals(currentScore.wins + 1));
        expect(newScore, isNot(equals(currentScore)));
      });
    });

    group('incrementLosses', () {
      test('should increment losses from zero', () async {
        // Arrange
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementLosses(currentScore);

        // Assert
        expect(newScore.wins, equals(0));
        expect(newScore.losses, equals(1));
        expect(newScore.draws, equals(0));

        final loaded = await repository.loadScore();
        expect(loaded.losses, equals(1));
      });

      test('should increment losses from existing score', () async {
        // Arrange
        await repository.saveScore(const Score(wins: 5, losses: 3, draws: 2));
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementLosses(currentScore);

        // Assert
        expect(newScore.wins, equals(5));
        expect(newScore.losses, equals(4));
        expect(newScore.draws, equals(2));

        final loaded = await repository.loadScore();
        expect(loaded.losses, equals(4));
      });

      test('should increment losses multiple times', () async {
        // Act
        var score = await repository.loadScore();
        score = await repository.incrementLosses(score);
        score = await repository.incrementLosses(score);
        score = await repository.incrementLosses(score);

        // Assert
        expect(score.losses, equals(3));

        final loaded = await repository.loadScore();
        expect(loaded.losses, equals(3));
      });

      test('should not affect wins or draws', () async {
        // Arrange
        await repository.saveScore(const Score(wins: 1, losses: 2, draws: 3));
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementLosses(currentScore);

        // Assert
        expect(newScore.wins, equals(1));
        expect(newScore.losses, equals(3));
        expect(newScore.draws, equals(3));
      });

      test('should return updated score', () async {
        // Arrange
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementLosses(currentScore);

        // Assert
        expect(newScore.losses, equals(currentScore.losses + 1));
        expect(newScore, isNot(equals(currentScore)));
      });
    });

    group('incrementDraws', () {
      test('should increment draws from zero', () async {
        // Arrange
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementDraws(currentScore);

        // Assert
        expect(newScore.wins, equals(0));
        expect(newScore.losses, equals(0));
        expect(newScore.draws, equals(1));

        final loaded = await repository.loadScore();
        expect(loaded.draws, equals(1));
      });

      test('should increment draws from existing score', () async {
        // Arrange
        await repository.saveScore(const Score(wins: 5, losses: 3, draws: 2));
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementDraws(currentScore);

        // Assert
        expect(newScore.wins, equals(5));
        expect(newScore.losses, equals(3));
        expect(newScore.draws, equals(3));

        final loaded = await repository.loadScore();
        expect(loaded.draws, equals(3));
      });

      test('should increment draws multiple times', () async {
        // Act
        var score = await repository.loadScore();
        score = await repository.incrementDraws(score);
        score = await repository.incrementDraws(score);
        score = await repository.incrementDraws(score);

        // Assert
        expect(score.draws, equals(3));

        final loaded = await repository.loadScore();
        expect(loaded.draws, equals(3));
      });

      test('should not affect wins or losses', () async {
        // Arrange
        await repository.saveScore(const Score(wins: 1, losses: 2, draws: 3));
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementDraws(currentScore);

        // Assert
        expect(newScore.wins, equals(1));
        expect(newScore.losses, equals(2));
        expect(newScore.draws, equals(4));
      });

      test('should return updated score', () async {
        // Arrange
        final currentScore = await repository.loadScore();

        // Act
        final newScore = await repository.incrementDraws(currentScore);

        // Assert
        expect(newScore.draws, equals(currentScore.draws + 1));
        expect(newScore, isNot(equals(currentScore)));
      });
    });

    group('resetScore', () {
      test('should reset non-empty score to zero', () async {
        // Arrange
        await repository.saveScore(const Score(wins: 10, losses: 5, draws: 3));

        // Act
        await repository.resetScore();

        // Assert
        final score = await repository.loadScore();
        expect(score.wins, equals(0));
        expect(score.losses, equals(0));
        expect(score.draws, equals(0));
      });

      test('should reset already empty score', () async {
        // Arrange
        await repository.saveScore(const Score());

        // Act
        await repository.resetScore();

        // Assert
        final score = await repository.loadScore();
        expect(score.wins, equals(0));
        expect(score.losses, equals(0));
        expect(score.draws, equals(0));
      });

      test('should persist reset across repository instances', () async {
        // Arrange
        await repository.saveScore(const Score(wins: 100, losses: 50, draws: 25));

        // Act
        await repository.resetScore();

        // Assert
        final newRepository = ScoreRepository();
        final score = await newRepository.loadScore();
        expect(score.wins, equals(0));
        expect(score.losses, equals(0));
        expect(score.draws, equals(0));
      });

      test('should allow incrementing after reset', () async {
        // Arrange
        await repository.saveScore(const Score(wins: 5, losses: 3, draws: 2));

        // Act
        await repository.resetScore();
        var score = await repository.loadScore();
        score = await repository.incrementWins(score);

        // Assert
        expect(score.wins, equals(1));
        expect(score.losses, equals(0));
        expect(score.draws, equals(0));
      });
    });

    group('complex scenarios', () {
      test('should handle multiple operations in sequence', () async {
        // Arrange & Act
        var score = await repository.loadScore();
        score = await repository.incrementWins(score);
        score = await repository.incrementWins(score);
        score = await repository.incrementLosses(score);
        score = await repository.incrementDraws(score);
        score = await repository.incrementWins(score);

        // Assert
        expect(score.wins, equals(3));
        expect(score.losses, equals(1));
        expect(score.draws, equals(1));

        final loaded = await repository.loadScore();
        expect(loaded, equals(score));
      });

      test('should maintain consistency across multiple instances', () async {
        // Arrange
        final repo1 = ScoreRepository();
        final repo2 = ScoreRepository();

        // Act
        var score1 = await repo1.loadScore();
        score1 = await repo1.incrementWins(score1);

        var score2 = await repo2.loadScore();
        score2 = await repo2.incrementLosses(score2);

        // Assert
        final finalScore1 = await repo1.loadScore();
        final finalScore2 = await repo2.loadScore();
        expect(finalScore1.wins, equals(1));
        expect(finalScore1.losses, equals(1));
        expect(finalScore2, equals(finalScore1));
      });

      test('should handle save after increments', () async {
        // Arrange & Act
        var score = await repository.loadScore();
        score = await repository.incrementWins(score);
        score = await repository.incrementWins(score);
        await repository.saveScore(const Score(wins: 100, losses: 50, draws: 25));

        // Assert
        final loaded = await repository.loadScore();
        expect(loaded.wins, equals(100));
        expect(loaded.losses, equals(50));
        expect(loaded.draws, equals(25));
      });
    });
  });
}
