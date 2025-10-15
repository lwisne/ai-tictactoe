import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/data/repositories/theme_repository.dart';
import 'package:tictactoe_app/domain/models/theme_preference.dart';
import 'package:tictactoe_app/presentation/blocs/theme/theme_bloc.dart';
import 'package:tictactoe_app/presentation/blocs/theme/theme_event.dart';
import 'package:tictactoe_app/presentation/blocs/theme/theme_state.dart';

class MockThemeRepository extends Mock implements ThemeRepository {}

void main() {
  late ThemeRepository mockRepository;
  late ThemeBloc themeBloc;

  setUpAll(() {
    // Register fallback value for mocktail
    registerFallbackValue(const ThemeSettings());
  });

  setUp(() {
    mockRepository = MockThemeRepository();
    themeBloc = ThemeBloc(mockRepository);
  });

  tearDown(() {
    themeBloc.close();
  });

  group('ThemeState', () {
    test('should have system as default preference', () {
      const state = ThemeState();
      expect(state.preference, ThemePreference.system);
      expect(state.isLoading, isFalse);
    });

    test('should convert ThemePreference to ThemeMode correctly', () {
      const systemState = ThemeState(preference: ThemePreference.system);
      expect(systemState.themeMode, ThemeMode.system);

      const lightState = ThemeState(preference: ThemePreference.light);
      expect(lightState.themeMode, ThemeMode.light);

      const darkState = ThemeState(preference: ThemePreference.dark);
      expect(darkState.themeMode, ThemeMode.dark);
    });

    test('should support copyWith', () {
      const state1 = ThemeState(preference: ThemePreference.system);
      final state2 = state1.copyWith(preference: ThemePreference.dark);
      final state3 = state1.copyWith(isLoading: true);

      expect(state2.preference, ThemePreference.dark);
      expect(state2.isLoading, isFalse);
      expect(state3.preference, ThemePreference.system);
      expect(state3.isLoading, isTrue);
    });

    test('should support equality comparison', () {
      const state1 = ThemeState(preference: ThemePreference.light);
      const state2 = ThemeState(preference: ThemePreference.light);
      const state3 = ThemeState(preference: ThemePreference.dark);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('ThemeEvent', () {
    test('ThemeInitialized should support equality comparison', () {
      const event1 = ThemeInitialized();
      const event2 = ThemeInitialized();

      expect(event1, equals(event2));
    });

    test('ThemeChanged should support equality comparison', () {
      const event1 = ThemeChanged(ThemePreference.light);
      const event2 = ThemeChanged(ThemePreference.light);
      const event3 = ThemeChanged(ThemePreference.dark);

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('ThemeResetToSystem should support equality comparison', () {
      const event1 = ThemeResetToSystem();
      const event2 = ThemeResetToSystem();

      expect(event1, equals(event2));
    });

    test('different events should not be equal', () {
      const event1 = ThemeInitialized();
      const event2 = ThemeChanged(ThemePreference.light);

      expect(event1, isNot(equals(event2)));
    });
  });

  group('ThemeBloc', () {
    test('initial state should be system theme', () {
      expect(themeBloc.state.preference, ThemePreference.system);
      expect(themeBloc.state.isLoading, isFalse);
    });

    blocTest<ThemeBloc, ThemeState>(
      'ThemeInitialized should load saved settings',
      setUp: () {
        when(() => mockRepository.loadThemeSettings()).thenAnswer(
          (_) async => const ThemeSettings(preference: ThemePreference.dark),
        );
      },
      build: () => ThemeBloc(mockRepository),
      act: (bloc) => bloc.add(const ThemeInitialized()),
      expect: () => [
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.dark, isLoading: false),
      ],
      verify: (_) {
        verify(() => mockRepository.loadThemeSettings()).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'ThemeInitialized should use system default on error',
      setUp: () {
        when(
          () => mockRepository.loadThemeSettings(),
        ).thenThrow(Exception('Load error'));
      },
      build: () => ThemeBloc(mockRepository),
      act: (bloc) => bloc.add(const ThemeInitialized()),
      expect: () => [
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.system, isLoading: false),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'ThemeChanged should save and update state to light',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenAnswer((_) async {});
      },
      build: () => ThemeBloc(mockRepository),
      act: (bloc) => bloc.add(const ThemeChanged(ThemePreference.light)),
      expect: () => [
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.light, isLoading: false),
      ],
      verify: (_) {
        verify(
          () => mockRepository.saveThemeSettings(
            const ThemeSettings(preference: ThemePreference.light),
          ),
        ).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'ThemeChanged should save and update state to dark',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenAnswer((_) async {});
      },
      build: () => ThemeBloc(mockRepository),
      act: (bloc) => bloc.add(const ThemeChanged(ThemePreference.dark)),
      expect: () => [
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.dark, isLoading: false),
      ],
      verify: (_) {
        verify(
          () => mockRepository.saveThemeSettings(
            const ThemeSettings(preference: ThemePreference.dark),
          ),
        ).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'ThemeChanged should revert on save error',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenThrow(Exception('Save error'));
      },
      build: () => ThemeBloc(mockRepository),
      act: (bloc) => bloc.add(const ThemeChanged(ThemePreference.dark)),
      expect: () => [
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.system, isLoading: false),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'ThemeResetToSystem should delegate to ThemeChanged',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenAnswer((_) async {});
      },
      build: () => ThemeBloc(mockRepository),
      act: (bloc) => bloc.add(const ThemeResetToSystem()),
      expect: () => [
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.system, isLoading: false),
      ],
      verify: (_) {
        verify(
          () => mockRepository.saveThemeSettings(
            const ThemeSettings(preference: ThemePreference.system),
          ),
        ).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'should handle multiple theme changes',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenAnswer((_) async {});
      },
      build: () => ThemeBloc(mockRepository),
      act: (bloc) async {
        bloc.add(const ThemeChanged(ThemePreference.light));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ThemeChanged(ThemePreference.dark));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ThemeChanged(ThemePreference.system));
      },
      expect: () => [
        // First change to light
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.light, isLoading: false),
        // Second change to dark
        const ThemeState(preference: ThemePreference.light, isLoading: true),
        const ThemeState(preference: ThemePreference.dark, isLoading: false),
        // Third change to system
        const ThemeState(preference: ThemePreference.dark, isLoading: true),
        const ThemeState(preference: ThemePreference.system, isLoading: false),
      ],
      verify: (_) {
        verify(() => mockRepository.saveThemeSettings(any())).called(3);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'should maintain state after failed save attempt',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenAnswer((_) async {});
      },
      build: () => ThemeBloc(mockRepository),
      seed: () => const ThemeState(preference: ThemePreference.light),
      act: (bloc) async {
        // This should fail but maintain the light preference
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenThrow(Exception('Save error'));
        bloc.add(const ThemeChanged(ThemePreference.dark));
      },
      expect: () => [
        const ThemeState(preference: ThemePreference.light, isLoading: true),
        const ThemeState(preference: ThemePreference.light, isLoading: false),
      ],
    );

    test('should close without errors', () async {
      final bloc = ThemeBloc(mockRepository);
      await expectLater(bloc.close(), completes);
    });

    test('should not emit after close', () async {
      final bloc = ThemeBloc(mockRepository);
      await bloc.close();

      expect(
        () => bloc.add(const ThemeInitialized()),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Integration with ThemeMode', () {
    test('ThemeMode conversion should be consistent', () {
      final states = [
        const ThemeState(preference: ThemePreference.system),
        const ThemeState(preference: ThemePreference.light),
        const ThemeState(preference: ThemePreference.dark),
      ];

      final expectedModes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

      for (var i = 0; i < states.length; i++) {
        expect(states[i].themeMode, expectedModes[i]);
      }
    });
  });

  group('ThemeBloc Event Processing', () {
    blocTest<ThemeBloc, ThemeState>(
      'should process initialization then change events',
      setUp: () {
        when(() => mockRepository.loadThemeSettings()).thenAnswer(
          (_) async => const ThemeSettings(preference: ThemePreference.system),
        );
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenAnswer((_) async {});
      },
      build: () => ThemeBloc(mockRepository),
      act: (bloc) async {
        bloc.add(const ThemeInitialized());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ThemeChanged(ThemePreference.dark));
      },
      expect: () => [
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.system, isLoading: false),
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.dark, isLoading: false),
      ],
    );

    test('should work with stream subscription', () async {
      when(
        () => mockRepository.saveThemeSettings(any()),
      ).thenAnswer((_) async {});

      final bloc = ThemeBloc(mockRepository);
      final states = <ThemeState>[];

      final subscription = bloc.stream.listen((state) {
        states.add(state);
      });

      bloc.add(const ThemeChanged(ThemePreference.light));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, equals(2));
      expect(states[0].isLoading, isTrue);
      expect(states[1].preference, ThemePreference.light);

      await subscription.cancel();
      await bloc.close();
    });
  });
}
