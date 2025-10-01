import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/blocs/score_cubit.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/models/score.dart';
import 'package:tic_tac_toe/services/score_service.dart';

void main() {
  group('ScoreCubit', () {
    late SharedPreferences prefs;
    late ScoreService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = ScoreService(prefs);
    });

    test('initial state loads from service', () async {
      // Save some scores first
      await service.saveScore(const Score(xWins: 3, oWins: 2, draws: 1));

      final cubit = ScoreCubit(service);

      // Wait for async initialization
      await Future.delayed(Duration.zero);

      expect(cubit.state, const Score(xWins: 3, oWins: 2, draws: 1));
      await cubit.close();
    });

    blocTest<ScoreCubit, Score>(
      'recordWin for Player.x emits updated score',
      build: () => ScoreCubit(service),
      act: (cubit) => cubit.recordWin(Player.x),
      expect: () => [const Score(xWins: 1, oWins: 0, draws: 0)],
    );

    blocTest<ScoreCubit, Score>(
      'recordWin for Player.o emits updated score',
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
      'resetScores emits initial score',
      build: () => ScoreCubit(service),
      seed: () => const Score(xWins: 5, oWins: 3, draws: 2),
      act: (cubit) => cubit.resetScores(),
      expect: () => [Score.initial()],
    );

    blocTest<ScoreCubit, Score>(
      'multiple wins accumulate correctly',
      build: () => ScoreCubit(service),
      act: (cubit) async {
        await cubit.recordWin(Player.x);
        await cubit.recordWin(Player.o);
        await cubit.recordWin(Player.x);
      },
      expect: () => [
        const Score(xWins: 1, oWins: 0, draws: 0),
        const Score(xWins: 1, oWins: 1, draws: 0),
        const Score(xWins: 2, oWins: 1, draws: 0),
      ],
    );

    blocTest<ScoreCubit, Score>(
      'mixed game results accumulate correctly',
      build: () => ScoreCubit(service),
      act: (cubit) async {
        await cubit.recordWin(Player.x);
        await cubit.recordDraw();
        await cubit.recordWin(Player.o);
        await cubit.recordWin(Player.x);
      },
      expect: () => [
        const Score(xWins: 1, oWins: 0, draws: 0),
        const Score(xWins: 1, oWins: 0, draws: 1),
        const Score(xWins: 1, oWins: 1, draws: 1),
        const Score(xWins: 2, oWins: 1, draws: 1),
      ],
    );

    test('loadScores emits loaded score', () async {
      // Save some scores
      await service.saveScore(const Score(xWins: 10, oWins: 5, draws: 3));

      final cubit = ScoreCubit(service);

      // Initial load happens in constructor
      await Future.delayed(Duration.zero);
      expect(cubit.state.xWins, 10);

      // Manual load should also work
      cubit.loadScores();
      await Future.delayed(Duration.zero);
      expect(cubit.state.xWins, 10);

      await cubit.close();
    });

    test('scores persist across cubit instances', () async {
      final cubit1 = ScoreCubit(service);
      await cubit1.recordWin(Player.x);
      await cubit1.recordWin(Player.o);
      await cubit1.recordDraw();
      await cubit1.close();

      // Create new cubit - should load persisted scores
      final cubit2 = ScoreCubit(service);
      await Future.delayed(Duration.zero);

      expect(cubit2.state.xWins, 1);
      expect(cubit2.state.oWins, 1);
      expect(cubit2.state.draws, 1);

      await cubit2.close();
    });
  });
}
