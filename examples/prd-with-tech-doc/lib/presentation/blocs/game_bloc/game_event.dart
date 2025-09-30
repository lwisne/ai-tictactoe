import 'package:equatable/equatable.dart';
import '../../../domain/entities/game_config.dart';
import '../../../domain/entities/position.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class StartNewGame extends GameEvent {
  final GameConfig config;

  const StartNewGame(this.config);

  @override
  List<Object?> get props => [config];
}

class MakeMove extends GameEvent {
  final Position position;

  const MakeMove(this.position);

  @override
  List<Object?> get props => [position];
}

class UndoMove extends GameEvent {
  const UndoMove();
}

class ResetGame extends GameEvent {
  const ResetGame();
}

class MakeAiMove extends GameEvent {
  const MakeAiMove();
}
