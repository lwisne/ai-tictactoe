import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/presentation/blocs/settings/settings_bloc.dart';
import 'package:tictactoe_app/presentation/blocs/settings/settings_event.dart';
import 'package:tictactoe_app/presentation/blocs/settings/settings_state.dart';

void main() {
  late SettingsBloc settingsBloc;

  setUp(() {
    settingsBloc = SettingsBloc();
  });

  tearDown(() {
    settingsBloc.close();
  });

  group('SettingsState', () {
    test('should have correct default values', () {
      const state = SettingsState();
      expect(state.isInitialized, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('should support copyWith for isInitialized', () {
      const state1 = SettingsState();
      final state2 = state1.copyWith(isInitialized: true);

      expect(state2.isInitialized, isTrue);
      expect(state2.isLoading, isFalse);
    });

    test('should support copyWith for isLoading', () {
      const state1 = SettingsState();
      final state2 = state1.copyWith(isLoading: true);

      expect(state2.isInitialized, isFalse);
      expect(state2.isLoading, isTrue);
    });

    test('should support copyWith for multiple properties', () {
      const state1 = SettingsState();
      final state2 = state1.copyWith(isInitialized: true, isLoading: true);

      expect(state2.isInitialized, isTrue);
      expect(state2.isLoading, isTrue);
    });

    test('should support equality comparison', () {
      const state1 = SettingsState(isInitialized: true);
      const state2 = SettingsState(isInitialized: true);
      const state3 = SettingsState(isInitialized: false);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('should include all properties in equality check', () {
      const state1 = SettingsState(isInitialized: true, isLoading: true);
      const state2 = SettingsState(isInitialized: true, isLoading: true);
      const state3 = SettingsState(isInitialized: true, isLoading: false);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('SettingsEvent', () {
    test('SettingsInitialized should support equality comparison', () {
      const event1 = SettingsInitialized();
      const event2 = SettingsInitialized();

      expect(event1, equals(event2));
    });

    test('SettingsPlaceholderEvent should support equality comparison', () {
      const event1 = SettingsPlaceholderEvent();
      const event2 = SettingsPlaceholderEvent();

      expect(event1, equals(event2));
    });

    test('different events should not be equal', () {
      const event1 = SettingsInitialized();
      const event2 = SettingsPlaceholderEvent();

      expect(event1, isNot(equals(event2)));
    });
  });

  group('SettingsBloc', () {
    test('initial state should have correct default values', () {
      expect(settingsBloc.state.isInitialized, isFalse);
      expect(settingsBloc.state.isLoading, isFalse);
    });

    blocTest<SettingsBloc, SettingsState>(
      'emits loading then initialized state when SettingsInitialized is added',
      build: () => SettingsBloc(),
      act: (bloc) => bloc.add(const SettingsInitialized()),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        const SettingsState(isInitialized: false, isLoading: true),
        const SettingsState(isInitialized: true, isLoading: false),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'should handle SettingsPlaceholderEvent without emitting states',
      build: () => SettingsBloc(),
      act: (bloc) => bloc.add(const SettingsPlaceholderEvent()),
      expect: () => [],
    );

    blocTest<SettingsBloc, SettingsState>(
      'should handle multiple initialization events',
      build: () => SettingsBloc(),
      act: (bloc) async {
        bloc.add(const SettingsInitialized());
        await Future.delayed(const Duration(milliseconds: 200));
        bloc.add(const SettingsInitialized());
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        const SettingsState(isInitialized: false, isLoading: true),
        const SettingsState(isInitialized: true, isLoading: false),
        const SettingsState(isInitialized: true, isLoading: true),
        const SettingsState(isInitialized: true, isLoading: false),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'should maintain state after placeholder event',
      build: () => SettingsBloc(),
      seed: () => const SettingsState(isInitialized: true, isLoading: false),
      act: (bloc) => bloc.add(const SettingsPlaceholderEvent()),
      expect: () => [],
      verify: (bloc) {
        expect(bloc.state.isInitialized, isTrue);
        expect(bloc.state.isLoading, isFalse);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'should handle mixed event sequence',
      build: () => SettingsBloc(),
      act: (bloc) async {
        bloc.add(const SettingsInitialized());
        await Future.delayed(const Duration(milliseconds: 200));
        bloc.add(const SettingsPlaceholderEvent());
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        const SettingsState(isInitialized: false, isLoading: true),
        const SettingsState(isInitialized: true, isLoading: false),
      ],
    );

    test('should close without errors', () async {
      final bloc = SettingsBloc();
      await expectLater(bloc.close(), completes);
    });

    test('should not emit after close', () async {
      final bloc = SettingsBloc();
      await bloc.close();

      expect(
        () => bloc.add(const SettingsInitialized()),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('SettingsBloc Integration', () {
    blocTest<SettingsBloc, SettingsState>(
      'should demonstrate complete placeholder lifecycle',
      build: () => SettingsBloc(),
      act: (bloc) async {
        // Initialize
        bloc.add(const SettingsInitialized());
        await Future.delayed(const Duration(milliseconds: 200));

        // Trigger placeholder events
        bloc.add(const SettingsPlaceholderEvent());
        bloc.add(const SettingsPlaceholderEvent());

        // Re-initialize
        bloc.add(const SettingsInitialized());
      },
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const SettingsState(isInitialized: false, isLoading: true),
        const SettingsState(isInitialized: true, isLoading: false),
        const SettingsState(isInitialized: true, isLoading: true),
        const SettingsState(isInitialized: true, isLoading: false),
      ],
    );

    test('should work with stream subscription', () async {
      final bloc = SettingsBloc();
      final states = <SettingsState>[];

      final subscription = bloc.stream.listen((state) {
        states.add(state);
      });

      bloc.add(const SettingsInitialized());
      await Future.delayed(const Duration(milliseconds: 150));

      expect(states.length, equals(2));
      expect(states[0].isLoading, isTrue);
      expect(states[1].isInitialized, isTrue);

      await subscription.cancel();
      await bloc.close();
    });
  });

  group('SettingsBloc Documentation', () {
    test('should be properly documented as a placeholder', () {
      // This test verifies the placeholder nature of SettingsBloc
      // Future tasks will expand this with actual settings logic
      final bloc = SettingsBloc();

      // Initial state is uninitialized
      expect(bloc.state.isInitialized, isFalse);

      bloc.close();
    });
  });
}
