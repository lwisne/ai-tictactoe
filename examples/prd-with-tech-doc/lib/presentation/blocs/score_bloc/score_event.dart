import 'package:equatable/equatable.dart';

abstract class ScoreEvent extends Equatable {
  const ScoreEvent();

  @override
  List<Object?> get props => [];
}

class LoadScore extends ScoreEvent {
  const LoadScore();
}

class IncrementWins extends ScoreEvent {
  const IncrementWins();
}

class IncrementLosses extends ScoreEvent {
  const IncrementLosses();
}

class IncrementDraws extends ScoreEvent {
  const IncrementDraws();
}

class ResetScore extends ScoreEvent {
  const ResetScore();
}
