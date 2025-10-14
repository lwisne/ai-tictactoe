import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// AI Difficulty Selection page with standard back button behavior
///
/// As specified in LWI-151, this page should have a back button that returns
/// to the previous screen (home) without confirmation.
class AiDifficultyPage extends StatelessWidget {
  const AiDifficultyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select AI Difficulty'),
        // Standard back button - automatically provided by Flutter
        // Uses go_router's navigation when pressed
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 100, color: Colors.purple),
            const SizedBox(height: 24),
            const Text(
              'AI Difficulty Selection',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose your challenge level',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            // Difficulty selection buttons that will navigate to game
            ElevatedButton(
              onPressed: () {
                context.go('/game');
              },
              child: const Text('Easy'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/game');
              },
              child: const Text('Medium'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/game');
              },
              child: const Text('Hard'),
            ),
          ],
        ),
      ),
    );
  }
}
