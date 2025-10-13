import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/player.dart';
import '../models/score.dart';
import '../services/score_service.dart';

/// Cubit for managing score state
class ScoreCubit extends Cubit<Score> {
  final ScoreService _scoreService;

  ScoreCubit(this._scoreService) : super(Score.empty()) {
    loadScores();
  }

  /// Loads scores from persistent storage
  void loadScores() {
    final score = _scoreService.loadScore();
    emit(score);
  }

  /// Records a win for a player
  Future<void> recordWin(Player winner) async {
    await _scoreService.recordWin(winner);
    loadScores();
  }

  /// Records a draw
  Future<void> recordDraw() async {
    await _scoreService.recordDraw();
    loadScores();
  }

  /// Resets all scores to zero
  Future<void> resetScores() async {
    await _scoreService.resetScores();
    loadScores();
  }
}
