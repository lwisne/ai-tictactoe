import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/cubits/score_cubit.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/models/score.dart';
import 'package:tic_tac_toe/services/score_service.dart';

void main() {
  group('ScoreCubit', () {
    late ScoreService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = ScoreService(prefs);
    });

    test('initial state is empty score', () {
      final cubit = ScoreCubit(service);
      expect(cubit.state, Score.empty());
    });

    blocTest<ScoreCubit, Score>(
      'recordWin for Player X emits updated score',
      build: () => ScoreCubit(service),
      act: (cubit) => cubit.recordWin(Player.x),
      expect: () => [const Score(xWins: 1, oWins: 0, draws: 0)],
    );

    blocTest<ScoreCubit, Score>(
      'recordWin for Player O emits updated score',
      build: () => ScoreCubit(service),
      act: (cubit) => cubit.recordWin(Player.o),
      expect: () => [const Score(xWins: 0, oWins: 1, draws: 0)],
    );

    blocTest<ScoreCubit, Score>(
      'recordDraw emits updated score',
      build: () => ScoreCubit(service),
      act: (cubit) => cubit.recordDraw(),
      expect: () => [const Score(xWins: 0, oWins: 0, draws: 1)],
    );

    blocTest<ScoreCubit, Score>(
      'multiple operations emit correct states',
      build: () => ScoreCubit(service),
      act: (cubit) async {
        await cubit.recordWin(Player.x);
        await cubit.recordWin(Player.x);
        await cubit.recordWin(Player.o);
        await cubit.recordDraw();
      },
      expect: () => [
        const Score(xWins: 1, oWins: 0, draws: 0),
        const Score(xWins: 2, oWins: 0, draws: 0),
        const Score(xWins: 2, oWins: 1, draws: 0),
        const Score(xWins: 2, oWins: 1, draws: 1),
      ],
    );

    blocTest<ScoreCubit, Score>(
      'resetScores emits empty score',
      build: () => ScoreCubit(service),
      seed: () => const Score(xWins: 5, oWins: 3, draws: 2),
      act: (cubit) => cubit.resetScores(),
      expect: () => [Score.empty()],
    );

    blocTest<ScoreCubit, Score>(
      'refresh emits score from service',
      build: () => ScoreCubit(service),
      act: (cubit) async {
        await service.recordWin(Player.x);
        cubit.refresh();
      },
      expect: () => [const Score(xWins: 1, oWins: 0, draws: 0)],
    );
  });
}
