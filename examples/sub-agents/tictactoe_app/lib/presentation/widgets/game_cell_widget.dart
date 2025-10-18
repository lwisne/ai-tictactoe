import 'package:flutter/material.dart';

/// A single cell in the Tic-Tac-Toe game board
///
/// Features:
/// - Minimum 56dp tap target (Material Design guideline)
/// - Large, clear X and O symbols (32sp+)
/// - Empty cells show subtle tappable indication
/// - Material 3 styling with ripple effect
/// - Accessibility labels for screen readers
/// - Supports light and dark themes
///
/// The cell automatically styles based on:
/// - Empty state: Shows subtle background with tap ripple
/// - X/O state: Shows large, bold symbol with no interaction
/// - Disabled state: No tap handling
class GameCellWidget extends StatelessWidget {
  /// The value of the cell ('', 'X', or 'O')
  final String value;

  /// The index of this cell (0-8)
  final int index;

  /// Callback when the cell is tapped
  ///
  /// If null, the cell is not tappable (already filled or game over)
  final VoidCallback? onTap;

  const GameCellWidget({
    super.key,
    required this.value,
    required this.index,
    this.onTap,
  });

  /// Get row number for accessibility (0-2)
  int get _row => index ~/ 3;

  /// Get column number for accessibility (0-2)
  int get _column => index % 3;

  /// Generate semantic label for screen readers
  String get _semanticLabel {
    final position = 'Row ${_row + 1}, Column ${_column + 1}';
    if (value.isEmpty) {
      return '$position, empty cell, tappable';
    } else {
      return '$position, $value';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isEmpty = value.isEmpty;
    final isTappable = onTap != null;

    // Color coding for X and O
    final symbolColor = value == 'X'
        ? colorScheme.primary
        : value == 'O'
        ? colorScheme.secondary
        : null;

    return Semantics(
      label: _semanticLabel,
      button: isTappable,
      enabled: isTappable,
      child: Material(
        color: isEmpty && isTappable
            ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: colorScheme.primary.withOpacity(0.2),
          highlightColor: colorScheme.primary.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant, width: 1),
            ),
            child: Center(
              child: isEmpty
                  ? isTappable
                        ? Icon(
                            Icons.add_circle_outline,
                            size: 24,
                            color: colorScheme.onSurface.withOpacity(0.2),
                          )
                        : const SizedBox.shrink()
                  : Text(
                      value,
                      style: textTheme.displayLarge?.copyWith(
                        color: symbolColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 40, // 40sp for extra clarity
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
