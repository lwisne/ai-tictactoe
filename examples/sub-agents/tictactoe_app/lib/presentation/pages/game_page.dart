import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/exit_game_dialog.dart';
import '../widgets/game_board_widget.dart';

/// Game page with 3x3 game board and exit confirmation
///
/// Features:
/// - 3x3 responsive game board with Material 3 design
/// - Turn indicator showing current player
/// - Exit confirmation on back button press
/// - Handles both AppBar and system back buttons
///
/// Implementation notes:
/// - Currently uses local state for demonstration
/// - Future integration with GameBloc for state management
/// - Follows Clean Architecture principles
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Temporary state for demonstration - will be moved to BLoC
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  bool _isGameOver = false;

  void _handleCellTap(int index) {
    if (_board[index].isEmpty && !_isGameOver) {
      setState(() {
        _board[index] = _currentPlayer;
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      });
    }
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _isGameOver = false;
    });
  }

  /// Handles back button press with exit confirmation
  ///
  /// Shows exit game dialog and returns true to allow navigation if user
  /// confirms, or false to prevent navigation if user cancels.
  Future<bool> _handleBackPress(BuildContext context) async {
    final shouldExit = await ExitGameDialog.show(context);

    if (shouldExit && context.mounted) {
      // User confirmed exit, navigate to home
      context.go('/');
    }

    // Return false to prevent automatic pop since we handle navigation manually
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent automatic pop
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        // Only handle if pop didn't already happen
        if (!didPop && context.mounted) {
          await _handleBackPress(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Game'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackPress(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Turn indicator
                Text(
                  'Current Player: $_currentPlayer',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: _currentPlayer == 'X'
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                  semanticsLabel: 'Current player is $_currentPlayer',
                ),
                const SizedBox(height: 24),

                // Game board
                Expanded(
                  child: GameBoardWidget(
                    board: _board,
                    onCellTap: _handleCellTap,
                    isGameOver: _isGameOver,
                  ),
                ),

                const SizedBox(height: 24),

                // Reset button
                FilledButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Game'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
