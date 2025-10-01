import 'package:flutter/material.dart';
import 'game_page.dart';

/// Home/Menu screen with game mode selection
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Tic-Tac-Toe',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // 2-Player mode button
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GamePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('2 Player'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                const SizedBox(height: 16),

                // Single Player mode button (placeholder for AI)
                FilledButton.tonalIcon(
                  onPressed: () {
                    // TODO: Navigate to single player game when AI is implemented
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Single player mode coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Single Player'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                const SizedBox(height: 16),

                // Settings button (placeholder)
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to settings when implemented
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
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
