import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Game Details page with standard back button behavior
///
/// As specified in LWI-151, this page should have a back button that returns
/// to the history list without confirmation.
class GameDetailsPage extends StatelessWidget {
  /// The ID of the game to display
  final String gameId;

  const GameDetailsPage({required this.gameId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
        // Standard back button - automatically provided by Flutter
        // Uses go_router's navigation when pressed, returns to history page
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 100, color: Colors.teal),
            const SizedBox(height: 24),
            const Text(
              'Game Details',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Game ID: $gameId',
              style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Game replay will be shown here',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
