import 'package:equatable/equatable.dart';

/// Base class for all Game events
///
/// This is a placeholder implementation for the game BLoC.
/// Future tasks will expand this with actual game logic events such as:
/// - GameStarted
/// - CellSelected
/// - GameReset
/// - TurnChanged
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the game
class GameInitialized extends GameEvent {
  const GameInitialized();
}

/// Placeholder event for future game logic
/// This demonstrates the event pattern and will be expanded in future tasks
class GamePlaceholderEvent extends GameEvent {
  const GamePlaceholderEvent();
}
