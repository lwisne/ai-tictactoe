import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/position.dart';

class BoardCell extends StatelessWidget {
  final Player player;
  final Position position;
  final bool isWinningCell;
  final VoidCallback onTap;

  const BoardCell({
    super.key,
    required this.player,
    required this.position,
    required this.isWinningCell,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: player == Player.none ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: isWinningCell
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surface,
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            player.symbol,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: player == Player.x
                  ? colorScheme.primary
                  : player == Player.o
                      ? colorScheme.secondary
                      : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
