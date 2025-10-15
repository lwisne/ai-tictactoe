import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubits/game_ui_cubit.dart';
import '../widgets/exit_game_dialog.dart';
import '../widgets/game_board_widget.dart';
import '../../core/di/injection.dart';

/// Game page with 3x3 game board and exit confirmation
///
/// Features:
/// - 3x3 responsive game board with Material 3 design
/// - Turn indicator showing current player
/// - Exit confirmation on back button press
/// - Handles both AppBar and system back buttons
///
/// Implementation notes:
/// - Uses GameUICubit for state management (follows architecture rules)
/// - Future integration with GameBloc+GameService for business logic
/// - Follows Clean Architecture principles with StatelessWidget
class GamePage extends StatelessWidget {
  const GamePage({super.key});

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
    return BlocProvider(
      create: (_) => getIt<GameUICubit>(),
      child: BlocBuilder<GameUICubit, GameUIState>(
        builder: (context, state) {
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
                        'Current Player: ${state.currentPlayer}',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: state.currentPlayer == 'X'
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                        semanticsLabel:
                            'Current player is ${state.currentPlayer}',
                      ),
                      const SizedBox(height: 24),

                      // Game board
                      Expanded(
                        child: GameBoardWidget(
                          board: state.board,
                          onCellTap: (index) {
                            context.read<GameUICubit>().handleCellTap(index);
                          },
                          isGameOver: state.isGameOver,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Reset button
                      FilledButton.icon(
                        onPressed: () {
                          context.read<GameUICubit>().resetGame();
                        },
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
        },
      ),
    );
  }
}
