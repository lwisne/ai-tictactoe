import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'game_cell_widget.dart';

/// A 3x3 game board widget for Tic-Tac-Toe
///
/// Features:
/// - Responsive grid layout with square cells
/// - Minimum 56dp tap targets as per Material Design guidelines
/// - Material 3 styling with borders and elevation
/// - Supports light and dark themes
/// - Accessibility labels for screen readers
///
/// The board adapts to available screen space while maintaining:
/// - Square aspect ratio for cells
/// - Visible grid lines
/// - Clear tap targets
///
/// Usage:
/// ```dart
/// GameBoardWidget(
///   board: ['', 'X', '', 'O', 'X', '', '', '', 'O'],
///   onCellTap: (index) => print('Cell $index tapped'),
/// )
/// ```
class GameBoardWidget extends StatelessWidget {
  /// The current state of the board (9 cells)
  ///
  /// Each element can be:
  /// - '' (empty)
  /// - 'X' (player X)
  /// - 'O' (player O)
  final List<String> board;

  /// Callback when a cell is tapped
  ///
  /// Receives the index of the tapped cell (0-8)
  final void Function(int index)? onCellTap;

  /// Whether the game is over (disables all cell interactions)
  final bool isGameOver;

  const GameBoardWidget({
    super.key,
    required this.board,
    this.onCellTap,
    this.isGameOver = false,
  }) : assert(board.length == 9, 'Board must have exactly 9 cells');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate board size to fit screen while maintaining minimum tap targets
          // Maximum board size is 90% of available width/height (whichever is smaller)
          final maxBoardSize = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth * 0.9
              : constraints.maxHeight * 0.9;

          // Minimum board size based on 56dp minimum tap targets
          // 56dp * 3 cells = 168dp minimum + borders
          const minBoardSize = 56.0 * 3 + 32.0; // Adding padding for borders

          // Use the larger of min size and calculated max size
          final boardSize = maxBoardSize > minBoardSize
              ? maxBoardSize
              : minBoardSize;

          return SizedBox(
            width: boardSize,
            height: boardSize,
            child: Semantics(
              label: 'Tic-Tac-Toe game board',
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outline, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  child: AspectRatio(
                    aspectRatio: 1.0, // Keep board square
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            childAspectRatio: 1.0, // Keep cells square
                          ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return GameCellWidget(
                          value: board[index],
                          index: index,
                          onTap: isGameOver || board[index].isNotEmpty
                              ? null
                              : () => onCellTap?.call(index),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
