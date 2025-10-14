import 'package:flutter/material.dart';

/// Game Details page - placeholder for viewing historical games
/// Will be implemented with actual game replay in future tasks
class GameDetailsPage extends StatelessWidget {
  /// The ID of the game to display
  final String gameId;

  const GameDetailsPage({required this.gameId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
