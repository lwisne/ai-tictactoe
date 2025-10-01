import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/score.dart';

/// Service for managing persistent score tracking
class ScoreService {
  static const String _scoreKey = 'tic_tac_toe_scores';
  final SharedPreferences _prefs;

  ScoreService(this._prefs);

  /// Loads scores from persistent storage
  Score loadScore() {
    final jsonString = _prefs.getString(_scoreKey);
    if (jsonString == null) {
      return Score.initial();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Score.fromJson(json);
    } catch (e) {
      // If deserialization fails, return initial score
      return Score.initial();
    }
  }

  /// Saves scores to persistent storage
  Future<void> saveScore(Score score) async {
    final jsonString = jsonEncode(score.toJson());
    await _prefs.setString(_scoreKey, jsonString);
  }

  /// Records a win for a player
  Future<Score> recordWin(Score currentScore, Player winner) async {
    final updatedScore = winner == Player.x
        ? currentScore.copyWith(xWins: currentScore.xWins + 1)
        : currentScore.copyWith(oWins: currentScore.oWins + 1);

    await saveScore(updatedScore);
    return updatedScore;
  }

  /// Records a draw
  Future<Score> recordDraw(Score currentScore) async {
    final updatedScore = currentScore.copyWith(draws: currentScore.draws + 1);
    await saveScore(updatedScore);
    return updatedScore;
  }

  /// Resets all scores to zero
  Future<Score> resetScores() async {
    final score = Score.initial();
    await saveScore(score);
    return score;
  }
}
