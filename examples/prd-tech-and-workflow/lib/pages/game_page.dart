import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/game_cubit.dart';
import '../blocs/score_cubit.dart';
import '../models/board_position.dart';
import '../models/game_state.dart';
import '../models/score.dart';
import '../services/game_service.dart';
import '../services/score_service.dart';
import '../widgets/game_board.dart';

/// Main game page with 2-player tic-tac-toe
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => GameCubit(GameService())),
            BlocProvider(create: (_) => ScoreCubit(ScoreService(snapshot.data!))),
          ],
          child: const _GameView(),
        );
      },
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    final gameService = GameService();

    return BlocListener<GameCubit, GameState>(
      listener: (context, state) {
        if (state.isGameOver) {
          final winner = gameService.getWinner(state);
          final isDraw = gameService.isDraw(state);

          if (winner != null) {
            context.read<ScoreCubit>().recordWin(winner);
          } else if (isDraw) {
            context.read<ScoreCubit>().recordDraw();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tic-Tac-Toe'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<GameCubit>().resetGame(),
              tooltip: 'Reset Game',
            ),
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () => context.read<ScoreCubit>().resetScores(),
              tooltip: 'Reset Scores',
            ),
          ],
        ),
        body: BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Scores display
                BlocBuilder<ScoreCubit, Score>(
                  builder: (context, score) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ScoreCard(label: 'X Wins', value: score.xWins),
                          _ScoreCard(label: 'Draws', value: score.draws),
                          _ScoreCard(label: 'O Wins', value: score.oWins),
                        ],
                      ),
                    );
                  },
                ),

                // Current player indicator
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Current Player: ${state.currentPlayer.symbol}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),

                // Game board
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: GameBoard(
                        board: state.board,
                        onCellTapped: (position) {
                          context.read<GameCubit>().makeMove(position);
                        },
                      ),
                    ),
                  ),
                ),

                // Reset button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FilledButton.icon(
                    onPressed: () => context.read<GameCubit>().resetGame(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Game'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      ),
    );
  }
}
