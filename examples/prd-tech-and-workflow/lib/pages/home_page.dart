import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/score_cubit.dart';
import '../models/score.dart';
import 'game_page.dart';
import 'settings_page.dart';

/// Home screen with game mode selection
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
            tooltip: 'Settings',
          ),
        ],
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
                  'Choose Game Mode',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Score Display
                const _ScoreDisplay(),
                const SizedBox(height: 32),

                // Two Player Mode
                _GameModeCard(
                  icon: Icons.people,
                  title: '2 Player',
                  description: 'Play against a friend',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const GamePage(gameMode: GameMode.twoPlayer),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Single Player Mode
                _GameModeCard(
                  icon: Icons.computer,
                  title: 'vs AI',
                  description: 'Play against computer',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GamePage(gameMode: GameMode.vsAi),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Display current game scores with reset option
class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoreCubit, Score>(
      builder: (context, score) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ScoreStat(
                      label: 'X Wins',
                      value: score.xWins,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _ScoreStat(
                      label: 'Draws',
                      value: score.draws,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    _ScoreStat(
                      label: 'O Wins',
                      value: score.oWins,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
                if (score.totalGames > 0) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Reset Scores'),
                          content: const Text(
                            'Are you sure you want to reset all scores to zero?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<ScoreCubit>().resetScores();
                                Navigator.pop(dialogContext);
                              },
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Individual score statistic
class _ScoreStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _GameModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _GameModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
