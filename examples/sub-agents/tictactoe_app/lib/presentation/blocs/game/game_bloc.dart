import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/models/game_result.dart';
import '../../../domain/services/game_service.dart';
import 'game_event.dart';
import 'game_state.dart';

/// BLoC for managing game state and coordinating game logic
///
/// This BLoC follows Clean Architecture principles:
/// - Contains ZERO business logic (all logic is in GameService)
/// - Only coordinates between UI events and domain services
/// - Transforms domain results into UI states
/// - Manages UI-specific concerns (loading, error states)
///
/// ARCHITECTURAL RULE: This BLoC MUST NOT contain game logic.
/// All turn management, validation, and win detection is in GameService.
@injectable
class GameBloc extends Bloc<GameEvent, GameState> {
  final GameService _gameService;

  GameBloc({required GameService gameService})
    : _gameService = gameService,
      super(const GameInitial()) {
    // Register event handlers
    on<GameInitialized>(_onGameInitialized);
    on<StartNewGame>(_onStartNewGame);
    on<MakeMove>(_onMakeMove);
    on<UndoMove>(_onUndoMove);
    on<ResetGame>(_onResetGame);
  }

  /// Handle game initialization
  ///
  /// This prepares the BLoC when the game screen loads.
  /// No game is created yet - user must trigger StartNewGame.
  Future<void> _onGameInitialized(
    GameInitialized event,
    Emitter<GameState> emit,
  ) async {
    // BLoC is initialized and ready for a new game
    // UI should show game mode selection or similar
    emit(const GameInitial());
  }

  /// Handle starting a new game
  ///
  /// Coordinates with GameService to create a new game state.
  /// Emits GameInProgress with the initial game state.
  Future<void> _onStartNewGame(
    StartNewGame event,
    Emitter<GameState> emit,
  ) async {
    try {
      // ✅ CORRECT: Delegate game creation to service
      final gameState = _gameService.createNewGame(event.config);

      // ✅ CORRECT: BLoC only transforms service result to UI state
      emit(GameInProgress(gameState));
    } catch (e) {
      emit(GameError('Failed to start game: $e'));
    }
  }

  /// Handle player move
  ///
  /// Coordinates with GameService to:
  /// 1. Validate the move
  /// 2. Update game state if valid
  /// 3. Check if game finished
  ///
  /// IMPORTANT: Contains ZERO game logic - all logic is in GameService.
  void _onMakeMove(MakeMove event, Emitter<GameState> emit) {
    // Only process moves when game is in progress
    if (state is! GameInProgress) {
      return;
    }

    final currentState = (state as GameInProgress).gameState;

    try {
      // ✅ CORRECT: Validate move via service (no validation logic here)
      if (!_gameService.isValidMove(currentState, event.position)) {
        // Invalid move - ignore it
        // Optionally could emit error state, but silent ignore is fine for UX
        return;
      }

      // ✅ CORRECT: Delegate move logic to service
      final newGameState = _gameService.makeMove(currentState, event.position);

      // ✅ CORRECT: BLoC decides UI state based on domain result
      if (newGameState.result != GameResult.ongoing) {
        // Game finished - emit finished state
        emit(GameFinished(newGameState));
      } else {
        // Game continues - emit in progress state
        emit(GameInProgress(newGameState));
      }
    } catch (e) {
      emit(GameError('Failed to make move: $e'));
    }
  }

  /// Handle undo move
  ///
  /// Coordinates with GameService to revert the last move.
  void _onUndoMove(UndoMove event, Emitter<GameState> emit) {
    // Can only undo when game is in progress or finished
    if (state is GameInitial || state is GameError) {
      return;
    }

    final currentState = state is GameInProgress
        ? (state as GameInProgress).gameState
        : (state as GameFinished).gameState;

    try {
      // ✅ CORRECT: Delegate undo logic to service
      final previousState = _gameService.undoLastMove(currentState);

      if (previousState == null) {
        // No moves to undo - could show message to user
        return;
      }

      // ✅ CORRECT: Transform service result to UI state
      // After undo, game is always in progress (never finished)
      emit(GameInProgress(previousState));
    } catch (e) {
      emit(GameError('Failed to undo move: $e'));
    }
  }

  /// Handle game reset
  ///
  /// Coordinates with GameService to create a fresh game
  /// with the same configuration.
  void _onResetGame(ResetGame event, Emitter<GameState> emit) {
    // Can only reset when we have an active game
    if (state is GameInitial || state is GameError) {
      return;
    }

    final currentState = state is GameInProgress
        ? (state as GameInProgress).gameState
        : (state as GameFinished).gameState;

    try {
      // ✅ CORRECT: Delegate reset logic to service
      final newGameState = _gameService.resetGame(currentState);

      // ✅ CORRECT: Transform service result to UI state
      emit(GameInProgress(newGameState));
    } catch (e) {
      emit(GameError('Failed to reset game: $e'));
    }
  }
}
