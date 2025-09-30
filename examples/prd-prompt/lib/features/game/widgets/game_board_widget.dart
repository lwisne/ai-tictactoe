import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';
import 'game_cell.dart';

class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        return AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final isWinningCell =
                  state.result.winningLine?.contains(index) ?? false;

              return GameCell(
                player: state.board.cells[index],
                isWinningCell: isWinningCell,
                isEnabled: state.canMakeMove,
                onTap: () {
                  context.read<GameCubit>().makeMove(index);
                },
              );
            },
          ),
        );
      },
    );
  }
}