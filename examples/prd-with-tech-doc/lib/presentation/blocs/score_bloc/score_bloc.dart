import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/score_repository.dart';
import '../../../domain/models/score.dart';
import 'score_event.dart';
import 'score_state.dart';

class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  final ScoreRepository _scoreRepository;

  ScoreBloc({required ScoreRepository scoreRepository})
      : _scoreRepository = scoreRepository,
        super(const ScoreInitial()) {
    on<LoadScore>(_onLoadScore);
    on<IncrementWins>(_onIncrementWins);
    on<IncrementLosses>(_onIncrementLosses);
    on<IncrementDraws>(_onIncrementDraws);
    on<ResetScore>(_onResetScore);
  }

  Future<void> _onLoadScore(LoadScore event, Emitter<ScoreState> emit) async {
    emit(const ScoreLoading());
    try {
      final score = await _scoreRepository.loadScore();
      emit(ScoreLoaded(score));
    } catch (e) {
      emit(ScoreError(e.toString()));
    }
  }

  Future<void> _onIncrementWins(IncrementWins event, Emitter<ScoreState> emit) async {
    if (state is! ScoreLoaded) return;

    final currentScore = (state as ScoreLoaded).score;
    try {
      final newScore = await _scoreRepository.incrementWins(currentScore);
      emit(ScoreLoaded(newScore));
    } catch (e) {
      emit(ScoreError(e.toString()));
    }
  }

  Future<void> _onIncrementLosses(IncrementLosses event, Emitter<ScoreState> emit) async {
    if (state is! ScoreLoaded) return;

    final currentScore = (state as ScoreLoaded).score;
    try {
      final newScore = await _scoreRepository.incrementLosses(currentScore);
      emit(ScoreLoaded(newScore));
    } catch (e) {
      emit(ScoreError(e.toString()));
    }
  }

  Future<void> _onIncrementDraws(IncrementDraws event, Emitter<ScoreState> emit) async {
    if (state is! ScoreLoaded) return;

    final currentScore = (state as ScoreLoaded).score;
    try {
      final newScore = await _scoreRepository.incrementDraws(currentScore);
      emit(ScoreLoaded(newScore));
    } catch (e) {
      emit(ScoreError(e.toString()));
    }
  }

  Future<void> _onResetScore(ResetScore event, Emitter<ScoreState> emit) async {
    try {
      await _scoreRepository.resetScore();
      emit(const ScoreLoaded(Score()));
    } catch (e) {
      emit(ScoreError(e.toString()));
    }
  }
}
