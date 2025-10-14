import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Home page - top-level screen with no back button
///
/// As specified in LWI-151, the home screen is the top-level navigation point
/// and should not have a back button. Users can access all main features from here.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No leading widget in AppBar - home screen has no back button
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe'),
        // Explicitly set automaticallyImplyLeading to false to ensure no back button
        automaticallyImplyLeading: false,
      ),
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
            // Navigation buttons for main features
            ElevatedButton(
              onPressed: () {
                context.go('/ai-select');
              },
              child: const Text('Single Player'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/game');
              },
              child: const Text('Two Player'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                context.go('/history');
              },
              child: const Text('Game History'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                context.go('/settings');
              },
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
