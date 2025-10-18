import 'package:equatable/equatable.dart';
import '../../../domain/models/game_state.dart' as domain;

/// Base class for all Game BLoC states
///
/// These states represent the UI state of the game screen.
/// The GameBloc emits these states based on results from GameService.
///
/// IMPORTANT: These are UI states, not domain states.
/// The domain.GameState (game logic state) is contained within these UI states.
abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

/// Initial state when GameBloc is first created
///
/// The game screen should show a loading or initialization UI.
class GameInitial extends GameState {
  const GameInitial();
}

/// State when game is actively in progress
///
/// Contains the current game state from the domain layer.
/// The UI should render the board and allow player interaction.
class GameInProgress extends GameState {
  final domain.GameState gameState;

  const GameInProgress(this.gameState);

  @override
  List<Object?> get props => [gameState];
}

/// State when the game has finished
///
/// This could be a win, loss, or draw.
/// The UI should show the final result and offer to play again.
class GameFinished extends GameState {
  final domain.GameState gameState;

  const GameFinished(this.gameState);

  @override
  List<Object?> get props => [gameState];
}

/// State when there's an error
///
/// The UI should display an error message.
class GameError extends GameState {
  final String message;

  const GameError(this.message);

  @override
  List<Object?> get props => [message];
}
