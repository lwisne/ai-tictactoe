import 'package:equatable/equatable.dart';
import '../../../domain/models/game_config.dart';
import '../../../domain/models/position.dart';

/// Base class for all Game events
///
/// Events represent user actions or system triggers that affect the game.
/// The GameBloc listens to these events and coordinates with GameService
/// to update the game state.
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the game BLoC
///
/// This is typically the first event sent when the game screen loads.
class GameInitialized extends GameEvent {
  const GameInitialized();
}

/// Event to start a new game
///
/// This creates a fresh game with the provided configuration.
class StartNewGame extends GameEvent {
  final GameConfig config;

  const StartNewGame(this.config);

  @override
  List<Object?> get props => [config];
}

/// Event when a player makes a move
///
/// This is triggered when a user taps a cell on the game board.
/// The GameBloc will validate the move via GameService and update the state.
class MakeMove extends GameEvent {
  final Position position;

  const MakeMove(this.position);

  @override
  List<Object?> get props => [position];
}

/// Event to undo the last move
///
/// This allows players to take back their last move.
class UndoMove extends GameEvent {
  const UndoMove();
}

/// Event to reset the current game
///
/// This starts a fresh game with the same configuration.
class ResetGame extends GameEvent {
  const ResetGame();
}
