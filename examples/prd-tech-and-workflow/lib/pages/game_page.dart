import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_cubit.dart';
import '../models/board_position.dart';
import '../models/game_state.dart';
import '../services/game_service.dart';
import '../widgets/game_board.dart';

/// Main game page with 2-player tic-tac-toe
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCubit(GameService()),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GameCubit>().resetGame(),
            tooltip: 'Reset Game',
          ),
        ],
      ),
      body: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
    );
  }
}
