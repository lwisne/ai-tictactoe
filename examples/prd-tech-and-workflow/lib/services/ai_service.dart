import 'dart:math';
import '../models/board_position.dart';
import '../models/game_state.dart';

/// Service for AI opponent logic
class AIService {
  final Random _random;

  AIService({Random? random}) : _random = random ?? Random();

  /// Gets the next AI move for easy difficulty (random selection)
  /// Returns null if no valid moves available
  BoardPosition? getEasyMove(GameState state, List<BoardPosition> emptyPositions) {
    if (emptyPositions.isEmpty) {
      return null;
    }

    final randomIndex = _random.nextInt(emptyPositions.length);
    return emptyPositions[randomIndex];
  }
}
