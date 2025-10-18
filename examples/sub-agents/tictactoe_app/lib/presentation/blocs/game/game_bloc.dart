import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/game_state_persistence_repository.dart';
import '../../../domain/models/game_result.dart';
import '../../../domain/models/game_state.dart' as domain;
import '../../../domain/models/persisted_game_state.dart';
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
  final GameStatePersistenceRepository _persistenceRepository;

  // Track session scores for persistence
  int _playerWins = 0;
  int _aiWins = 0;
  int _draws = 0;

  // Store last saved state to avoid redundant saves
  PersistedGameState? _lastSavedState;

  GameBloc({
    required GameService gameService,
    required GameStatePersistenceRepository persistenceRepository,
  }) : _gameService = gameService,
       _persistenceRepository = persistenceRepository,
       super(const GameInitial()) {
    // Register event handlers
    on<GameInitialized>(_onGameInitialized);
    on<StartNewGame>(_onStartNewGame);
    on<MakeMove>(_onMakeMove);
    on<UndoMove>(_onUndoMove);
    on<ResetGame>(_onResetGame);
    on<SaveGameState>(_onSaveGameState);
    on<LoadSavedGameState>(_onLoadSavedGameState);
    on<ResumeGame>(_onResumeGame);
    on<ClearSavedGameState>(_onClearSavedGameState);
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
  /// 4. Auto-save state if game ongoing
  /// 5. Clear saved state if game finished
  ///
  /// IMPORTANT: Contains ZERO game logic - all logic is in GameService.
  Future<void> _onMakeMove(MakeMove event, Emitter<GameState> emit) async {
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
        // Update session scores
        _updateSessionScores(newGameState.result);

        // Game finished - emit finished state and clear saved state
        emit(GameFinished(newGameState));
        await _persistenceRepository.clearGameState();
        _lastSavedState = null;
      } else {
        // Game continues - emit in progress state and save
        emit(GameInProgress(newGameState));
        await _saveCurrentState(newGameState);
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
  Future<void> _onResetGame(ResetGame event, Emitter<GameState> emit) async {
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

      // Save the reset state
      await _saveCurrentState(newGameState);
    } catch (e) {
      emit(GameError('Failed to reset game: $e'));
    }
  }

  /// Handle save game state
  ///
  /// Triggered by app lifecycle changes to persist current game.
  Future<void> _onSaveGameState(
    SaveGameState event,
    Emitter<GameState> emit,
  ) async {
    // Only save when game is in progress
    if (state is! GameInProgress) {
      return;
    }

    final currentState = (state as GameInProgress).gameState;
    await _saveCurrentState(currentState);
  }

  /// Handle load saved game state
  ///
  /// Triggered on app startup to check for saved in-progress games.
  Future<void> _onLoadSavedGameState(
    LoadSavedGameState event,
    Emitter<GameState> emit,
  ) async {
    try {
      final savedState = await _persistenceRepository.loadGameState();

      if (savedState != null) {
        // Restore session scores
        _playerWins = savedState.playerWins;
        _aiWins = savedState.aiWins;
        _draws = savedState.draws;
        _lastSavedState = savedState;

        // Emit state to trigger resume dialog
        emit(GameSavedStateDetected(savedState));
      } else {
        // No saved state - stay in initial state
        emit(const GameInitial());
      }
    } catch (e) {
      // Error loading state - clear it and continue
      await _persistenceRepository.clearGameState();
      emit(const GameInitial());
    }
  }

  /// Handle resume game
  ///
  /// Triggered when user chooses to resume from the dialog.
  void _onResumeGame(ResumeGame event, Emitter<GameState> emit) {
    if (state is! GameSavedStateDetected) {
      return;
    }

    final savedState = (state as GameSavedStateDetected).persistedState;

    // Check if saved game is still ongoing
    if (savedState.gameState.result == GameResult.ongoing) {
      emit(GameInProgress(savedState.gameState));
    } else {
      // Saved game was finished - just show it as finished
      emit(GameFinished(savedState.gameState));
    }
  }

  /// Handle clear saved game state
  ///
  /// Triggered when user chooses "New Game" from resume dialog
  /// or when game ends normally.
  Future<void> _onClearSavedGameState(
    ClearSavedGameState event,
    Emitter<GameState> emit,
  ) async {
    await _persistenceRepository.clearGameState();
    _lastSavedState = null;
    _playerWins = 0;
    _aiWins = 0;
    _draws = 0;
    emit(const GameInitial());
  }

  /// Helper: Save current state to persistent storage
  ///
  /// Only saves if state has changed since last save.
  Future<void> _saveCurrentState(domain.GameState gameState) async {
    final persistedState = PersistedGameState(
      gameState: gameState,
      playerWins: _playerWins,
      aiWins: _aiWins,
      draws: _draws,
      savedAt: DateTime.now(),
    );

    // Skip save if state hasn't changed (compare only meaningful fields)
    if (_lastSavedState != null &&
        _lastSavedState!.gameState == persistedState.gameState &&
        _lastSavedState!.playerWins == persistedState.playerWins &&
        _lastSavedState!.aiWins == persistedState.aiWins &&
        _lastSavedState!.draws == persistedState.draws) {
      return;
    }

    await _persistenceRepository.saveGameState(persistedState);
    _lastSavedState = persistedState;
  }

  /// Helper: Update session scores based on game result
  ///
  /// Note: This tracks all game results regardless of mode.
  /// In single-player mode: Player.x is the user, Player.o is AI.
  /// In two-player mode: Both players are users, so "wins" track X vs O.
  void _updateSessionScores(GameResult result) {
    switch (result) {
      case GameResult.win:
        _playerWins++;
        break;
      case GameResult.loss:
        _aiWins++;
        break;
      case GameResult.draw:
        _draws++;
        break;
      case GameResult.ongoing:
        // Should never happen when game is finished
        break;
    }
  }
}
