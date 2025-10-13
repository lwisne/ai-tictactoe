import 'package:flutter/material.dart';
import '../models/board_position.dart';
import '../models/player.dart';

/// Widget displaying the 3x3 game board
///
/// Follows architecture pattern: Pure widget with no business logic
class GameBoard extends StatelessWidget {
  final List<Player?> board;
  final Function(BoardPosition)? onCellTapped;

  const GameBoard({
    super.key,
    required this.board,
    required this.onCellTapped,
  }) : assert(board.length == 9);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return _GameCell(
            player: board[index],
            onTap: onCellTapped != null
                ? () => onCellTapped!(BoardPosition(index))
                : null,
          );
        },
      ),
    );
  }
}

/// Individual cell in the game board
class _GameCell extends StatelessWidget {
  final Player? player;
  final VoidCallback? onTap;

  const _GameCell({
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            player?.symbol ?? '',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: player == Player.x
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}
