import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/score.dart';

class ScoreRepository {
  static const String _winsKey = 'wins';
  static const String _lossesKey = 'losses';
  static const String _drawsKey = 'draws';

  /// Loads the score from persistent storage
  Future<Score> loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    final wins = prefs.getInt(_winsKey) ?? 0;
    final losses = prefs.getInt(_lossesKey) ?? 0;
    final draws = prefs.getInt(_drawsKey) ?? 0;

    return Score(
      wins: wins,
      losses: losses,
      draws: draws,
    );
  }

  /// Saves the score to persistent storage
  Future<void> saveScore(Score score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_winsKey, score.wins);
    await prefs.setInt(_lossesKey, score.losses);
    await prefs.setInt(_drawsKey, score.draws);
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
