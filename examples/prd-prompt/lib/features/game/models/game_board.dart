import 'package:equatable/equatable.dart';
import 'player.dart';
import 'game_result.dart';

class GameBoard extends Equatable {
  final List<Player> cells;
  final Player currentPlayer;

  const GameBoard({
    required this.cells,
    required this.currentPlayer,
  });

  factory GameBoard.initial() {
    return GameBoard(
      cells: List.filled(9, Player.none),
      currentPlayer: Player.x,
    );
  }

  // Winning combinations for 3x3 board
  static const List<List<int>> winningCombinations = [
    [0, 1, 2], // Top row
    [3, 4, 5], // Middle row
    [6, 7, 8], // Bottom row
    [0, 3, 6], // Left column
    [1, 4, 7], // Middle column
    [2, 5, 8], // Right column
    [0, 4, 8], // Diagonal top-left to bottom-right
    [2, 4, 6], // Diagonal top-right to bottom-left
  ];

  GameBoard makeMove(int index) {
    if (index < 0 || index >= 9 || cells[index] != Player.none) {
      return this;
    }

    final newCells = List<Player>.from(cells);
    newCells[index] = currentPlayer;

    return GameBoard(
      cells: newCells,
      currentPlayer: currentPlayer.opponent,
    );
  }

  GameResult checkGameResult() {
    // Check for winner
    for (final combination in winningCombinations) {
      final first = cells[combination[0]];
      if (first != Player.none &&
          cells[combination[1]] == first &&
          cells[combination[2]] == first) {
        return GameResult.won(first, combination);
      }
    }

    // Check for draw
    if (cells.every((cell) => cell != Player.none)) {
      return const GameResult.draw();
    }

    // Game is still playing
    return const GameResult.playing();
  }

  List<int> getAvailableMoves() {
    final moves = <int>[];
    for (int i = 0; i < cells.length; i++) {
      if (cells[i] == Player.none) {
        moves.add(i);
      }
    }
    return moves;
  }

  bool isValidMove(int index) {
    return index >= 0 && index < 9 && cells[index] == Player.none;
  }

  @override
  List<Object?> get props => [cells, currentPlayer];
}