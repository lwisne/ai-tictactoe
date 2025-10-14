import 'package:flutter/material.dart';

/// AI Difficulty Selection page - placeholder
/// Will be implemented with actual difficulty selection in future tasks
class AiDifficultyPage extends StatelessWidget {
  const AiDifficultyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select AI Difficulty'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            // Placeholder difficulty buttons
            ElevatedButton(
              onPressed: () {
                // Will start game with easy AI
              },
              child: const Text('Easy'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Will start game with medium AI
              },
              child: const Text('Medium'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Will start game with hard AI
              },
              child: const Text('Hard'),
            ),
          ],
        ),
      ),
    );
  }
}
