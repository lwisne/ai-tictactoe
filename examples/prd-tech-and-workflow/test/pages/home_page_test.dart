import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/cubits/score_cubit.dart';
import 'package:tic_tac_toe/cubits/settings_cubit.dart';
import 'package:tic_tac_toe/pages/game_page.dart';
import 'package:tic_tac_toe/pages/home_page.dart';
import 'package:tic_tac_toe/pages/settings_page.dart';
import 'package:tic_tac_toe/services/score_service.dart';
import 'package:tic_tac_toe/services/settings_service.dart';

void main() {
  group('HomePage', () {
    late SharedPreferences prefs;
    late SettingsService settingsService;
    late ScoreService scoreService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
      scoreService = ScoreService(prefs);
    });

    Widget createHomePage() {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsCubit(settingsService)),
          BlocProvider(create: (_) => ScoreCubit(scoreService)),
        ],
        child: const MaterialApp(
          home: HomePage(),
        ),
      );
    }

    testWidgets('renders title and game mode options', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(createHomePage());

      // Verify title
      expect(find.text('Tic-Tac-Toe'), findsOneWidget); // AppBar
      expect(find.text('Choose Game Mode'), findsOneWidget);

      // Verify game mode options
      expect(find.text('2 Player'), findsOneWidget);
      expect(find.text('vs AI'), findsOneWidget);

      // Verify icons
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.computer), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('displays score board', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(createHomePage());

      // Verify score display elements
      expect(find.text('X Wins'), findsOneWidget);
      expect(find.text('Draws'), findsOneWidget);
      expect(find.text('O Wins'), findsOneWidget);
    });

    testWidgets('2 Player button navigates to game page', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(createHomePage());

      // Tap 2 Player button
      await tester.tap(find.text('2 Player'));
      await tester.pumpAndSettle();

      // Verify navigation to GamePage with twoPlayer mode
      expect(find.byType(GamePage), findsOneWidget);
    });

    testWidgets('vs AI button navigates to game page', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(createHomePage());

      // Tap vs AI button
      await tester.tap(find.text('vs AI'));
      await tester.pumpAndSettle();

      // Verify navigation to GamePage with vsAi mode
      expect(find.byType(GamePage), findsOneWidget);
    });

    testWidgets('Settings button navigates to settings page', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(createHomePage());

      // Tap Settings button
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify navigation to SettingsPage
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('respects theme from MaterialApp', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => SettingsCubit(settingsService)),
            BlocProvider(create: (_) => ScoreCubit(scoreService)),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            home: const HomePage(),
          ),
        ),
      );

      // Verify page renders without errors
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('layout is responsive with constraints', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(createHomePage());

      // Verify ConstrainedBox exists with max width 400
      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final homePageConstraint = constrainedBoxes.firstWhere(
        (box) => box.constraints.maxWidth == 400,
      );
      expect(homePageConstraint, isNotNull);
    });

    testWidgets('navigating back from game returns to home', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(createHomePage());

      // Navigate to game
      await tester.tap(find.text('2 Player'));
      await tester.pumpAndSettle();

      // Verify on game page
      expect(find.byType(GamePage), findsOneWidget);

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify back on home page
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('2 Player'), findsOneWidget);
    });
  });
}
