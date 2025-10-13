import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/score.dart';

/// Service for persisting game scores
class ScoreService {
  static const String _scoreKey = 'game_score';
  final SharedPreferences _prefs;

  ScoreService(this._prefs);

  /// Loads the current score from persistent storage
  Score loadScore() {
    final json = _prefs.getString(_scoreKey);
    if (json == null) {
      return Score.empty();
    }

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return Score.fromJson(map);
    } catch (e) {
      return Score.empty();
    }
  }

  /// Records a win for the specified player
  Future<void> recordWin(Player player) async {
    final currentScore = loadScore();
    final newScore = player == Player.x
        ? currentScore.copyWith(xWins: currentScore.xWins + 1)
        : currentScore.copyWith(oWins: currentScore.oWins + 1);

    await _saveScore(newScore);
  }

  /// Records a draw
  Future<void> recordDraw() async {
    final currentScore = loadScore();
    final newScore = currentScore.copyWith(draws: currentScore.draws + 1);
    await _saveScore(newScore);
  }

  /// Resets all scores to zero
  Future<void> resetScores() async {
    await _saveScore(Score.empty());
  }

  Future<void> _saveScore(Score score) async {
    final json = jsonEncode(score.toJson());
    await _prefs.setString(_scoreKey, json);
  }
}
