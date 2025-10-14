import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_bloc.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_event.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_state.dart';

void main() {
  late GameBloc gameBloc;

  setUp(() {
    gameBloc = GameBloc();
  });

  tearDown(() {
    gameBloc.close();
  });

  group('GameState', () {
    test('should have correct default values', () {
      const state = GameState();
      expect(state.isInitialized, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('should support copyWith for isInitialized', () {
      const state1 = GameState();
      final state2 = state1.copyWith(isInitialized: true);

      expect(state2.isInitialized, isTrue);
      expect(state2.isLoading, isFalse);
    });

    test('should support copyWith for isLoading', () {
      const state1 = GameState();
      final state2 = state1.copyWith(isLoading: true);

      expect(state2.isInitialized, isFalse);
      expect(state2.isLoading, isTrue);
    });

    test('should support copyWith for multiple properties', () {
      const state1 = GameState();
      final state2 = state1.copyWith(isInitialized: true, isLoading: true);

      expect(state2.isInitialized, isTrue);
      expect(state2.isLoading, isTrue);
    });

    test('should support equality comparison', () {
      const state1 = GameState(isInitialized: true);
      const state2 = GameState(isInitialized: true);
      const state3 = GameState(isInitialized: false);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('should include all properties in equality check', () {
      const state1 = GameState(isInitialized: true, isLoading: true);
      const state2 = GameState(isInitialized: true, isLoading: true);
      const state3 = GameState(isInitialized: true, isLoading: false);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('GameEvent', () {
    test('GameInitialized should support equality comparison', () {
      const event1 = GameInitialized();
      const event2 = GameInitialized();

      expect(event1, equals(event2));
    });

    test('GamePlaceholderEvent should support equality comparison', () {
      const event1 = GamePlaceholderEvent();
      const event2 = GamePlaceholderEvent();

      expect(event1, equals(event2));
    });

    test('different events should not be equal', () {
      const event1 = GameInitialized();
      const event2 = GamePlaceholderEvent();

      expect(event1, isNot(equals(event2)));
    });
  });

  group('GameBloc', () {
    test('initial state should have correct default values', () {
      expect(gameBloc.state.isInitialized, isFalse);
      expect(gameBloc.state.isLoading, isFalse);
    });

    blocTest<GameBloc, GameState>(
      'emits loading then initialized state when GameInitialized is added',
      build: () => GameBloc(),
      act: (bloc) => bloc.add(const GameInitialized()),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        const GameState(isInitialized: false, isLoading: true),
        const GameState(isInitialized: true, isLoading: false),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should handle GamePlaceholderEvent without emitting states',
      build: () => GameBloc(),
      act: (bloc) => bloc.add(const GamePlaceholderEvent()),
      expect: () => [],
    );

    blocTest<GameBloc, GameState>(
      'should handle multiple initialization events',
      build: () => GameBloc(),
      act: (bloc) async {
        bloc.add(const GameInitialized());
        await Future.delayed(const Duration(milliseconds: 200));
        bloc.add(const GameInitialized());
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        const GameState(isInitialized: false, isLoading: true),
        const GameState(isInitialized: true, isLoading: false),
        const GameState(isInitialized: true, isLoading: true),
        const GameState(isInitialized: true, isLoading: false),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should maintain state after placeholder event',
      build: () => GameBloc(),
      seed: () => const GameState(isInitialized: true, isLoading: false),
      act: (bloc) => bloc.add(const GamePlaceholderEvent()),
      expect: () => [],
      verify: (bloc) {
        expect(bloc.state.isInitialized, isTrue);
        expect(bloc.state.isLoading, isFalse);
      },
    );

    blocTest<GameBloc, GameState>(
      'should handle mixed event sequence',
      build: () => GameBloc(),
      act: (bloc) async {
        bloc.add(const GameInitialized());
        await Future.delayed(const Duration(milliseconds: 200));
        bloc.add(const GamePlaceholderEvent());
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        const GameState(isInitialized: false, isLoading: true),
        const GameState(isInitialized: true, isLoading: false),
      ],
    );

    test('should close without errors', () async {
      final bloc = GameBloc();
      await expectLater(bloc.close(), completes);
    });

    test('should not emit after close', () async {
      final bloc = GameBloc();
      await bloc.close();

      expect(
        () => bloc.add(const GameInitialized()),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('GameBloc Integration', () {
    blocTest<GameBloc, GameState>(
      'should demonstrate complete placeholder lifecycle',
      build: () => GameBloc(),
      act: (bloc) async {
        // Initialize
        bloc.add(const GameInitialized());
        await Future.delayed(const Duration(milliseconds: 200));

        // Trigger placeholder events
        bloc.add(const GamePlaceholderEvent());
        bloc.add(const GamePlaceholderEvent());

        // Re-initialize
        bloc.add(const GameInitialized());
      },
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const GameState(isInitialized: false, isLoading: true),
        const GameState(isInitialized: true, isLoading: false),
        const GameState(isInitialized: true, isLoading: true),
        const GameState(isInitialized: true, isLoading: false),
      ],
    );

    test('should work with stream subscription', () async {
      final bloc = GameBloc();
      final states = <GameState>[];

      final subscription = bloc.stream.listen((state) {
        states.add(state);
      });

      bloc.add(const GameInitialized());
      await Future.delayed(const Duration(milliseconds: 150));

      expect(states.length, equals(2));
      expect(states[0].isLoading, isTrue);
      expect(states[1].isInitialized, isTrue);

      await subscription.cancel();
      await bloc.close();
    });
  });

  group('GameBloc Documentation', () {
    test('should be properly documented as a placeholder', () {
      // This test verifies the placeholder nature of GameBloc
      // Future tasks will expand this with actual game logic
      final bloc = GameBloc();

      // Initial state is uninitialized
      expect(bloc.state.isInitialized, isFalse);

      bloc.close();
    });
  });
}
