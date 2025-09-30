import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'cubit/game_cubit.dart';
import 'cubit/game_state.dart';
import 'models/game_mode.dart';
import 'models/game_result.dart';
import 'widgets/game_board_widget.dart';

class GameScreen extends StatelessWidget {
  final GameMode gameMode;
  final AiDifficulty? aiDifficulty;

  const GameScreen({
    super.key,
    required this.gameMode,
    this.aiDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameCubit(
        gameMode: gameMode,
        aiDifficulty: aiDifficulty,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Expanded(
                child: Center(
                  child: GameBoardWidget(),
                ),
              ),
              _buildBottomSection(context),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    if (gameMode.isSinglePlayer) {
      return 'vs AI (${aiDifficulty?.displayName ?? 'Easy'})';
    }
    return 'Two Player';
  }

  Widget _buildBottomSection(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) {
        if (state.isGameOver) {
          _showGameOverDialog(context, state);
        }
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (state.isAiThinking)
                const CircularProgressIndicator()
              else
                Text(
                  _getStatusText(state),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<GameCubit>().resetGame();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Game'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(GameState state) {
    if (state.isAiThinking) {
      return 'AI is thinking...';
    }

    if (state.isGameOver) {
      if (state.result.status == GameStatus.draw) {
        return 'It\'s a Draw!';
      }
      return '${state.result.winner?.symbol} Wins!';
    }

    return '${state.board.currentPlayer.symbol}\'s Turn';
  }

  void _showGameOverDialog(BuildContext context, GameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(_getGameOverTitle(state)),
        content: Text(_getGameOverMessage(state)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<GameCubit>().resetGame();
            },
            child: const Text('Play Again'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/');
            },
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }

  String _getGameOverTitle(GameState state) {
    if (state.result.status == GameStatus.draw) {
      return 'Draw!';
    }
    return '${state.result.winner?.symbol} Wins!';
  }

  String _getGameOverMessage(GameState state) {
    if (state.result.status == GameStatus.draw) {
      return 'Good game! Nobody wins this time.';
    }

    if (gameMode.isSinglePlayer) {
      if (state.result.winner?.symbol == 'X') {
        return 'Congratulations! You beat the AI!';
      } else {
        return 'The AI wins! Try again?';
      }
    }

    return 'Congratulations to ${state.result.winner?.symbol}!';
  }
}