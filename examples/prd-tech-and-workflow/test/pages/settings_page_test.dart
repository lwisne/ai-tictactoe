import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/cubits/settings_cubit.dart';
import 'package:tic_tac_toe/models/settings.dart' as app_settings;
import 'package:tic_tac_toe/pages/settings_page.dart';
import 'package:tic_tac_toe/services/settings_service.dart';

void main() {
  group('SettingsPage', () {
    late SettingsService settingsService;
    late SettingsCubit settingsCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
      settingsCubit = SettingsCubit(settingsService);
    });

    tearDown(() {
      settingsCubit.close();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<SettingsCubit>.value(
          value: settingsCubit,
          child: const SettingsPage(),
        ),
      );
    }

    testWidgets('renders settings page with all sections', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Gameplay'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('AI Difficulty'), findsOneWidget);
      expect(find.text('Reset to Defaults'), findsOneWidget);
    });

    testWidgets('sound switch reflects current state', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final switchFinder = find.byType(SwitchListTile);
      final switchWidget = tester.widget<SwitchListTile>(switchFinder);

      expect(switchWidget.value, true);
    });

    testWidgets('tapping sound switch toggles state', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final switchFinder = find.byType(SwitchListTile);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(settingsCubit.state.soundEnabled, false);
    });

    testWidgets('displays current theme mode', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('System Default'), findsOneWidget);
    });

    testWidgets('tapping theme opens dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final themeTile = find.ancestor(
        of: find.text('Theme'),
        matching: find.byType(ListTile),
      );

      await tester.tap(themeTile);
      await tester.pumpAndSettle();

      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('selecting theme from dialog updates state', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open theme dialog
      final themeTile = find.ancestor(
        of: find.text('Theme'),
        matching: find.byType(ListTile),
      );
      await tester.tap(themeTile);
      await tester.pumpAndSettle();

      // Select Dark theme
      final darkRadio = find.ancestor(
        of: find.text('Dark'),
        matching: find.byType(RadioListTile<app_settings.ThemeMode>),
      );
      await tester.tap(darkRadio);
      await tester.pumpAndSettle();

      expect(settingsCubit.state.themeMode, app_settings.ThemeMode.dark);
    });

    testWidgets('displays current AI difficulty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('tapping AI difficulty opens dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final aiTile = find.ancestor(
        of: find.text('AI Difficulty'),
        matching: find.byType(ListTile),
      );

      await tester.tap(aiTile);
      await tester.pumpAndSettle();

      expect(find.text('Choose AI Difficulty'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('AI makes frequent mistakes'), findsOneWidget);
      expect(find.text('Balanced gameplay'), findsOneWidget);
      expect(find.text('Unbeatable AI'), findsOneWidget);
    });

    testWidgets('selecting AI difficulty from dialog updates state',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open AI difficulty dialog
      final aiTile = find.ancestor(
        of: find.text('AI Difficulty'),
        matching: find.byType(ListTile),
      );
      await tester.tap(aiTile);
      await tester.pumpAndSettle();

      // Select Hard difficulty
      final hardRadio = find.ancestor(
        of: find.text('Unbeatable AI'),
        matching: find.byType(RadioListTile<app_settings.AiDifficulty>),
      );
      await tester.tap(hardRadio);
      await tester.pumpAndSettle();

      expect(settingsCubit.state.aiDifficulty, app_settings.AiDifficulty.hard);
    });

    testWidgets('tapping reset button shows confirmation dialog',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      final resetButton = find.text('Reset to Defaults');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      expect(find.text('Reset Settings'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to reset all settings to their default values?',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget); // Reset button only
    });

    testWidgets('confirming reset resets settings', (tester) async {
      // Change settings first
      await settingsCubit.toggleSound();
      await settingsCubit.setThemeMode(app_settings.ThemeMode.dark);
      await settingsCubit.setAiDifficulty(app_settings.AiDifficulty.hard);

      await tester.pumpWidget(createTestWidget());

      // Open reset dialog
      final resetButton = find.text('Reset to Defaults');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Confirm reset (find the button, not the title)
      final resetConfirmButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, 'Reset'),
      );
      await tester.tap(resetConfirmButton);
      await tester.pumpAndSettle();

      expect(settingsCubit.state, app_settings.Settings.defaults());
    });

    testWidgets('canceling reset keeps current settings', (tester) async {
      // Change settings first
      await settingsCubit.toggleSound();

      await tester.pumpWidget(createTestWidget());

      // Open reset dialog
      final resetButton = find.text('Reset to Defaults');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Cancel
      final cancelButton = find.text('Cancel');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      expect(settingsCubit.state.soundEnabled, false);
    });

    testWidgets('all settings persist and display correctly', (tester) async {
      // Set all settings to non-default values
      await settingsCubit.toggleSound();
      await settingsCubit.setThemeMode(app_settings.ThemeMode.light);
      await settingsCubit.setAiDifficulty(app_settings.AiDifficulty.easy);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify switch shows false
      final switchWidget =
          tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(switchWidget.value, false);

      // Verify theme shows Light
      expect(find.text('Light'), findsOneWidget);

      // Verify AI difficulty shows Easy
      expect(find.text('Easy'), findsOneWidget);
    });
  });
}
