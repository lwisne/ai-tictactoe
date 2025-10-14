import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/data/repositories/theme_repository.dart';
import 'package:tictactoe_app/domain/models/theme_preference.dart';
import 'package:tictactoe_app/presentation/cubits/theme_cubit.dart';

class MockThemeRepository extends Mock implements ThemeRepository {}

void main() {
  late ThemeRepository mockRepository;
  late ThemeCubit themeCubit;

  setUpAll(() {
    // Register fallback value for mocktail
    registerFallbackValue(const ThemeSettings());
  });

  setUp(() {
    mockRepository = MockThemeRepository();
    themeCubit = ThemeCubit(mockRepository);
  });

  tearDown(() {
    themeCubit.close();
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

  group('ThemeCubit', () {
    test('initial state should be system theme', () {
      expect(themeCubit.state.preference, ThemePreference.system);
      expect(themeCubit.state.isLoading, isFalse);
    });

    blocTest<ThemeCubit, ThemeState>(
      'initializeTheme should load saved settings',
      setUp: () {
        when(() => mockRepository.loadThemeSettings()).thenAnswer(
          (_) async => const ThemeSettings(preference: ThemePreference.dark),
        );
      },
      build: () => ThemeCubit(mockRepository),
      act: (cubit) => cubit.initializeTheme(),
      expect: () => [
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.dark, isLoading: false),
      ],
      verify: (_) {
        verify(() => mockRepository.loadThemeSettings()).called(1);
      },
    );

    blocTest<ThemeCubit, ThemeState>(
      'initializeTheme should use system default on error',
      setUp: () {
        when(
          () => mockRepository.loadThemeSettings(),
        ).thenThrow(Exception('Load error'));
      },
      build: () => ThemeCubit(mockRepository),
      act: (cubit) => cubit.initializeTheme(),
      expect: () => [
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.system, isLoading: false),
      ],
    );

    blocTest<ThemeCubit, ThemeState>(
      'setThemePreference should save and update state to light',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenAnswer((_) async {});
      },
      build: () => ThemeCubit(mockRepository),
      act: (cubit) => cubit.setThemePreference(ThemePreference.light),
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

    blocTest<ThemeCubit, ThemeState>(
      'setThemePreference should save and update state to dark',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenAnswer((_) async {});
      },
      build: () => ThemeCubit(mockRepository),
      act: (cubit) => cubit.setThemePreference(ThemePreference.dark),
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

    blocTest<ThemeCubit, ThemeState>(
      'setThemePreference should revert on save error',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenThrow(Exception('Save error'));
      },
      build: () => ThemeCubit(mockRepository),
      act: (cubit) => cubit.setThemePreference(ThemePreference.dark),
      expect: () => [
        const ThemeState(preference: ThemePreference.system, isLoading: true),
        const ThemeState(preference: ThemePreference.system, isLoading: false),
      ],
    );

    blocTest<ThemeCubit, ThemeState>(
      'resetToSystem should set preference to system',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenAnswer((_) async {});
      },
      build: () => ThemeCubit(mockRepository),
      act: (cubit) => cubit.resetToSystem(),
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

    blocTest<ThemeCubit, ThemeState>(
      'should handle multiple theme changes',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenAnswer((_) async {});
      },
      build: () => ThemeCubit(mockRepository),
      act: (cubit) async {
        await cubit.setThemePreference(ThemePreference.light);
        await cubit.setThemePreference(ThemePreference.dark);
        await cubit.setThemePreference(ThemePreference.system);
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

    blocTest<ThemeCubit, ThemeState>(
      'should maintain state after failed save attempt',
      setUp: () {
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenAnswer((_) async {});
      },
      build: () => ThemeCubit(mockRepository),
      seed: () => const ThemeState(preference: ThemePreference.light),
      act: (cubit) async {
        // This should fail but maintain the light preference
        when(
          () => mockRepository.saveThemeSettings(any()),
        ).thenThrow(Exception('Save error'));
        await cubit.setThemePreference(ThemePreference.dark);
      },
      expect: () => [
        const ThemeState(preference: ThemePreference.light, isLoading: true),
        const ThemeState(preference: ThemePreference.light, isLoading: false),
      ],
    );
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
}
