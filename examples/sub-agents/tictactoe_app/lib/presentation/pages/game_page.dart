import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/exit_game_dialog.dart';

/// Game page with exit confirmation on back button
///
/// Implements PopScope to intercept back button presses (both AppBar back
/// button and Android system back button) and show exit confirmation dialog.
///
/// Prevents accidental game exits as specified in LWI-151.
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
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videogame_asset, size: 100, color: Colors.green),
              SizedBox(height: 24),
              Text(
                'Game Page',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Game board will be implemented here',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                'Try pressing the back button to see exit confirmation',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
