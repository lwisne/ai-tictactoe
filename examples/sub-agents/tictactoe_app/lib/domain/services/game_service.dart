import 'package:injectable/injectable.dart';
import '../models/game_config.dart';
import '../models/game_result.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/position.dart';

/// Result of checking for a winner
///
/// Contains the winning player and the positions that form the winning line.
class WinResult {
  final Player winner;
  final List<Position> line;

  const WinResult({required this.winner, required this.line});
}

/// Service containing all game logic and turn management
///
/// This service is the brain of the Tic-Tac-Toe game. It handles:
/// - Creating new games
/// - Validating moves
/// - Managing turns
/// - Detecting wins and draws
/// - Board analysis
///
/// This is a stateless service - all state is passed in and returned.
/// It contains ZERO UI logic and has NO Flutter dependencies.
@lazySingleton
class GameService {
  /// Creates a new game with an empty board
  ///
  /// Returns a [GameState] with:
  /// - Empty 3x3 board (all cells are [Player.none])
  /// - Current player set to [GameConfig.firstPlayer]
  /// - Game result set to [GameResult.ongoing]
  /// - Start time set to current time
  GameState createNewGame(GameConfig config) {
    // Create empty 3x3 board
    final board = List.generate(3, (_) => List.generate(3, (_) => Player.none));

    return GameState(
      board: board,
      currentPlayer: config.firstPlayer,
      result: GameResult.ongoing,
      config: config,
      startTime: DateTime.now(),
      moveHistory: const [],
    );
  }

  /// Validates if a move is legal
  ///
  /// Returns `false` if:
  /// - Game is already finished (result != ongoing)
  /// - Position is out of bounds (row/col not 0-2)
  /// - Cell is already occupied (not [Player.none])
  ///
  /// Returns `true` if the move is valid.
  bool isValidMove(GameState state, Position position) {
    // Game must be ongoing
    if (state.result != GameResult.ongoing) {
      return false;
    }

    // Position must be within bounds
    if (position.row < 0 ||
        position.row > 2 ||
        position.col < 0 ||
        position.col > 2) {
      return false;
    }

    // Cell must be empty
    if (state.board[position.row][position.col] != Player.none) {
      return false;
    }

    return true;
  }

  /// Makes a move and returns the new game state
  ///
  /// This is the core turn management method. It:
  /// 1. Validates the move
  /// 2. Updates the board
  /// 3. Checks for win/draw
  /// 4. Switches turns (if game continues)
  /// 5. Updates move history
  ///
  /// If the move is invalid, returns the current state unchanged.
  ///
  /// This method handles ALL turn logic - the BLoC simply calls this
  /// and emits the resulting state to the UI.
  GameState makeMove(GameState state, Position position) {
    // Validate move
    if (!isValidMove(state, position)) {
      return state;
    }

    // Create a deep copy of the board
    final newBoard = state.board.map((row) => List<Player>.from(row)).toList();

    // Place current player's mark
    newBoard[position.row][position.col] = state.currentPlayer;

    // Check for winner
    final winResult = checkWinner(newBoard);

    // Determine game result
    GameResult gameResult;
    Player? winner;
    List<Position>? winningLine;

    if (winResult != null) {
      // Someone won
      winner = winResult.winner;
      winningLine = winResult.line;
      // In two-player mode, the player who just moved won
      // In single-player mode, we'll determine win/loss later
      gameResult = GameResult.win;
    } else if (isBoardFull(newBoard)) {
      // Board is full with no winner - draw
      gameResult = GameResult.draw;
    } else {
      // Game continues
      gameResult = GameResult.ongoing;
    }

    // Switch turns only if game is still ongoing
    final nextPlayer = gameResult == GameResult.ongoing
        ? state.currentPlayer.opponent
        : state.currentPlayer;

    // Add move to history
    final newMoveHistory = [...state.moveHistory, position];

    // Calculate elapsed time
    final elapsedTime = DateTime.now().difference(state.startTime);

    return state.copyWith(
      board: newBoard,
      currentPlayer: nextPlayer,
      result: gameResult,
      winner: winner,
      winningLine: winningLine,
      moveHistory: newMoveHistory,
      elapsedTime: elapsedTime,
    );
  }

  /// Checks if the board is completely filled
  ///
  /// Returns `true` if all cells contain [Player.x] or [Player.o].
  /// Returns `false` if any cell is [Player.none].
  bool isBoardFull(List<List<Player>> board) {
    for (final row in board) {
      for (final cell in row) {
        if (cell == Player.none) {
          return false;
        }
      }
    }
    return true;
  }

  /// Checks for a winner on the board
  ///
  /// Checks all possible winning combinations:
  /// - 3 horizontal lines
  /// - 3 vertical lines
  /// - 2 diagonal lines
  ///
  /// Returns [WinResult] with winner and winning line if found.
  /// Returns `null` if no winner.
  WinResult? checkWinner(List<List<Player>> board) {
    // Check horizontal lines
    for (int row = 0; row < 3; row++) {
      if (board[row][0] != Player.none &&
          board[row][0] == board[row][1] &&
          board[row][1] == board[row][2]) {
        return WinResult(
          winner: board[row][0],
          line: [
            Position(row: row, col: 0),
            Position(row: row, col: 1),
            Position(row: row, col: 2),
          ],
        );
      }
    }

    // Check vertical lines
    for (int col = 0; col < 3; col++) {
      if (board[0][col] != Player.none &&
          board[0][col] == board[1][col] &&
          board[1][col] == board[2][col]) {
        return WinResult(
          winner: board[0][col],
          line: [
            Position(row: 0, col: col),
            Position(row: 1, col: col),
            Position(row: 2, col: col),
          ],
        );
      }
    }

    // Check diagonal (top-left to bottom-right)
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

    // Check diagonal (top-right to bottom-left)
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

  /// Gets all available (empty) positions on the board
  ///
  /// Returns a list of all positions where [Player.none] currently resides.
  /// Used for AI move calculation and validation.
  List<Position> getAvailableMoves(List<List<Player>> board) {
    final availableMoves = <Position>[];

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col] == Player.none) {
          availableMoves.add(Position(row: row, col: col));
        }
      }
    }

    return availableMoves;
  }

  /// Undoes the last move
  ///
  /// Returns a new [GameState] with the last move removed, or `null` if
  /// there are no moves to undo.
  ///
  /// This reconstructs the game state by replaying all moves except the last.
  GameState? undoLastMove(GameState state) {
    if (state.moveHistory.isEmpty) {
      return null;
    }

    // Get all moves except the last one
    final newMoveHistory = state.moveHistory.sublist(
      0,
      state.moveHistory.length - 1,
    );

    // Start fresh with same config
    GameState newState = createNewGame(state.config);

    // Replay all moves except the last
    for (final move in newMoveHistory) {
      newState = makeMove(newState, move);
    }

    return newState;
  }

  /// Resets the game with the same configuration
  ///
  /// Creates a fresh game state with:
  /// - Empty board
  /// - Same configuration
  /// - New start time
  /// - Current player reset to [GameConfig.firstPlayer]
  GameState resetGame(GameState state) {
    return createNewGame(state.config);
  }
}
