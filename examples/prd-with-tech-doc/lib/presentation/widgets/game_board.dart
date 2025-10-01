import 'package:flutter/material.dart';
import '../../domain/models/game_state.dart' as domain;
import '../../domain/models/position.dart';
import 'board_cell.dart';

class GameBoard extends StatelessWidget {
  final domain.GameState gameState;
  final Function(Position) onCellTap;

  const GameBoard({
    super.key,
    required this.gameState,
    required this.onCellTap,
  });

  bool _isWinningCell(Position position) {
    if (gameState.winningLine == null) return false;
    return gameState.winningLine!.any(
      (p) => p.row == position.row && p.col == position.col,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final row = index ~/ 3;
            final col = index % 3;
            final position = Position(row: row, col: col);

            return BoardCell(
              player: gameState.board[row][col],
              position: position,
              isWinningCell: _isWinningCell(position),
              onTap: () => onCellTap(position),
            );
          },
        ),
      ),
    );
  }
}
