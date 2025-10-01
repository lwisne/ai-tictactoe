import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/player.dart';
import '../models/score.dart';
import '../services/score_service.dart';

/// Cubit for managing score state
///
/// Follows architecture pattern: Delegates all business logic to ScoreService
class ScoreCubit extends Cubit<Score> {
  final ScoreService _scoreService;

  ScoreCubit(this._scoreService) : super(_scoreService.loadScore());

  /// Records a win for the specified player and updates state
  Future<void> recordWin(Player player) async {
    await _scoreService.recordWin(player);
    emit(_scoreService.loadScore());
  }

  /// Records a draw and updates state
  Future<void> recordDraw() async {
    await _scoreService.recordDraw();
    emit(_scoreService.loadScore());
  }

  /// Resets all scores to zero and updates state
  Future<void> resetScores() async {
    await _scoreService.resetScores();
    emit(_scoreService.loadScore());
  }

  /// Refreshes the score from persistent storage
  void refresh() {
    emit(_scoreService.loadScore());
  }
}
