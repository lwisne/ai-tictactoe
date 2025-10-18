import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/core/di/injection.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_bloc.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_event.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_state.dart'
    as game_states;
import 'package:tictactoe_app/presentation/pages/ai_difficulty_page.dart';
import 'package:tictactoe_app/presentation/pages/game_details_page.dart';
import 'package:tictactoe_app/presentation/pages/game_page.dart';
import 'package:tictactoe_app/presentation/pages/history_page.dart';
import 'package:tictactoe_app/presentation/pages/home_page.dart';
import 'package:tictactoe_app/presentation/pages/settings_page.dart';
import 'package:tictactoe_app/routes/app_router.dart';

class MockGameBloc extends Mock implements GameBloc {}

void main() {
  late GameBloc mockGameBloc;

  setUpAll(() {
    registerFallbackValue(const game_states.GameInitial());
    registerFallbackValue(const ResumeGame());
    registerFallbackValue(const ClearSavedGameState());
  });

  group('AppRouter', () {
    setUp(() async {
      // Reset GetIt before each test to ensure a clean DI container
      await GetIt.instance.reset();
      // Initialize dependency injection for each test to prevent state pollution
      configureDependencies();

      // Create mock GameBloc with default behavior
      mockGameBloc = MockGameBloc();
      when(
        () => mockGameBloc.state,
      ).thenReturn(const game_states.GameInitial());
      when(
        () => mockGameBloc.stream,
      ).thenAnswer((_) => Stream.value(const game_states.GameInitial()));
      when(() => mockGameBloc.close()).thenAnswer((_) async {});
      when(() => mockGameBloc.add(any())).thenReturn(null);
    });

    tearDown(() async {
      // Reset router to home to prevent state pollution between tests
      AppRouter.router.go('/');
      await mockGameBloc.close();
    });

    Widget createTestApp() {
      return BlocProvider<GameBloc>.value(
        value: mockGameBloc,
        child: MaterialApp.router(routerConfig: AppRouter.router),
      );
    }

    testWidgets('navigates to home page at initial location', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Verify home page is displayed
      expect(find.byType(HomePage), findsOneWidget);
      // "Tic-Tac-Toe" appears in both AppBar and body
      expect(find.text('Tic-Tac-Toe'), findsAtLeastNWidgets(1));
    });

    testWidgets('navigates to game page when /game route is accessed', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      // Navigate to game page
      AppRouter.router.go(AppRouter.game);
      await tester.pumpAndSettle();

      // Verify game page is displayed
      expect(find.byType(GamePage), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);
    });

    testWidgets(
      'navigates to AI difficulty page when /ai-select route is accessed',
      (tester) async {
        await tester.pumpWidget(createTestApp());

        // Navigate to AI difficulty page
        AppRouter.router.go(AppRouter.aiSelect);
        await tester.pumpAndSettle();

        // Verify AI difficulty page is displayed
        expect(find.byType(AiDifficultyPage), findsOneWidget);
        expect(find.text('AI Difficulty Selection'), findsOneWidget);
      },
    );

    testWidgets('navigates to history page when /history route is accessed', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      // Navigate to history page
      AppRouter.router.go(AppRouter.history);
      await tester.pumpAndSettle();

      // Verify history page is displayed
      expect(find.byType(HistoryPage), findsOneWidget);
      // "Game History" appears in both AppBar and body
      expect(find.text('Game History'), findsAtLeastNWidgets(1));
    });

    testWidgets('navigates to game details page with gameId parameter', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      const testGameId = 'game-123';

      // Navigate to game details page with parameter
      AppRouter.router.go('/history/$testGameId');
      await tester.pumpAndSettle();

      // Verify game details page is displayed with correct ID
      expect(find.byType(GameDetailsPage), findsOneWidget);
      expect(find.text('Game ID: $testGameId'), findsOneWidget);
    });

    testWidgets('navigates to settings page when /settings route is accessed', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      // Navigate to settings page
      AppRouter.router.go(AppRouter.settings);
      await tester.pumpAndSettle();

      // Verify settings page is displayed
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('Settings'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows error page for invalid route', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Navigate to invalid route
      AppRouter.router.go('/invalid-route');
      await tester.pumpAndSettle();

      // Verify error page is displayed
      expect(find.text('404'), findsOneWidget);
      expect(find.text('Page Not Found'), findsOneWidget);
      expect(find.textContaining('Page not found'), findsOneWidget);
    });

    testWidgets('error page has back button that navigates home', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      // Navigate to invalid route
      AppRouter.router.go('/invalid-route');
      await tester.pumpAndSettle();

      // Tap the back button in AppBar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // Verify we're back at home by checking router location
      expect(
        AppRouter.router.routerDelegate.currentConfiguration.uri.path,
        equals('/'),
      );
    });

    testWidgets('error page has home button that navigates home', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      // Navigate to invalid route
      AppRouter.router.go('/invalid-route');
      await tester.pumpAndSettle();

      // Tap the "Go Home" button
      await tester.tap(find.text('Go Home'));
      await tester.pump();

      // Verify we're back at home by checking router location
      expect(
        AppRouter.router.routerDelegate.currentConfiguration.uri.path,
        equals('/'),
      );
    });

    test('route constants are correctly defined', () {
      // Verify all route constants exist
      expect(AppRouter.home, equals('/'));
      expect(AppRouter.game, equals('/game'));
      expect(AppRouter.aiSelect, equals('/ai-select'));
      expect(AppRouter.history, equals('/history'));
      expect(AppRouter.gameDetails, equals('/history/:gameId'));
      expect(AppRouter.settings, equals('/settings'));
    });
  });
}
