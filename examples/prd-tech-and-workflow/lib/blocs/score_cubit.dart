import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/player.dart';
import '../models/score.dart';
import '../services/score_service.dart';

/// Cubit for managing score state
class ScoreCubit extends Cubit<Score> {
  final ScoreService _scoreService;

  ScoreCubit(this._scoreService) : super(Score.initial()) {
    loadScores();
  }

  /// Loads scores from persistent storage
  void loadScores() {
    final score = _scoreService.loadScore();
    emit(score);
  }

  /// Records a win for a player
  Future<void> recordWin(Player winner) async {
    final updatedScore = await _scoreService.recordWin(state, winner);
    emit(updatedScore);
  }

  /// Records a draw
  Future<void> recordDraw() async {
    final updatedScore = await _scoreService.recordDraw(state);
    emit(updatedScore);
  }

  /// Resets all scores to zero
  Future<void> resetScores() async {
    final score = await _scoreService.resetScores();
    emit(score);
  }
}
