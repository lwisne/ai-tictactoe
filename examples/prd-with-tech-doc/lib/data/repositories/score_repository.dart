import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/score.dart';
import '../models/score_model.dart';

/// Repository for Score persistence
///
/// Responsibilities:
/// - Convert between domain entities (Score) and data models (ScoreModel)
/// - Handle persistence using SharedPreferences
/// - Manage serialization/deserialization
class ScoreRepository {
  static const String _scoreKey = 'score';

  /// Loads the score from persistent storage
  ///
  /// Returns a domain Score entity by:
  /// 1. Loading individual values from SharedPreferences
  /// 2. Creating ScoreModel from values
  /// 3. Converting ScoreModel to Score entity
  Future<Score> loadScore() async {
    final prefs = await SharedPreferences.getInstance();

    // Load individual keys
    final wins = prefs.getInt('wins') ?? 0;
    final losses = prefs.getInt('losses') ?? 0;
    final draws = prefs.getInt('draws') ?? 0;

    final model = ScoreModel(
      wins: wins,
      losses: losses,
      draws: draws,
    );

    return model.toEntity();
  }

  /// Saves the score to persistent storage
  ///
  /// Converts domain entity to data model, then persists:
  /// 1. Convert Score entity to ScoreModel
  /// 2. Serialize ScoreModel to JSON
  /// 3. Save to SharedPreferences
  Future<void> saveScore(Score score) async {
    final prefs = await SharedPreferences.getInstance();
    final model = ScoreModel.fromEntity(score);

    // Store as individual keys for simplicity
    // In a real app, we'd serialize to JSON string
    await prefs.setInt('wins', model.wins);
    await prefs.setInt('losses', model.losses);
    await prefs.setInt('draws', model.draws);
  }

  /// Resets the score to zero
  Future<void> resetScore() async {
    await saveScore(const Score());
  }

  /// Increments wins and saves
  Future<Score> incrementWins(Score currentScore) async {
    final newScore = currentScore.copyWith(wins: currentScore.wins + 1);
    await saveScore(newScore);
    return newScore;
  }

  /// Increments losses and saves
  Future<Score> incrementLosses(Score currentScore) async {
    final newScore = currentScore.copyWith(losses: currentScore.losses + 1);
    await saveScore(newScore);
    return newScore;
  }

  /// Increments draws and saves
  Future<Score> incrementDraws(Score currentScore) async {
    final newScore = currentScore.copyWith(draws: currentScore.draws + 1);
    await saveScore(newScore);
    return newScore;
  }
}
