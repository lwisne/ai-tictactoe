import '../models/board_position.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import 'game_service.dart';

/// Hard AI opponent using Minimax algorithm for optimal play
/// This AI is unbeatable - it will never lose
class AiHardService {
  final GameService _gameService;

  AiHardService(this._gameService);

  /// Gets the AI's move using Minimax algorithm with alpha-beta pruning
  /// Returns the optimal move for the current game state
  BoardPosition getMove(GameState state) {
    final emptyPositions = _gameService.getEmptyPositions(state);

    if (emptyPositions.isEmpty) {
      throw StateError('No valid moves available');
    }

    // If only one move available, return it immediately
    if (emptyPositions.length == 1) {
      return emptyPositions[0];
    }

    final aiPlayer = state.currentPlayer;
    int bestScore = -1000;
    BoardPosition? bestMove;

    // Try each empty position and find the best move
    for (final position in emptyPositions) {
      // Simulate the move
      final newBoard = List<Player?>.from(state.board);
      newBoard[position.index] = aiPlayer;

      // Calculate score for this move using minimax
      final score = _minimax(
        newBoard,
        0,
        false,
        aiPlayer,
        -1000,
        1000,
      );

      // Update best move if this is better
      if (score > bestScore) {
        bestScore = score;
        bestMove = position;
      }
    }

    return bestMove!;
  }

  /// Minimax algorithm with alpha-beta pruning
  /// Returns the score for the current board state
  ///
  /// - board: Current board state
  /// - depth: Current depth in game tree
  /// - isMaximizing: True if maximizing player's turn
  /// - aiPlayer: The AI player (maximizing player)
  /// - alpha: Best score for maximizing player
  /// - beta: Best score for minimizing player
  int _minimax(
    List<Player?> board,
    int depth,
    bool isMaximizing,
    Player aiPlayer,
    int alpha,
    int beta,
  ) {
    final opponent = aiPlayer.opponent;

    // Check terminal states
    final winner = _gameService.checkWinner(board);
    if (winner == aiPlayer) {
      return 10 - depth; // Prefer faster wins
    } else if (winner == opponent) {
      return depth - 10; // Prefer slower losses (though shouldn't happen)
    }

    // Check for draw
    if (board.every((cell) => cell != null)) {
      return 0;
    }

    if (isMaximizing) {
      // Maximizing player (AI)
      int maxScore = -1000;

      for (int i = 0; i < 9; i++) {
        if (board[i] == null) {
          board[i] = aiPlayer;
          final score = _minimax(board, depth + 1, false, aiPlayer, alpha, beta);
          board[i] = null;

          maxScore = score > maxScore ? score : maxScore;
          alpha = alpha > score ? alpha : score;

          // Alpha-beta pruning
          if (beta <= alpha) {
            break;
          }
        }
      }

      return maxScore;
    } else {
      // Minimizing player (opponent)
      int minScore = 1000;

      for (int i = 0; i < 9; i++) {
        if (board[i] == null) {
          board[i] = opponent;
          final score = _minimax(board, depth + 1, true, aiPlayer, alpha, beta);
          board[i] = null;

          minScore = score < minScore ? score : minScore;
          beta = beta < score ? beta : score;

          // Alpha-beta pruning
          if (beta <= alpha) {
            break;
          }
        }
      }

      return minScore;
    }
  }
}
