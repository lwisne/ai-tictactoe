import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/score.dart';

/// Repository for Score persistence
///
/// Responsibilities:
/// - Handle persistence using SharedPreferences
/// - Manage serialization/deserialization
class ScoreRepository {
  static const String _scoreKey = 'score';

  /// Loads the score from persistent storage
  Future<Score> loadScore() async {
    final prefs = await SharedPreferences.getInstance();

    // Load individual keys
    final wins = prefs.getInt('wins') ?? 0;
    final losses = prefs.getInt('losses') ?? 0;
    final draws = prefs.getInt('draws') ?? 0;

    return Score(
      wins: wins,
      losses: losses,
      draws: draws,
    );
  }

  /// Saves the score to persistent storage
  Future<void> saveScore(Score score) async {
    final prefs = await SharedPreferences.getInstance();

    // Store as individual keys for simplicity
    await prefs.setInt('wins', score.wins);
    await prefs.setInt('losses', score.losses);
    await prefs.setInt('draws', score.draws);
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
