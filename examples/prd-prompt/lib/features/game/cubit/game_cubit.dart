import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import '../models/ai_player.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  AiPlayer? _aiPlayer;

  GameCubit({
    required GameMode gameMode,
    AiDifficulty? aiDifficulty,
  }) : super(GameState.initial(
          gameMode: gameMode,
          aiDifficulty: aiDifficulty,
        )) {
    if (gameMode.isSinglePlayer && aiDifficulty != null) {
      _aiPlayer = AiPlayer(difficulty: aiDifficulty);
    }
  }

  Future<void> makeMove(int index) async {
    if (!state.canMakeMove) return;
    if (!state.board.isValidMove(index)) return;

    // Make player move
    final newBoard = state.board.makeMove(index);
    final result = newBoard.checkGameResult();

    // Provide haptic feedback
    await _provideHapticFeedback();

    emit(state.copyWith(
      board: newBoard,
      result: result,
    ));

    // If game is over, provide end-game haptic feedback
    if (result.status.isOver) {
      await _provideGameOverHaptic();
      return;
    }

    // If single player mode and it's AI's turn, make AI move
    if (state.gameMode.isSinglePlayer &&
        newBoard.currentPlayer == Player.o &&
        _aiPlayer != null) {
      await _makeAiMove();
    }
  }

  Future<void> _makeAiMove() async {
    emit(state.copyWith(isAiThinking: true));

    // Add small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    final aiMove = _aiPlayer!.getMove(state.board);
    if (aiMove == -1) {
      emit(state.copyWith(isAiThinking: false));
      return;
    }

    final newBoard = state.board.makeMove(aiMove);
    final result = newBoard.checkGameResult();

    // Provide haptic feedback for AI move
    await _provideHapticFeedback();

    emit(state.copyWith(
      board: newBoard,
      result: result,
      isAiThinking: false,
    ));

    // If game is over, provide end-game haptic feedback
    if (result.status.isOver) {
      await _provideGameOverHaptic();
    }
  }

  void resetGame() {
    emit(GameState.initial(
      gameMode: state.gameMode,
      aiDifficulty: state.aiDifficulty,
    ));
  }

  Future<void> _provideHapticFeedback() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.vibrate(duration: 50);
    }
  }

  Future<void> _provideGameOverHaptic() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.vibrate(duration: 200);
    }
  }
}