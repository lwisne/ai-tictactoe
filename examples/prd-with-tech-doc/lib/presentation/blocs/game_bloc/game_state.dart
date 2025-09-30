import 'package:equatable/equatable.dart';
import '../../../domain/models/game_state.dart' as domain;

abstract class GameBlocState extends Equatable {
  const GameBlocState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameBlocState {
  const GameInitial();
}

class GameInProgress extends GameBlocState {
  final domain.GameState gameState;

  const GameInProgress(this.gameState);

  @override
  List<Object?> get props => [gameState];
}

class GameFinished extends GameBlocState {
  final domain.GameState gameState;

  const GameFinished(this.gameState);

  @override
  List<Object?> get props => [gameState];
}

class AiThinking extends GameBlocState {
  final domain.GameState gameState;

  const AiThinking(this.gameState);

  @override
  List<Object?> get props => [gameState];
}
