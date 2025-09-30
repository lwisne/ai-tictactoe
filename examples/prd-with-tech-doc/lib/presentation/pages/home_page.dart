import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/difficulty_level.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_mode.dart';
import '../../domain/entities/player.dart';
import '../../routes/app_router.dart';
import '../blocs/score_bloc/score_bloc.dart';
import '../blocs/score_bloc/score_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRouter.settings),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.grid_3x3,
                size: 100,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Tic-Tac-Toe',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 48),
              _buildScoreCard(context),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () => _showDifficultyDialog(context),
                icon: const Icon(Icons.person),
                label: const Text('Single Player'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _startTwoPlayerGame(context),
                icon: const Icon(Icons.people),
                label: const Text('Two Player'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ScoreBloc, ScoreState>(
      builder: (context, state) {
        if (state is ScoreLoaded) {
          final score = state.score;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Your Stats',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        context,
                        'Wins',
                        score.wins.toString(),
                        colorScheme.primary,
                      ),
                      _buildStatItem(
                        context,
                        'Losses',
                        score.losses.toString(),
                        colorScheme.error,
                      ),
                      _buildStatItem(
                        context,
                        'Draws',
                        score.draws.toString(),
                        colorScheme.secondary,
                      ),
                    ],
                  ),
                  if (score.totalGames > 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Win Rate: ${(score.winRate * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Select Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DifficultyLevel.values.map((difficulty) {
            return ListTile(
              title: Text(difficulty.displayName),
              subtitle: Text(difficulty.description),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _startSinglePlayerGame(context, difficulty);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _startSinglePlayerGame(BuildContext context, DifficultyLevel difficulty) {
    final config = GameConfig(
      gameMode: GameMode.singlePlayer,
      difficultyLevel: difficulty,
      firstPlayer: Player.x,
    );
    context.push(AppRouter.game, extra: config);
  }

  void _startTwoPlayerGame(BuildContext context) {
    final config = const GameConfig(
      gameMode: GameMode.twoPlayer,
      firstPlayer: Player.x,
    );
    context.push(AppRouter.game, extra: config);
  }
}
