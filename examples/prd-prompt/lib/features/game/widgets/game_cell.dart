import 'package:flutter/material.dart';
import '../models/player.dart';

class GameCell extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;
  final bool isWinningCell;
  final bool isEnabled;

  const GameCell({
    super.key,
    required this.player,
    this.onTap,
    this.isWinningCell = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isEnabled && player.isEmpty ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isWinningCell
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isWinningCell
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: player.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    player.symbol,
                    key: ValueKey(player),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: player.isX
                          ? colorScheme.primary
                          : colorScheme.secondary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}