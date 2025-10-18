import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'game_ui_state.dart';

/// Cubit for managing simple game UI state
///
/// This is a temporary implementation for LWI-99 (Create 3×3 game board UI).
/// It handles basic game state without business logic.
///
/// NOTE: This will be replaced with a proper GameBloc that uses GameService
/// for business logic (win detection, validation, etc.) in future tasks.
@injectable
class GameUICubit extends Cubit<GameUIState> {
  GameUICubit() : super(const GameUIState.initial());

  /// Handles a cell tap by updating the board and switching players
  ///
  /// This is simplified logic for UI demonstration only.
  /// Real game logic (win detection, validation) will be in GameService.
  void handleCellTap(int index) {
    if (state.board[index].isEmpty && !state.isGameOver) {
      final newBoard = List<String>.from(state.board);
      newBoard[index] = state.currentPlayer;

      emit(
        state.copyWith(
          board: newBoard,
          currentPlayer: state.currentPlayer == 'X' ? 'O' : 'X',
        ),
      );
    }
  }

  /// Resets the game to initial state
  void resetGame() {
    emit(const GameUIState.initial());
  }
}
