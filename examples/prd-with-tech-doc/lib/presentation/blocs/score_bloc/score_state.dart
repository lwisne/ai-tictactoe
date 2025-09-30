import 'package:equatable/equatable.dart';
import '../../../domain/entities/score.dart';

abstract class ScoreState extends Equatable {
  const ScoreState();

  @override
  List<Object?> get props => [];
}

class ScoreInitial extends ScoreState {
  const ScoreInitial();
}

class ScoreLoading extends ScoreState {
  const ScoreLoading();
}

class ScoreLoaded extends ScoreState {
  final Score score;

  const ScoreLoaded(this.score);

  @override
  List<Object?> get props => [score];
}

class ScoreError extends ScoreState {
  final String message;

  const ScoreError(this.message);

  @override
  List<Object?> get props => [message];
}
