import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../../domain/models/game_config.dart';
import '../../domain/models/game_result.dart';
import '../../domain/models/position.dart';
import '../blocs/game_bloc/game_bloc.dart';
import '../blocs/game_bloc/game_event.dart';
import '../blocs/game_bloc/game_state.dart';
import '../blocs/score_bloc/score_bloc.dart';
import '../blocs/score_bloc/score_event.dart';
import '../extensions/game_result_extensions.dart';
import '../extensions/player_extensions.dart';
import '../widgets/game_board.dart';

class GamePage extends StatelessWidget {
  final GameConfig? config;

  const GamePage({super.key, this.config});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameBlocState>(
      listenWhen: (previous, current) {
        // Only initialize once when transitioning from Initial
        return previous is GameInitial && current is! GameInitial;
      },
      listener: (context, state) {
        // Game already started, do nothing
      },
      child: Builder(
        builder: (context) {
          // Start game if config is provided and game is initial
          final currentState = context.watch<GameBloc>().state;
          if (config != null && currentState is GameInitial) {
            // Schedule the event for next frame to avoid calling during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<GameBloc>().add(StartNewGame(config!));
            });
          }

          return BlocConsumer<GameBloc, GameBlocState>(
        listener: (context, state) {
          if (state is GameFinished) {
            _handleGameFinished(context, state);
          }
        },
        builder: (context, state) {
          if (state is GameInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final gameState = state is GameInProgress
              ? state.gameState
              : state is GameFinished
                  ? state.gameState
                  : state is AiThinking
                      ? state.gameState
                      : null;

          if (gameState == null) {
            return const Scaffold(
              body: Center(child: Text('No game state')),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                gameState.config.gameMode.displayName,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<GameBloc>().add(const ResetGame()),
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildStatusBar(context, state, gameState),
                ),
                Expanded(
                  child: GameBoard(
                    gameState: gameState,
                    onCellTap: (position) => _onCellTap(context, position, state),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildActionButtons(context, state),
                ),
              ],
            ),
          );
        },
      );
        },
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, GameBlocState state, gameState) {
    final colorScheme = Theme.of(context).colorScheme;

    String statusText;
    Color statusColor;

    if (state is AiThinking) {
      statusText = 'AI is thinking...';
      statusColor = colorScheme.secondary;
    } else if (state is GameFinished) {
      statusText = GameResultDisplay.displayText(gameState.result, gameState.winner ?? gameState.currentPlayer);
      statusColor = colorScheme.primary;
    } else {
      statusText = "Current: ${PlayerDisplay.symbol(gameState.currentPlayer)}";
      statusColor = colorScheme.onSurface;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              statusText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (state is GameInProgress || state is AiThinking)
              Text(
                '${gameState.moveHistory.length} moves',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameBlocState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (state is GameInProgress || state is GameFinished)
          OutlinedButton.icon(
            onPressed: state is GameInProgress
                ? () => context.read<GameBloc>().add(const UndoMove())
                : null,
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
          ),
        FilledButton.icon(
          onPressed: () => context.read<GameBloc>().add(const ResetGame()),
          icon: const Icon(Icons.refresh),
          label: const Text('New Game'),
        ),
      ],
    );
  }

  void _onCellTap(BuildContext context, Position position, GameBlocState state) {
    if (state is! GameInProgress) return;

    // Add haptic feedback
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 50);
      }
    });

    context.read<GameBloc>().add(MakeMove(position));
  }

  void _handleGameFinished(BuildContext context, GameFinished state) {
    final gameState = state.gameState;
    final scoreBloc = context.read<ScoreBloc>();

    // Update score
    if (gameState.result == GameResult.win) {
      scoreBloc.add(const IncrementWins());
    } else if (gameState.result == GameResult.loss) {
      scoreBloc.add(const IncrementLosses());
    } else if (gameState.result == GameResult.draw) {
      scoreBloc.add(const IncrementDraws());
    }

    // Show result dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              GameResultDisplay.displayText(gameState.result, gameState.winner ?? gameState.currentPlayer),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  gameState.result == GameResult.win
                      ? Icons.emoji_events
                      : gameState.result == GameResult.draw
                          ? Icons.handshake
                          : Icons.sentiment_neutral,
                  size: 64,
                  color: gameState.result == GameResult.win
                      ? Colors.amber
                      : gameState.result == GameResult.draw
                          ? Colors.grey
                          : Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Moves: ${gameState.moveHistory.length}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Time: ${gameState.elapsedTime.inSeconds}s',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.pop();
                },
                child: const Text('Home'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<GameBloc>().add(const ResetGame());
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
        );
      }
    });
  }
}
