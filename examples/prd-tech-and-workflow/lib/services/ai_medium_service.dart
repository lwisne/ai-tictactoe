import 'dart:math';

import '../models/board_position.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import 'game_service.dart';

/// Medium AI opponent using basic strategy
/// Blocks obvious wins and creates opportunities, but makes some mistakes
class AiMediumService {
  final GameService _gameService;
  final Random _random;

  AiMediumService(this._gameService, {Random? random})
      : _random = random ?? Random();

  /// Gets the AI's move for the current game state
  /// Strategy:
  /// 1. 70% chance: Try to win if possible
  /// 2. 70% chance: Block opponent's winning move
  /// 3. 30% chance: Make strategic move (center, corners)
  /// 4. Otherwise: Random valid move
  BoardPosition getMove(GameState state) {
    final emptyPositions = _gameService.getEmptyPositions(state);

    if (emptyPositions.isEmpty) {
      throw StateError('No valid moves available');
    }

    final aiPlayer = state.currentPlayer;
    final opponent = aiPlayer.opponent;

    // 70% of the time, try to win immediately
    if (_random.nextDouble() < 0.7) {
      final winMove = _findWinningMove(state.board, aiPlayer);
      if (winMove != null) {
        return winMove;
      }
    }

    // 70% of the time, block opponent's winning move
    if (_random.nextDouble() < 0.7) {
      final blockMove = _findWinningMove(state.board, opponent);
      if (blockMove != null) {
        return blockMove;
      }
    }

    // 30% of the time, make a strategic move
    if (_random.nextDouble() < 0.3) {
      final strategicMove = _findStrategicMove(state.board, emptyPositions);
      if (strategicMove != null) {
        return strategicMove;
      }
    }

    // Otherwise, random move
    return emptyPositions[_random.nextInt(emptyPositions.length)];
  }

  /// Finds a move that would win for the given player
  BoardPosition? _findWinningMove(List<Player?> board, Player player) {
    // Try each empty position to see if it creates a win
    for (int i = 0; i < 9; i++) {
      if (board[i] == null) {
        final testBoard = List<Player?>.from(board);
        testBoard[i] = player;

        if (_gameService.checkWinner(testBoard) == player) {
          return BoardPosition(i);
        }
      }
    }
    return null;
  }

  /// Finds a strategic move (center, then corners, then edges)
  BoardPosition? _findStrategicMove(
      List<Player?> board, List<BoardPosition> emptyPositions) {
    // Prefer center (index 4)
    if (board[4] == null) {
      return BoardPosition(4);
    }

    // Prefer corners (0, 2, 6, 8)
    const corners = [0, 2, 6, 8];
    final emptyCorners =
        corners.where((i) => board[i] == null).map((i) => BoardPosition(i));
    if (emptyCorners.isNotEmpty) {
      return emptyCorners.elementAt(_random.nextInt(emptyCorners.length));
    }

    // Prefer edges (1, 3, 5, 7)
    const edges = [1, 3, 5, 7];
    final emptyEdges =
        edges.where((i) => board[i] == null).map((i) => BoardPosition(i));
    if (emptyEdges.isNotEmpty) {
      return emptyEdges.elementAt(_random.nextInt(emptyEdges.length));
    }

    return null;
  }
}
