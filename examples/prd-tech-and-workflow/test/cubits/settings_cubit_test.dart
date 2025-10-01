import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/cubits/settings_cubit.dart';
import 'package:tic_tac_toe/models/settings.dart';
import 'package:tic_tac_toe/services/settings_service.dart';

void main() {
  group('SettingsCubit', () {
    late SettingsService settingsService;
    late SettingsCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
      cubit = SettingsCubit(settingsService);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is defaults', () {
      expect(cubit.state, Settings.defaults());
    });

    blocTest<SettingsCubit, Settings>(
      'toggleSound emits new state and persists',
      build: () => cubit,
      act: (cubit) => cubit.toggleSound(),
      expect: () => [
        Settings.defaults().copyWith(soundEnabled: false),
      ],
      verify: (_) {
        final loaded = settingsService.loadSettings();
        expect(loaded.soundEnabled, false);
      },
    );

    blocTest<SettingsCubit, Settings>(
      'toggleSound twice returns to original state',
      build: () => cubit,
      act: (cubit) async {
        await cubit.toggleSound();
        await cubit.toggleSound();
      },
      expect: () => [
        Settings.defaults().copyWith(soundEnabled: false),
        Settings.defaults().copyWith(soundEnabled: true),
      ],
    );

    blocTest<SettingsCubit, Settings>(
      'setThemeMode emits new state and persists',
      build: () => cubit,
      act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
      expect: () => [
        Settings.defaults().copyWith(themeMode: ThemeMode.dark),
      ],
      verify: (_) {
        final loaded = settingsService.loadSettings();
        expect(loaded.themeMode, ThemeMode.dark);
      },
    );

    blocTest<SettingsCubit, Settings>(
      'setThemeMode to light mode',
      build: () => cubit,
      act: (cubit) => cubit.setThemeMode(ThemeMode.light),
      expect: () => [
        Settings.defaults().copyWith(themeMode: ThemeMode.light),
      ],
    );

    blocTest<SettingsCubit, Settings>(
      'setAiDifficulty emits new state and persists',
      build: () => cubit,
      act: (cubit) => cubit.setAiDifficulty(AiDifficulty.hard),
      expect: () => [
        Settings.defaults().copyWith(aiDifficulty: AiDifficulty.hard),
      ],
      verify: (_) {
        final loaded = settingsService.loadSettings();
        expect(loaded.aiDifficulty, AiDifficulty.hard);
      },
    );

    blocTest<SettingsCubit, Settings>(
      'setAiDifficulty to easy mode',
      build: () => cubit,
      act: (cubit) => cubit.setAiDifficulty(AiDifficulty.easy),
      expect: () => [
        Settings.defaults().copyWith(aiDifficulty: AiDifficulty.easy),
      ],
    );

    blocTest<SettingsCubit, Settings>(
      'resetSettings returns to defaults and clears storage',
      build: () => cubit,
      seed: () => const Settings(
        soundEnabled: false,
        themeMode: ThemeMode.dark,
        aiDifficulty: AiDifficulty.hard,
      ),
      act: (cubit) => cubit.resetSettings(),
      expect: () => [Settings.defaults()],
      verify: (_) {
        final loaded = settingsService.loadSettings();
        expect(loaded, Settings.defaults());
      },
    );

    blocTest<SettingsCubit, Settings>(
      'multiple changes accumulate correctly',
      build: () => cubit,
      act: (cubit) async {
        await cubit.toggleSound();
        await cubit.setThemeMode(ThemeMode.dark);
        await cubit.setAiDifficulty(AiDifficulty.hard);
      },
      expect: () => [
        Settings.defaults().copyWith(soundEnabled: false),
        Settings.defaults().copyWith(
          soundEnabled: false,
          themeMode: ThemeMode.dark,
        ),
        const Settings(
          soundEnabled: false,
          themeMode: ThemeMode.dark,
          aiDifficulty: AiDifficulty.hard,
        ),
      ],
    );

    test('loads persisted settings on initialization', () async {
      // Save settings before creating cubit
      await settingsService.saveSettings(const Settings(
        soundEnabled: false,
        themeMode: ThemeMode.dark,
        aiDifficulty: AiDifficulty.easy,
      ));

      // Create new cubit - should load persisted settings
      final newCubit = SettingsCubit(settingsService);

      // Wait for initialization
      await Future.delayed(Duration.zero);

      expect(newCubit.state.soundEnabled, false);
      expect(newCubit.state.themeMode, ThemeMode.dark);
      expect(newCubit.state.aiDifficulty, AiDifficulty.easy);

      await newCubit.close();
    });
  });
}
