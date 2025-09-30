import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/data/repositories/score_repository.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';

void main() {
  late ScoreRepository repository;

  setUp(() {
    repository = ScoreRepository();
  });

  group('ScoreRepository', () {
    group('loadScore', () {
      test('should return empty score when no data saved', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await repository.loadScore();

        // Assert
        expect(result, equals(const Score()));
        expect(result.wins, equals(0));
        expect(result.losses, equals(0));
        expect(result.draws, equals(0));
      });

      test('should load score from SharedPreferences', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'wins': 10,
          'losses': 5,
          'draws': 3,
        });

        // Act
        final result = await repository.loadScore();

        // Assert
        expect(result.wins, equals(10));
        expect(result.losses, equals(5));
        expect(result.draws, equals(3));
      });

      test('should handle partial data', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'wins': 7,
          // losses and draws not set
        });

        // Act
        final result = await repository.loadScore();

        // Assert
        expect(result.wins, equals(7));
        expect(result.losses, equals(0));
        expect(result.draws, equals(0));
      });
    });

    group('saveScore', () {
      test('should save score to SharedPreferences', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final score = const Score(wins: 8, losses: 4, draws: 2);

        // Act
        await repository.saveScore(score);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('wins'), equals(8));
        expect(prefs.getInt('losses'), equals(4));
        expect(prefs.getInt('draws'), equals(2));
      });

      test('should overwrite existing score', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'wins': 5,
          'losses': 3,
          'draws': 1,
        });
        final newScore = const Score(wins: 12, losses: 7, draws: 4);

        // Act
        await repository.saveScore(newScore);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('wins'), equals(12));
        expect(prefs.getInt('losses'), equals(7));
        expect(prefs.getInt('draws'), equals(4));
      });

      test('should save zero values', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'wins': 10,
          'losses': 5,
          'draws': 3,
        });
        const zeroScore = Score();

        // Act
        await repository.saveScore(zeroScore);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('wins'), equals(0));
        expect(prefs.getInt('losses'), equals(0));
        expect(prefs.getInt('draws'), equals(0));
      });
    });

    group('resetScore', () {
      test('should reset score to zero', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'wins': 20,
          'losses': 15,
          'draws': 10,
        });

        // Act
        await repository.resetScore();

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('wins'), equals(0));
        expect(prefs.getInt('losses'), equals(0));
        expect(prefs.getInt('draws'), equals(0));
      });

      test('should work when no previous data exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        await repository.resetScore();

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('wins'), equals(0));
        expect(prefs.getInt('losses'), equals(0));
        expect(prefs.getInt('draws'), equals(0));
      });
    });

    group('incrementWins', () {
      test('should increment wins and save', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        const currentScore = Score(wins: 5, losses: 3, draws: 2);

        // Act
        final result = await repository.incrementWins(currentScore);

        // Assert
        expect(result.wins, equals(6));
        expect(result.losses, equals(3));
        expect(result.draws, equals(2));

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('wins'), equals(6));
        expect(prefs.getInt('losses'), equals(3));
        expect(prefs.getInt('draws'), equals(2));
      });

      test('should increment from zero', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        const currentScore = Score();

        // Act
        final result = await repository.incrementWins(currentScore);

        // Assert
        expect(result.wins, equals(1));
        expect(result.losses, equals(0));
        expect(result.draws, equals(0));
      });
    });

    group('incrementLosses', () {
      test('should increment losses and save', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        const currentScore = Score(wins: 5, losses: 3, draws: 2);

        // Act
        final result = await repository.incrementLosses(currentScore);

        // Assert
        expect(result.wins, equals(5));
        expect(result.losses, equals(4));
        expect(result.draws, equals(2));

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('wins'), equals(5));
        expect(prefs.getInt('losses'), equals(4));
        expect(prefs.getInt('draws'), equals(2));
      });

      test('should increment from zero', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        const currentScore = Score();

        // Act
        final result = await repository.incrementLosses(currentScore);

        // Assert
        expect(result.wins, equals(0));
        expect(result.losses, equals(1));
        expect(result.draws, equals(0));
      });
    });

    group('incrementDraws', () {
      test('should increment draws and save', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        const currentScore = Score(wins: 5, losses: 3, draws: 2);

        // Act
        final result = await repository.incrementDraws(currentScore);

        // Assert
        expect(result.wins, equals(5));
        expect(result.losses, equals(3));
        expect(result.draws, equals(3));

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('wins'), equals(5));
        expect(prefs.getInt('losses'), equals(3));
        expect(prefs.getInt('draws'), equals(3));
      });

      test('should increment from zero', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        const currentScore = Score();

        // Act
        final result = await repository.incrementDraws(currentScore);

        // Assert
        expect(result.wins, equals(0));
        expect(result.losses, equals(0));
        expect(result.draws, equals(1));
      });
    });

    group('Integration scenarios', () {
      test('should handle multiple increments correctly', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        var score = const Score();

        // Act & Assert
        score = await repository.incrementWins(score);
        expect(score.wins, equals(1));

        score = await repository.incrementWins(score);
        expect(score.wins, equals(2));

        score = await repository.incrementLosses(score);
        expect(score.losses, equals(1));

        score = await repository.incrementDraws(score);
        expect(score.draws, equals(1));

        // Verify persistence
        final loadedScore = await repository.loadScore();
        expect(loadedScore.wins, equals(2));
        expect(loadedScore.losses, equals(1));
        expect(loadedScore.draws, equals(1));
      });

      test('should persist score across load operations', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        await repository.saveScore(const Score(wins: 10, losses: 5, draws: 3));

        final loaded1 = await repository.loadScore();
        final loaded2 = await repository.loadScore();

        // Assert
        expect(loaded1, equals(loaded2));
        expect(loaded1.wins, equals(10));
        expect(loaded1.losses, equals(5));
        expect(loaded1.draws, equals(3));
      });

      test('should reset after increments', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        var score = const Score();

        // Act
        score = await repository.incrementWins(score);
        score = await repository.incrementLosses(score);
        score = await repository.incrementDraws(score);

        await repository.resetScore();

        final loadedScore = await repository.loadScore();

        // Assert
        expect(loadedScore, equals(const Score()));
      });
    });
  });
}
