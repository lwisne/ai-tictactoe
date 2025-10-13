import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/game_cubit.dart';
import '../cubits/score_cubit.dart';
import '../cubits/settings_cubit.dart';
import '../models/board_position.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/settings.dart';
import '../services/ai_easy_service.dart';
import '../services/ai_hard_service.dart';
import '../services/ai_medium_service.dart';
import '../services/game_service.dart';
import '../services/settings_service.dart';
import '../widgets/game_board.dart';

enum GameMode { twoPlayer, vsAi }

/// Main game page with 2-player or AI opponent tic-tac-toe
class GamePage extends StatelessWidget {
  final GameMode gameMode;

  const GamePage({
    super.key,
    required this.gameMode,
  });

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

        final settingsService = SettingsService(snapshot.data!);

        return BlocProvider(
          create: (_) => SettingsCubit(settingsService),
          child: BlocProvider(
            create: (_) => GameCubit(GameService()),
            child: _GameView(gameMode: gameMode),
          ),
        );
      },
    );
  }
}

class _GameView extends StatefulWidget {
  final GameMode gameMode;

  const _GameView({required this.gameMode});

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  bool _isAiThinking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.gameMode == GameMode.twoPlayer
              ? '2 Player Mode'
              : 'vs AI',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GameCubit>().resetGame(),
            tooltip: 'Reset Game',
          ),
        ],
      ),
      body: BlocConsumer<GameCubit, GameState>(
        listener: (context, state) {
          // Show game over dialog
          if (state.isGameOver) {
            _showGameOverDialog(context, state);
          }
          // Make AI move if it's AI's turn
          else if (widget.gameMode == GameMode.vsAi &&
              state.currentPlayer == Player.o &&
              !_isAiThinking) {
            _makeAiMove(context, state);
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Current player indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildStatusText(context, state),
              ),

              // Game board
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: GameBoard(
                      board: state.board,
                      onCellTapped: _isAiThinking
                          ? null
                          : (position) {
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
    );
  }

  Widget _buildStatusText(BuildContext context, GameState state) {
    if (_isAiThinking) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'AI is thinking...',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      );
    }

    if (state.isGameOver) {
      final gameService = GameService();
      final winner = gameService.getWinner(state);
      if (winner != null) {
        return Text(
          'Player ${winner.symbol} Wins!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        );
      } else {
        return Text(
          'Draw!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        );
      }
    }

    return Text(
      'Current Player: ${state.currentPlayer.symbol}',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }

  Future<void> _makeAiMove(BuildContext context, GameState state) async {
    setState(() => _isAiThinking = true);

    // Small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final settings = context.read<SettingsCubit>().state;
    final gameService = GameService();

    // Get AI move based on difficulty
    final BoardPosition move;
    switch (settings.aiDifficulty) {
      case AiDifficulty.easy:
        final aiService = AiEasyService(gameService);
        move = aiService.getMove(state);
        break;
      case AiDifficulty.medium:
        final aiService = AiMediumService(gameService);
        move = aiService.getMove(state);
        break;
      case AiDifficulty.hard:
        final aiService = AiHardService(gameService);
        move = aiService.getMove(state);
        break;
    }

    if (mounted) {
      context.read<GameCubit>().makeMove(move);
      setState(() => _isAiThinking = false);
    }
  }

  void _showGameOverDialog(BuildContext context, GameState state) {
    final gameService = GameService();
    final winner = gameService.getWinner(state);

    // Record the score
    if (winner != null) {
      context.read<ScoreCubit>().recordWin(winner);
    } else {
      context.read<ScoreCubit>().recordDraw();
    }

    // Small delay so the last move is visible
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            winner != null
                ? (winner == Player.x ? 'You Win!' : 'AI Wins!')
                : 'Draw!',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                winner == Player.x
                    ? Icons.celebration
                    : winner == Player.o
                        ? Icons.smart_toy
                        : Icons.handshake,
                size: 64,
                color: winner == Player.x
                    ? Colors.green
                    : winner == Player.o
                        ? Colors.red
                        : Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                winner != null
                    ? (winner == Player.x
                        ? 'Congratulations!'
                        : widget.gameMode == GameMode.vsAi
                            ? 'Better luck next time!'
                            : 'Player O wins!')
                    : 'Well played!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Menu'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<GameCubit>().resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    });
  }
}
