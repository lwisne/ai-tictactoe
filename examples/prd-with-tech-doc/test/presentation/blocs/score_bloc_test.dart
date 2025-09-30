import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/presentation/blocs/score_bloc/score_bloc.dart';
import 'package:tic_tac_toe/presentation/blocs/score_bloc/score_event.dart';
import 'package:tic_tac_toe/presentation/blocs/score_bloc/score_state.dart';

import '../../helpers/builders.dart';
import '../../helpers/mocks.dart';

void main() {
  late ScoreBloc bloc;
  late MockScoreRepository mockRepository;

  setUp(() {
    mockRepository = MockScoreRepository();
    bloc = ScoreBloc(scoreRepository: mockRepository);
  });

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const Score());
  });

  tearDown(() {
    bloc.close();
  });

  group('ScoreBloc', () {
    test('initial state is ScoreInitial', () {
      expect(bloc.state, equals(const ScoreInitial()));
    });

    group('LoadScore', () {
      blocTest<ScoreBloc, ScoreState>(
        'should emit [ScoreLoading, ScoreLoaded] when LoadScore is added successfully',
        build: () {
          final score = TestDataBuilder.createScore(
            wins: 5,
            losses: 3,
            draws: 2,
          );

          when(() => mockRepository.loadScore())
              .thenAnswer((_) async => score);

          return bloc;
        },
        act: (bloc) => bloc.add(const LoadScore()),
        expect: () => [
          const ScoreLoading(),
          isA<ScoreLoaded>()
              .having((s) => s.score.wins, 'wins', 5)
              .having((s) => s.score.losses, 'losses', 3)
              .having((s) => s.score.draws, 'draws', 2),
        ],
        verify: (_) {
          verify(() => mockRepository.loadScore()).called(1);
        },
      );

      blocTest<ScoreBloc, ScoreState>(
        'should emit [ScoreLoading, ScoreLoaded] with empty score when no saved data',
        build: () {
          when(() => mockRepository.loadScore())
              .thenAnswer((_) async => const Score());

          return bloc;
        },
        act: (bloc) => bloc.add(const LoadScore()),
        expect: () => [
          const ScoreLoading(),
          isA<ScoreLoaded>()
              .having((s) => s.score.wins, 'wins', 0)
              .having((s) => s.score.losses, 'losses', 0)
              .having((s) => s.score.draws, 'draws', 0),
        ],
      );

      blocTest<ScoreBloc, ScoreState>(
        'should emit [ScoreLoading, ScoreError] when LoadScore fails',
        build: () {
          when(() => mockRepository.loadScore())
              .thenThrow(Exception('Failed to load score'));

          return bloc;
        },
        act: (bloc) => bloc.add(const LoadScore()),
        expect: () => [
          const ScoreLoading(),
          isA<ScoreError>()
              .having((s) => s.message, 'message', contains('Failed to load')),
        ],
      );
    });

    group('IncrementWins', () {
      blocTest<ScoreBloc, ScoreState>(
        'should emit ScoreLoaded with incremented wins',
        build: () {
          final currentScore = TestDataBuilder.createScore(wins: 5);
          final newScore = TestDataBuilder.createScore(wins: 6);

          when(() => mockRepository.incrementWins(any()))
              .thenAnswer((_) async => newScore);

          return bloc;
        },
        seed: () => ScoreLoaded(TestDataBuilder.createScore(wins: 5)),
        act: (bloc) => bloc.add(const IncrementWins()),
        expect: () => [
          isA<ScoreLoaded>().having((s) => s.score.wins, 'wins', 6),
        ],
        verify: (_) {
          verify(() => mockRepository.incrementWins(any())).called(1);
        },
      );

      blocTest<ScoreBloc, ScoreState>(
        'should not emit new state when current state is not ScoreLoaded',
        build: () => bloc,
        seed: () => const ScoreInitial(),
        act: (bloc) => bloc.add(const IncrementWins()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockRepository.incrementWins(any()));
        },
      );

      blocTest<ScoreBloc, ScoreState>(
        'should emit ScoreError when increment fails',
        build: () {
          when(() => mockRepository.incrementWins(any()))
              .thenThrow(Exception('Failed to save'));

          return bloc;
        },
        seed: () => ScoreLoaded(TestDataBuilder.createScore()),
        act: (bloc) => bloc.add(const IncrementWins()),
        expect: () => [
          isA<ScoreError>()
              .having((s) => s.message, 'message', contains('Failed to save')),
        ],
      );
    });

    group('IncrementLosses', () {
      blocTest<ScoreBloc, ScoreState>(
        'should emit ScoreLoaded with incremented losses',
        build: () {
          final currentScore = TestDataBuilder.createScore(losses: 3);
          final newScore = TestDataBuilder.createScore(losses: 4);

          when(() => mockRepository.incrementLosses(any()))
              .thenAnswer((_) async => newScore);

          return bloc;
        },
        seed: () => ScoreLoaded(TestDataBuilder.createScore(losses: 3)),
        act: (bloc) => bloc.add(const IncrementLosses()),
        expect: () => [
          isA<ScoreLoaded>().having((s) => s.score.losses, 'losses', 4),
        ],
        verify: (_) {
          verify(() => mockRepository.incrementLosses(any())).called(1);
        },
      );

      blocTest<ScoreBloc, ScoreState>(
        'should not emit new state when current state is not ScoreLoaded',
        build: () => bloc,
        seed: () => const ScoreLoading(),
        act: (bloc) => bloc.add(const IncrementLosses()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockRepository.incrementLosses(any()));
        },
      );

      blocTest<ScoreBloc, ScoreState>(
        'should emit ScoreError when increment fails',
        build: () {
          when(() => mockRepository.incrementLosses(any()))
              .thenThrow(Exception('Storage error'));

          return bloc;
        },
        seed: () => ScoreLoaded(TestDataBuilder.createScore()),
        act: (bloc) => bloc.add(const IncrementLosses()),
        expect: () => [
          isA<ScoreError>()
              .having((s) => s.message, 'message', contains('Storage error')),
        ],
      );
    });

    group('IncrementDraws', () {
      blocTest<ScoreBloc, ScoreState>(
        'should emit ScoreLoaded with incremented draws',
        build: () {
          final currentScore = TestDataBuilder.createScore(draws: 2);
          final newScore = TestDataBuilder.createScore(draws: 3);

          when(() => mockRepository.incrementDraws(any()))
              .thenAnswer((_) async => newScore);

          return bloc;
        },
        seed: () => ScoreLoaded(TestDataBuilder.createScore(draws: 2)),
        act: (bloc) => bloc.add(const IncrementDraws()),
        expect: () => [
          isA<ScoreLoaded>().having((s) => s.score.draws, 'draws', 3),
        ],
        verify: (_) {
          verify(() => mockRepository.incrementDraws(any())).called(1);
        },
      );

      blocTest<ScoreBloc, ScoreState>(
        'should not emit new state when current state is not ScoreLoaded',
        build: () => bloc,
        seed: () => const ScoreError('Error'),
        act: (bloc) => bloc.add(const IncrementDraws()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockRepository.incrementDraws(any()));
        },
      );

      blocTest<ScoreBloc, ScoreState>(
        'should emit ScoreError when increment fails',
        build: () {
          when(() => mockRepository.incrementDraws(any()))
              .thenThrow(Exception('Database error'));

          return bloc;
        },
        seed: () => ScoreLoaded(TestDataBuilder.createScore()),
        act: (bloc) => bloc.add(const IncrementDraws()),
        expect: () => [
          isA<ScoreError>().having(
            (s) => s.message,
            'message',
            contains('Database error'),
          ),
        ],
      );
    });

    group('ResetScore', () {
      blocTest<ScoreBloc, ScoreState>(
        'should emit ScoreLoaded with empty score',
        build: () {
          when(() => mockRepository.resetScore()).thenAnswer((_) async => {});

          return bloc;
        },
        seed: () => ScoreLoaded(
          TestDataBuilder.createScore(wins: 10, losses: 5, draws: 3),
        ),
        act: (bloc) => bloc.add(const ResetScore()),
        expect: () => [
          isA<ScoreLoaded>()
              .having((s) => s.score.wins, 'wins', 0)
              .having((s) => s.score.losses, 'losses', 0)
              .having((s) => s.score.draws, 'draws', 0),
        ],
        verify: (_) {
          verify(() => mockRepository.resetScore()).called(1);
        },
      );

      blocTest<ScoreBloc, ScoreState>(
        'should emit ScoreError when reset fails',
        build: () {
          when(() => mockRepository.resetScore())
              .thenThrow(Exception('Failed to reset'));

          return bloc;
        },
        seed: () => ScoreLoaded(TestDataBuilder.createScore()),
        act: (bloc) => bloc.add(const ResetScore()),
        expect: () => [
          isA<ScoreError>()
              .having((s) => s.message, 'message', contains('Failed to reset')),
        ],
      );

      blocTest<ScoreBloc, ScoreState>(
        'should work from any state',
        build: () {
          when(() => mockRepository.resetScore()).thenAnswer((_) async => {});

          return bloc;
        },
        seed: () => const ScoreInitial(),
        act: (bloc) => bloc.add(const ResetScore()),
        expect: () => [
          isA<ScoreLoaded>()
              .having((s) => s.score, 'score', const Score()),
        ],
      );
    });

    group('Multiple Operations', () {
      blocTest<ScoreBloc, ScoreState>(
        'should handle multiple increments correctly',
        build: () {
          when(() => mockRepository.incrementWins(any()))
              .thenAnswer((invocation) async {
            final current = invocation.positionalArguments[0] as Score;
            return current.copyWith(wins: current.wins + 1);
          });
          when(() => mockRepository.incrementLosses(any()))
              .thenAnswer((invocation) async {
            final current = invocation.positionalArguments[0] as Score;
            return current.copyWith(losses: current.losses + 1);
          });
          when(() => mockRepository.incrementDraws(any()))
              .thenAnswer((invocation) async {
            final current = invocation.positionalArguments[0] as Score;
            return current.copyWith(draws: current.draws + 1);
          });

          return bloc;
        },
        seed: () => const ScoreLoaded(Score()),
        act: (bloc) => bloc
          ..add(const IncrementWins())
          ..add(const IncrementWins())
          ..add(const IncrementLosses())
          ..add(const IncrementDraws()),
        expect: () => [
          isA<ScoreLoaded>().having((s) => s.score.wins, 'wins after 1st', 1),
          isA<ScoreLoaded>().having((s) => s.score.wins, 'wins after 2nd', 2),
          isA<ScoreLoaded>()
              .having((s) => s.score.wins, 'wins', 2)
              .having((s) => s.score.losses, 'losses', 1),
          isA<ScoreLoaded>()
              .having((s) => s.score.wins, 'wins', 2)
              .having((s) => s.score.losses, 'losses', 1)
              .having((s) => s.score.draws, 'draws', 1),
        ],
      );
    });
  });
}
