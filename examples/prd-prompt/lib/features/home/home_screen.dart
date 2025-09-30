import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../game/models/game_mode.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'Tic-Tac-Toe',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your game mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 48),

                // Game Mode Buttons
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      context.go('/game', extra: {
                        'gameMode': GameMode.twoPlayer,
                      });
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('Two Player'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      _showDifficultyDialog(context);
                    },
                    icon: const Icon(Icons.smart_toy),
                    label: const Text('vs AI'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Difficulty'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AiDifficulty.values.map((difficulty) {
              return ListTile(
                title: Text(difficulty.displayName),
                subtitle: Text(_getDifficultyDescription(difficulty)),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  context.go('/game', extra: {
                    'gameMode': GameMode.singlePlayer,
                    'aiDifficulty': difficulty,
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getDifficultyDescription(AiDifficulty difficulty) {
    switch (difficulty) {
      case AiDifficulty.easy:
        return 'Random moves - perfect for beginners';
      case AiDifficulty.medium:
        return 'Blocks obvious moves - moderate challenge';
      case AiDifficulty.hard:
        return 'Optimal play - nearly unbeatable';
    }
  }
}