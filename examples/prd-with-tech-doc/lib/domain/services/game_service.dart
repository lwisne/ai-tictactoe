import '../entities/game_config.dart';
import '../entities/game_result.dart';
import '../entities/game_state.dart';
import '../entities/player.dart';
import '../entities/position.dart';

class GameService {
  /// Creates a new game state with an empty board
  GameState createNewGame(GameConfig config) {
    final board = List.generate(
      3,
      (_) => List.generate(3, (_) => Player.none),
    );

    return GameState(
      board: board,
      currentPlayer: config.firstPlayer,
      config: config,
      startTime: DateTime.now(),
    );
  }

  /// Validates if a move is legal
  bool isValidMove(GameState state, Position position) {
    if (state.result != GameResult.ongoing) {
      return false;
    }

    if (position.row < 0 || position.row > 2 || position.col < 0 || position.col > 2) {
      return false;
    }

    return state.board[position.row][position.col] == Player.none;
  }

  /// Makes a move and returns the new game state
  GameState makeMove(GameState state, Position position) {
    if (!isValidMove(state, position)) {
      return state;
    }

    // Update board
    final newBoard = state.board.map((row) => List<Player>.from(row)).toList();
    newBoard[position.row][position.col] = state.currentPlayer;

    // Update move history
    final newMoveHistory = List<Position>.from(state.moveHistory)..add(position);

    // Check for winner
    final winResult = checkWinner(newBoard);
    final gameResult = winResult != null
        ? (winResult.winner == state.currentPlayer ? GameResult.win : GameResult.loss)
        : (isBoardFull(newBoard) ? GameResult.draw : GameResult.ongoing);

    // Calculate elapsed time
    final elapsedTime = DateTime.now().difference(state.startTime);

    return state.copyWith(
      board: newBoard,
      currentPlayer: gameResult == GameResult.ongoing ? state.currentPlayer.opponent : state.currentPlayer,
      result: gameResult,
      winner: winResult?.winner,
      winningLine: winResult?.line,
      moveHistory: newMoveHistory,
      elapsedTime: elapsedTime,
    );
  }

  /// Checks if the board is full
  bool isBoardFull(List<List<Player>> board) {
    for (var row in board) {
      for (var cell in row) {
        if (cell == Player.none) {
          return false;
        }
      }
    }
    return true;
  }

  /// Checks for a winner and returns the winner and winning line
  WinResult? checkWinner(List<List<Player>> board) {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != Player.none &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        return WinResult(
          winner: board[i][0],
          line: [
            Position(row: i, col: 0),
            Position(row: i, col: 1),
            Position(row: i, col: 2),
          ],
        );
      }
    }

    // Check columns
    for (int j = 0; j < 3; j++) {
      if (board[0][j] != Player.none &&
          board[0][j] == board[1][j] &&
          board[1][j] == board[2][j]) {
        return WinResult(
          winner: board[0][j],
          line: [
            Position(row: 0, col: j),
            Position(row: 1, col: j),
            Position(row: 2, col: j),
          ],
        );
      }
    }

    // Check diagonals
    if (board[0][0] != Player.none &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return WinResult(
        winner: board[0][0],
        line: [
          const Position(row: 0, col: 0),
          const Position(row: 1, col: 1),
          const Position(row: 2, col: 2),
        ],
      );
    }

    if (board[0][2] != Player.none &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return WinResult(
        winner: board[0][2],
        line: [
          const Position(row: 0, col: 2),
          const Position(row: 1, col: 1),
          const Position(row: 2, col: 0),
        ],
      );
    }

    return null;
  }

  /// Gets all available moves
  List<Position> getAvailableMoves(List<List<Player>> board) {
    final moves = <Position>[];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          moves.add(Position(row: i, col: j));
        }
      }
    }
    return moves;
  }

  /// Undoes the last move
  GameState? undoLastMove(GameState state) {
    if (state.moveHistory.isEmpty) {
      return null;
    }

    final newMoveHistory = List<Position>.from(state.moveHistory)..removeLast();
    final newBoard = List.generate(
      3,
      (_) => List.generate(3, (_) => Player.none),
    );

    // Replay all moves except the last one
    Player currentPlayer = state.config.firstPlayer;
    for (final position in newMoveHistory) {
      newBoard[position.row][position.col] = currentPlayer;
      currentPlayer = currentPlayer.opponent;
    }

    return GameState(
      board: newBoard,
      currentPlayer: currentPlayer,
      moveHistory: newMoveHistory,
      config: state.config,
      startTime: state.startTime,
      elapsedTime: state.elapsedTime,
    );
  }

  /// Resets the game with the same configuration
  GameState resetGame(GameState state) {
    return createNewGame(state.config);
  }
}

/// Helper class to return winner information
class WinResult {
  final Player winner;
  final List<Position> line;

  WinResult({
    required this.winner,
    required this.line,
  });
}
