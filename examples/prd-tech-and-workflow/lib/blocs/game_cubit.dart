import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/board_position.dart';
import '../models/game_state.dart';
import '../services/game_service.dart';

/// Cubit for managing game UI state
///
/// Follows architecture pattern: BLoC only manages UI state,
/// all business logic is delegated to GameService
class GameCubit extends Cubit<GameState> {
  final GameService _gameService;

  GameCubit(this._gameService) : super(GameState.initial());

  /// Attempts to make a move at the given position
  void makeMove(BoardPosition position) {
    try {
      final newState = _gameService.makeMove(state, position);
      emit(newState);
    } on ArgumentError {
      // Invalid move - state remains unchanged
      // In production, could emit an error state or show a message
    }
  }

  /// Resets the game to initial state
  void resetGame() {
    final newState = _gameService.resetGame();
    emit(newState);
  }

  /// Checks if a move is valid
  bool isValidMove(BoardPosition position) {
    return _gameService.isValidMove(state, position);
  }
}
