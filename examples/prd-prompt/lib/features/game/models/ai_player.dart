import 'dart:math';
import 'game_board.dart';
import 'game_mode.dart';
import 'game_result.dart';
import 'player.dart';

class AiPlayer {
  final AiDifficulty difficulty;
  final Random _random = Random();

  AiPlayer({required this.difficulty});

  int getMove(GameBoard board) {
    switch (difficulty) {
      case AiDifficulty.easy:
        return _getRandomMove(board);
      case AiDifficulty.medium:
        return _getMediumMove(board);
      case AiDifficulty.hard:
        return _getHardMove(board);
    }
  }

  // Easy: Random move
  int _getRandomMove(GameBoard board) {
    final availableMoves = board.getAvailableMoves();
    if (availableMoves.isEmpty) return -1;
    return availableMoves[_random.nextInt(availableMoves.length)];
  }

  // Medium: Block opponent's winning move or take winning move, otherwise random
  int _getMediumMove(GameBoard board) {
    final aiPlayer = board.currentPlayer;
    final opponent = aiPlayer.opponent;

    // Check if AI can win
    final winningMove = _findWinningMove(board, aiPlayer);
    if (winningMove != -1) return winningMove;

    // Check if need to block opponent
    final blockingMove = _findWinningMove(board, opponent);
    if (blockingMove != -1) return blockingMove;

    // Otherwise, random move
    return _getRandomMove(board);
  }

  // Hard: Minimax algorithm for optimal play
  int _getHardMove(GameBoard board) {
    int bestScore = -1000;
    int bestMove = -1;

    for (final move in board.getAvailableMoves()) {
      final newBoard = board.makeMove(move);
      final score = _minimax(newBoard, 0, false, board.currentPlayer);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  int _findWinningMove(GameBoard board, Player player) {
    for (final move in board.getAvailableMoves()) {
      final testBoard = GameBoard(
        cells: List.from(board.cells)..[move] = player,
        currentPlayer: player.opponent,
      );

      if (testBoard.checkGameResult().status == GameStatus.won) {
        return move;
      }
    }
    return -1;
  }

  int _minimax(GameBoard board, int depth, bool isMaximizing, Player aiPlayer) {
    final result = board.checkGameResult();

    if (result.status == GameStatus.won) {
      if (result.winner == aiPlayer) {
        return 10 - depth; // Prefer faster wins
      } else {
        return depth - 10; // Prefer slower losses
      }
    }

    if (result.status == GameStatus.draw) {
      return 0;
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (final move in board.getAvailableMoves()) {
        final newBoard = board.makeMove(move);
        final score = _minimax(newBoard, depth + 1, false, aiPlayer);
        bestScore = max(bestScore, score);
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (final move in board.getAvailableMoves()) {
        final newBoard = board.makeMove(move);
        final score = _minimax(newBoard, depth + 1, true, aiPlayer);
        bestScore = min(bestScore, score);
      }
      return bestScore;
    }
  }
}