import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/game_mode.dart';
import '../../../domain/models/game_result.dart';
import '../../../domain/models/player.dart';
import '../../../domain/services/ai_service.dart';
import '../../../domain/services/game_service.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameBlocState> {
  final GameService _gameService;
  final AiService _aiService;

  GameBloc({
    required GameService gameService,
    required AiService aiService,
  })  : _gameService = gameService,
        _aiService = aiService,
        super(const GameInitial()) {
    on<StartNewGame>(_onStartNewGame);
    on<MakeMove>(_onMakeMove);
    on<UndoMove>(_onUndoMove);
    on<ResetGame>(_onResetGame);
    on<MakeAiMove>(_onMakeAiMove);
  }

  void _onStartNewGame(StartNewGame event, Emitter<GameBlocState> emit) {
    final gameState = _gameService.createNewGame(event.config);
    emit(GameInProgress(gameState));

    // If AI plays first in single player mode
    if (event.config.gameMode == GameMode.singlePlayer &&
        event.config.firstPlayer == Player.o) {
      add(const MakeAiMove());
    }
  }

  void _onMakeMove(MakeMove event, Emitter<GameBlocState> emit) {
    if (state is! GameInProgress) return;

    final currentState = (state as GameInProgress).gameState;

    // Validate and make move
    if (!_gameService.isValidMove(currentState, event.position)) {
      return;
    }

    final newGameState = _gameService.makeMove(currentState, event.position);

    // Check if game is finished
    if (newGameState.result != GameResult.ongoing) {
      emit(GameFinished(newGameState));
      return;
    }

    emit(GameInProgress(newGameState));

    // Trigger AI move if in single player mode
    if (newGameState.config.gameMode == GameMode.singlePlayer) {
      add(const MakeAiMove());
    }
  }

  Future<void> _onMakeAiMove(MakeAiMove event, Emitter<GameBlocState> emit) async {
    if (state is! GameInProgress) return;

    final currentState = (state as GameInProgress).gameState;

    // Only make AI move in single player mode
    if (currentState.config.gameMode != GameMode.singlePlayer) {
      return;
    }

    // Show AI thinking state
    emit(AiThinking(currentState));

    // Add slight delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    // Get AI move
    final aiPlayer = Player.o;
    final difficulty = currentState.config.difficultyLevel!;
    final aiMove = _aiService.getBestMove(
      currentState.board,
      aiPlayer,
      difficulty,
    );

    // Make the AI move
    final newGameState = _gameService.makeMove(currentState, aiMove);

    // Check if game is finished
    if (newGameState.result != GameResult.ongoing) {
      emit(GameFinished(newGameState));
      return;
    }

    emit(GameInProgress(newGameState));
  }

  void _onUndoMove(UndoMove event, Emitter<GameBlocState> emit) {
    if (state is! GameInProgress && state is! GameFinished) return;

    final currentState = state is GameInProgress
        ? (state as GameInProgress).gameState
        : (state as GameFinished).gameState;

    final previousState = _gameService.undoLastMove(currentState);

    if (previousState != null) {
      // In single player mode, undo two moves (player and AI)
      if (currentState.config.gameMode == GameMode.singlePlayer) {
        final previousPreviousState = _gameService.undoLastMove(previousState);
        if (previousPreviousState != null) {
          emit(GameInProgress(previousPreviousState));
          return;
        }
      }

      emit(GameInProgress(previousState));
    }
  }

  void _onResetGame(ResetGame event, Emitter<GameBlocState> emit) {
    if (state is GameInitial) return;

    final currentState = state is GameInProgress
        ? (state as GameInProgress).gameState
        : state is GameFinished
            ? (state as GameFinished).gameState
            : null;

    if (currentState == null) return;

    final newGameState = _gameService.resetGame(currentState);
    emit(GameInProgress(newGameState));

    // If AI plays first in single player mode
    if (newGameState.config.gameMode == GameMode.singlePlayer &&
        newGameState.config.firstPlayer == Player.o) {
      add(const MakeAiMove());
    }
  }
}
