import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'game_event.dart';
import 'game_state.dart';

/// BLoC for managing game state and logic
///
/// This is a placeholder implementation demonstrating the BLoC pattern.
/// Future tasks will expand this with actual game logic including:
/// - Board state management
/// - Turn-based gameplay
/// - Win/draw detection
/// - AI opponent logic
/// - Score tracking
///
/// Follows Clean Architecture principles and demonstrates event/state pattern.
@injectable
class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(const GameState()) {
    // Register event handlers
    on<GameInitialized>(_onGameInitialized);
    on<GamePlaceholderEvent>(_onGamePlaceholder);
  }

  /// Handle game initialization
  Future<void> _onGameInitialized(
    GameInitialized event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // Placeholder: In future, this will initialize game board, load saved games, etc.
    await Future.delayed(const Duration(milliseconds: 100));

    emit(state.copyWith(isInitialized: true, isLoading: false));
  }

  /// Handle placeholder event
  /// This demonstrates the event handling pattern
  Future<void> _onGamePlaceholder(
    GamePlaceholderEvent event,
    Emitter<GameState> emit,
  ) async {
    // Placeholder for future game logic
    // This method demonstrates proper event handler structure
  }
}
