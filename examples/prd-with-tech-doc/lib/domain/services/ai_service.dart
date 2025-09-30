import 'dart:math';
import '../entities/difficulty_level.dart';
import '../entities/player.dart';
import '../entities/position.dart';
import 'game_service.dart';

class AiService {
  final GameService _gameService;
  final Random _random = Random();

  AiService(this._gameService);

  /// Gets the best move for the AI based on difficulty level
  Position getBestMove(
    List<List<Player>> board,
    Player aiPlayer,
    DifficultyLevel difficulty,
  ) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return _getRandomMove(board);
      case DifficultyLevel.medium:
        return _getMediumMove(board, aiPlayer);
      case DifficultyLevel.hard:
        return _getMinimaxMove(board, aiPlayer);
    }
  }

  /// Easy difficulty: Random valid move
  Position _getRandomMove(List<List<Player>> board) {
    final availableMoves = _gameService.getAvailableMoves(board);
    return availableMoves[_random.nextInt(availableMoves.length)];
  }

  /// Medium difficulty: Block opponent wins, otherwise random
  Position _getMediumMove(List<List<Player>> board, Player aiPlayer) {
    final opponent = aiPlayer.opponent;

    // Check if AI can win
    final winningMove = _findWinningMove(board, aiPlayer);
    if (winningMove != null) {
      return winningMove;
    }

    // Check if need to block opponent
    final blockingMove = _findWinningMove(board, opponent);
    if (blockingMove != null) {
      return blockingMove;
    }

    // Otherwise make a random move
    return _getRandomMove(board);
  }

  /// Hard difficulty: Use minimax algorithm for optimal play
  Position _getMinimaxMove(List<List<Player>> board, Player aiPlayer) {
    int bestScore = -1000;
    Position? bestMove;

    final availableMoves = _gameService.getAvailableMoves(board);

    for (final move in availableMoves) {
      // Make the move
      final newBoard = board.map((row) => List<Player>.from(row)).toList();
      newBoard[move.row][move.col] = aiPlayer;

      // Calculate score using minimax
      final score = _minimax(newBoard, 0, false, aiPlayer, -1000, 1000);

      // Update best move
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? availableMoves.first;
  }

  /// Minimax algorithm with alpha-beta pruning
  int _minimax(
    List<List<Player>> board,
    int depth,
    bool isMaximizing,
    Player aiPlayer,
    int alpha,
    int beta,
  ) {
    final opponent = aiPlayer.opponent;

    // Check terminal states
    final winner = _gameService.checkWinner(board);
    if (winner != null) {
      return winner.winner == aiPlayer ? 10 - depth : depth - 10;
    }

    if (_gameService.isBoardFull(board)) {
      return 0;
    }

    if (isMaximizing) {
      int maxScore = -1000;
      final availableMoves = _gameService.getAvailableMoves(board);

      for (final move in availableMoves) {
        final newBoard = board.map((row) => List<Player>.from(row)).toList();
        newBoard[move.row][move.col] = aiPlayer;

        final score = _minimax(newBoard, depth + 1, false, aiPlayer, alpha, beta);
        maxScore = max(maxScore, score);
        alpha = max(alpha, score);

        if (beta <= alpha) {
          break; // Beta cutoff
        }
      }

      return maxScore;
    } else {
      int minScore = 1000;
      final availableMoves = _gameService.getAvailableMoves(board);

      for (final move in availableMoves) {
        final newBoard = board.map((row) => List<Player>.from(row)).toList();
        newBoard[move.row][move.col] = opponent;

        final score = _minimax(newBoard, depth + 1, true, aiPlayer, alpha, beta);
        minScore = min(minScore, score);
        beta = min(beta, score);

        if (beta <= alpha) {
          break; // Alpha cutoff
        }
      }

      return minScore;
    }
  }

  /// Finds a winning move for the given player, if one exists
  Position? _findWinningMove(List<List<Player>> board, Player player) {
    final availableMoves = _gameService.getAvailableMoves(board);

    for (final move in availableMoves) {
      final testBoard = board.map((row) => List<Player>.from(row)).toList();
      testBoard[move.row][move.col] = player;

      final winner = _gameService.checkWinner(testBoard);
      if (winner != null && winner.winner == player) {
        return move;
      }
    }

    return null;
  }
}
