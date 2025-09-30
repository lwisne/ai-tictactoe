import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/score_bloc/score_bloc.dart';
import '../blocs/score_bloc/score_event.dart';
import '../blocs/score_bloc/score_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildStatsSection(context),
          const Divider(),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        BlocBuilder<ScoreBloc, ScoreState>(
          builder: (context, state) {
            if (state is ScoreLoaded) {
              final score = state.score;
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: const Text('Wins'),
                    trailing: Text(
                      score.wins.toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.sentiment_dissatisfied),
                    title: const Text('Losses'),
                    trailing: Text(
                      score.losses.toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.handshake),
                    title: const Text('Draws'),
                    trailing: Text(
                      score.draws.toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.games),
                    title: const Text('Total Games'),
                    trailing: Text(
                      score.totalGames.toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (score.totalGames > 0)
                    ListTile(
                      leading: const Icon(Icons.percent),
                      title: const Text('Win Rate'),
                      trailing: Text(
                        '${(score.winRate * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FilledButton.icon(
                      onPressed: () => _showResetConfirmation(context),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Reset Statistics'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Version'),
          subtitle: Text('1.0.0'),
        ),
        const ListTile(
          leading: Icon(Icons.description),
          title: Text('Description'),
          subtitle: Text('A simple yet engaging Tic-Tac-Toe game with AI opponent'),
        ),
        const ListTile(
          leading: Icon(Icons.code),
          title: Text('Built with'),
          subtitle: Text('Flutter & Material 3'),
        ),
      ],
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Statistics?'),
        content: const Text(
          'This will permanently delete all your game statistics. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ScoreBloc>().add(const ResetScore());
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Statistics reset successfully')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
