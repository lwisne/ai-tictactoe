import 'package:flutter/material.dart';

/// Home page - placeholder for mode selection
/// Will be implemented in future tasks
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic-Tac-Toe')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_3x3, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Tic-Tac-Toe',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a game mode to begin',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            // Placeholder buttons for navigation demonstration
            ElevatedButton(
              onPressed: () {
                // Will navigate to AI difficulty selection
              },
              child: const Text('Single Player'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Will navigate directly to game
              },
              child: const Text('Two Player'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // Will navigate to history
              },
              child: const Text('Game History'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                // Will navigate to settings
              },
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
