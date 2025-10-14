import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/data/repositories/game_mode_repository.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/presentation/cubits/game_mode_cubit.dart';

class MockGameModeRepository extends Mock implements GameModeRepository {}

void main() {
  late GameModeRepository mockRepository;
  late GameModeCubit gameModeCubit;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(GameMode.vsAi);
  });

  setUp(() {
    mockRepository = MockGameModeRepository();
    gameModeCubit = GameModeCubit(mockRepository);
  });

  tearDown(() {
    gameModeCubit.close();
  });

  group('GameModeState', () {
    test('should have null lastPlayedMode as default', () {
      const state = GameModeState();
      expect(state.lastPlayedMode, isNull);
      expect(state.isLoading, isFalse);
    });

    test('should support copyWith with mode', () {
      const state1 = GameModeState(lastPlayedMode: null);
      final state2 = state1.copyWith(lastPlayedMode: GameMode.vsAi);
      final state3 = state1.copyWith(isLoading: true);

      expect(state2.lastPlayedMode, GameMode.vsAi);
      expect(state2.isLoading, isFalse);
      expect(state3.lastPlayedMode, isNull);
      expect(state3.isLoading, isTrue);
    });

    test('should support copyWith to clear lastPlayedMode', () {
      const state1 = GameModeState(lastPlayedMode: GameMode.vsAi);
      final state2 = state1.copyWith(clearLastPlayedMode: true);

      expect(state1.lastPlayedMode, GameMode.vsAi);
      expect(state2.lastPlayedMode, isNull);
    });

    test('should support equality comparison', () {
      const state1 = GameModeState(lastPlayedMode: GameMode.vsAi);
      const state2 = GameModeState(lastPlayedMode: GameMode.vsAi);
      const state3 = GameModeState(lastPlayedMode: GameMode.twoPlayer);
      const state4 = GameModeState(lastPlayedMode: null);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
      expect(state1, isNot(equals(state4)));
    });
  });

  group('GameModeCubit', () {
    test('initial state should have no last played mode', () {
      expect(gameModeCubit.state.lastPlayedMode, isNull);
      expect(gameModeCubit.state.isLoading, isFalse);
    });

    blocTest<GameModeCubit, GameModeState>(
      'initializeLastPlayedMode should load saved vsAi mode',
      setUp: () {
        when(
          () => mockRepository.loadLastPlayedMode(),
        ).thenAnswer((_) async => GameMode.vsAi);
      },
      build: () => GameModeCubit(mockRepository),
      act: (cubit) => cubit.initializeLastPlayedMode(),
      expect: () => [
        const GameModeState(lastPlayedMode: null, isLoading: true),
        const GameModeState(lastPlayedMode: GameMode.vsAi, isLoading: false),
      ],
      verify: (_) {
        verify(() => mockRepository.loadLastPlayedMode()).called(1);
      },
    );

    blocTest<GameModeCubit, GameModeState>(
      'initializeLastPlayedMode should load saved twoPlayer mode',
      setUp: () {
        when(
          () => mockRepository.loadLastPlayedMode(),
        ).thenAnswer((_) async => GameMode.twoPlayer);
      },
      build: () => GameModeCubit(mockRepository),
      act: (cubit) => cubit.initializeLastPlayedMode(),
      expect: () => [
        const GameModeState(lastPlayedMode: null, isLoading: true),
        const GameModeState(
          lastPlayedMode: GameMode.twoPlayer,
          isLoading: false,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.loadLastPlayedMode()).called(1);
      },
    );

    blocTest<GameModeCubit, GameModeState>(
      'initializeLastPlayedMode should handle null (no saved mode)',
      setUp: () {
        when(
          () => mockRepository.loadLastPlayedMode(),
        ).thenAnswer((_) async => null);
      },
      build: () => GameModeCubit(mockRepository),
      act: (cubit) => cubit.initializeLastPlayedMode(),
      expect: () => [
        const GameModeState(lastPlayedMode: null, isLoading: true),
        const GameModeState(lastPlayedMode: null, isLoading: false),
      ],
    );

    blocTest<GameModeCubit, GameModeState>(
      'initializeLastPlayedMode should handle load error gracefully',
      setUp: () {
        when(
          () => mockRepository.loadLastPlayedMode(),
        ).thenThrow(Exception('Load error'));
      },
      build: () => GameModeCubit(mockRepository),
      act: (cubit) => cubit.initializeLastPlayedMode(),
      expect: () => [
        const GameModeState(lastPlayedMode: null, isLoading: true),
        const GameModeState(lastPlayedMode: null, isLoading: false),
      ],
    );

    blocTest<GameModeCubit, GameModeState>(
      'selectGameMode should save and update state to vsAi',
      setUp: () {
        when(
          () => mockRepository.saveLastPlayedMode(any()),
        ).thenAnswer((_) async {});
      },
      build: () => GameModeCubit(mockRepository),
      act: (cubit) => cubit.selectGameMode(GameMode.vsAi),
      expect: () => [
        const GameModeState(lastPlayedMode: null, isLoading: true),
        const GameModeState(lastPlayedMode: GameMode.vsAi, isLoading: false),
      ],
      verify: (_) {
        verify(
          () => mockRepository.saveLastPlayedMode(GameMode.vsAi),
        ).called(1);
      },
    );

    blocTest<GameModeCubit, GameModeState>(
      'selectGameMode should save and update state to twoPlayer',
      setUp: () {
        when(
          () => mockRepository.saveLastPlayedMode(any()),
        ).thenAnswer((_) async {});
      },
      build: () => GameModeCubit(mockRepository),
      act: (cubit) => cubit.selectGameMode(GameMode.twoPlayer),
      expect: () => [
        const GameModeState(lastPlayedMode: null, isLoading: true),
        const GameModeState(
          lastPlayedMode: GameMode.twoPlayer,
          isLoading: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.saveLastPlayedMode(GameMode.twoPlayer),
        ).called(1);
      },
    );

    blocTest<GameModeCubit, GameModeState>(
      'selectGameMode should revert on save error',
      setUp: () {
        when(
          () => mockRepository.saveLastPlayedMode(any()),
        ).thenThrow(Exception('Save error'));
      },
      build: () => GameModeCubit(mockRepository),
      act: (cubit) => cubit.selectGameMode(GameMode.vsAi),
      expect: () => [
        const GameModeState(lastPlayedMode: null, isLoading: true),
        const GameModeState(lastPlayedMode: null, isLoading: false),
      ],
    );

    blocTest<GameModeCubit, GameModeState>(
      'clearLastPlayedMode should delete saved mode',
      setUp: () {
        when(
          () => mockRepository.deleteLastPlayedMode(),
        ).thenAnswer((_) async {});
      },
      build: () => GameModeCubit(mockRepository),
      seed: () => const GameModeState(lastPlayedMode: GameMode.vsAi),
      act: (cubit) => cubit.clearLastPlayedMode(),
      expect: () => [
        const GameModeState(lastPlayedMode: GameMode.vsAi, isLoading: true),
        const GameModeState(lastPlayedMode: null, isLoading: false),
      ],
      verify: (_) {
        verify(() => mockRepository.deleteLastPlayedMode()).called(1);
      },
    );

    blocTest<GameModeCubit, GameModeState>(
      'clearLastPlayedMode should revert on delete error',
      setUp: () {
        when(
          () => mockRepository.deleteLastPlayedMode(),
        ).thenThrow(Exception('Delete error'));
      },
      build: () => GameModeCubit(mockRepository),
      seed: () => const GameModeState(lastPlayedMode: GameMode.twoPlayer),
      act: (cubit) => cubit.clearLastPlayedMode(),
      expect: () => [
        const GameModeState(
          lastPlayedMode: GameMode.twoPlayer,
          isLoading: true,
        ),
        const GameModeState(
          lastPlayedMode: GameMode.twoPlayer,
          isLoading: false,
        ),
      ],
    );

    blocTest<GameModeCubit, GameModeState>(
      'should handle multiple mode selections',
      setUp: () {
        when(
          () => mockRepository.saveLastPlayedMode(any()),
        ).thenAnswer((_) async {});
      },
      build: () => GameModeCubit(mockRepository),
      act: (cubit) async {
        await cubit.selectGameMode(GameMode.vsAi);
        await cubit.selectGameMode(GameMode.twoPlayer);
        await cubit.selectGameMode(GameMode.vsAi);
      },
      expect: () => [
        // First selection: vsAi
        const GameModeState(lastPlayedMode: null, isLoading: true),
        const GameModeState(lastPlayedMode: GameMode.vsAi, isLoading: false),
        // Second selection: twoPlayer
        const GameModeState(lastPlayedMode: GameMode.vsAi, isLoading: true),
        const GameModeState(
          lastPlayedMode: GameMode.twoPlayer,
          isLoading: false,
        ),
        // Third selection: vsAi again
        const GameModeState(
          lastPlayedMode: GameMode.twoPlayer,
          isLoading: true,
        ),
        const GameModeState(lastPlayedMode: GameMode.vsAi, isLoading: false),
      ],
      verify: (_) {
        verify(() => mockRepository.saveLastPlayedMode(any())).called(3);
      },
    );

    blocTest<GameModeCubit, GameModeState>(
      'should maintain state after failed save attempt',
      setUp: () {
        when(
          () => mockRepository.saveLastPlayedMode(any()),
        ).thenAnswer((_) async {});
      },
      build: () => GameModeCubit(mockRepository),
      seed: () => const GameModeState(lastPlayedMode: GameMode.vsAi),
      act: (cubit) async {
        // This should fail but maintain the vsAi preference
        when(
          () => mockRepository.saveLastPlayedMode(any()),
        ).thenThrow(Exception('Save error'));
        await cubit.selectGameMode(GameMode.twoPlayer);
      },
      expect: () => [
        const GameModeState(lastPlayedMode: GameMode.vsAi, isLoading: true),
        const GameModeState(lastPlayedMode: GameMode.vsAi, isLoading: false),
      ],
    );

    blocTest<GameModeCubit, GameModeState>(
      'should support full lifecycle: initialize, select, clear',
      setUp: () {
        when(
          () => mockRepository.loadLastPlayedMode(),
        ).thenAnswer((_) async => null);
        when(
          () => mockRepository.saveLastPlayedMode(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.deleteLastPlayedMode(),
        ).thenAnswer((_) async {});
      },
      build: () => GameModeCubit(mockRepository),
      act: (cubit) async {
        await cubit.initializeLastPlayedMode();
        await cubit.selectGameMode(GameMode.vsAi);
        await cubit.clearLastPlayedMode();
      },
      expect: () => [
        // Initialize
        const GameModeState(lastPlayedMode: null, isLoading: true),
        const GameModeState(lastPlayedMode: null, isLoading: false),
        // Select
        const GameModeState(lastPlayedMode: null, isLoading: true),
        const GameModeState(lastPlayedMode: GameMode.vsAi, isLoading: false),
        // Clear
        const GameModeState(lastPlayedMode: GameMode.vsAi, isLoading: true),
        const GameModeState(lastPlayedMode: null, isLoading: false),
      ],
      verify: (_) {
        verify(() => mockRepository.loadLastPlayedMode()).called(1);
        verify(
          () => mockRepository.saveLastPlayedMode(GameMode.vsAi),
        ).called(1);
        verify(() => mockRepository.deleteLastPlayedMode()).called(1);
      },
    );
  });
}
