import 'dart:math';
import '../models/board_position.dart';
import '../models/game_state.dart';
import 'game_service.dart';

/// Easy AI opponent using random move selection
/// This AI makes random moves and is easy to beat
class AiEasyService {
  final GameService _gameService;
  final Random _random;

  AiEasyService(this._gameService, {Random? random})
      : _random = random ?? Random();

  /// Gets the AI's move by randomly selecting from empty positions
  BoardPosition getMove(GameState state) {
    final emptyPositions = _gameService.getEmptyPositions(state);

    if (emptyPositions.isEmpty) {
      throw StateError('No valid moves available');
    }

    return emptyPositions[_random.nextInt(emptyPositions.length)];
  }
}
