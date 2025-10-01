import '../models/board_position.dart';
import '../models/game_state.dart';
import '../models/player.dart';

/// Service containing all game business logic
class GameService {
  /// Validates if a move is legal
  bool isValidMove(GameState state, BoardPosition position) {
    // Can't make moves if game is over
    if (state.isGameOver) return false;

    // Position must be empty
    return state.board[position.index] == null;
  }

  /// Makes a move and returns the new game state
  GameState makeMove(GameState state, BoardPosition position) {
    if (!isValidMove(state, position)) {
      throw ArgumentError('Invalid move at position ${position.index}');
    }

    // Create new board with the move
    final newBoard = List<Player?>.from(state.board);
    newBoard[position.index] = state.currentPlayer;

    // Check if game is over (win or draw)
    final winner = checkWinner(newBoard);
    final boardFull = isBoardFull(GameState(
      board: newBoard,
      currentPlayer: state.currentPlayer,
    ));
    final isGameOver = winner != null || boardFull;

    // Switch to next player (unless game is over)
    final nextPlayer = state.currentPlayer.opponent;

    return state.copyWith(
      board: newBoard,
      currentPlayer: nextPlayer,
      isGameOver: isGameOver,
    );
  }

  /// Resets the game to initial state
  GameState resetGame() {
    return GameState.initial();
  }

  /// Gets all empty positions on the board
  List<BoardPosition> getEmptyPositions(GameState state) {
    final emptyPositions = <BoardPosition>[];
    for (int i = 0; i < 9; i++) {
      if (state.board[i] == null) {
        emptyPositions.add(BoardPosition(i));
      }
    }
    return emptyPositions;
  }

  /// Checks if the board is full
  bool isBoardFull(GameState state) {
    return state.board.every((cell) => cell != null);
  }

  /// Checks if there is a winner on the board
  /// Returns the winning player, or null if no winner
  Player? checkWinner(List<Player?> board) {
    // Define all winning patterns (indices)
    const winPatterns = [
      // Rows
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      // Columns
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      // Diagonals
      [0, 4, 8],
      [2, 4, 6],
    ];

    // Check each pattern
    for (final pattern in winPatterns) {
      final first = board[pattern[0]];
      if (first != null &&
          first == board[pattern[1]] &&
          first == board[pattern[2]]) {
        return first;
      }
    }

    return null;
  }

  /// Gets the winner from current game state
  /// Returns the winning player, or null if no winner
  Player? getWinner(GameState state) {
    return checkWinner(state.board);
  }

  /// Checks if the game is a draw
  bool isDraw(GameState state) {
    return state.isGameOver && getWinner(state) == null;
  }
}
