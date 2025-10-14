import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/presentation/pages/home_page.dart';
import 'package:tictactoe_app/presentation/pages/game_page.dart';
import 'package:tictactoe_app/presentation/pages/settings_page.dart';
import 'package:tictactoe_app/presentation/pages/history_page.dart';
import 'package:tictactoe_app/presentation/pages/ai_difficulty_page.dart';
import 'package:tictactoe_app/presentation/pages/game_details_page.dart';
import 'package:tictactoe_app/routes/app_router.dart';

import '../../helpers/test_helpers.dart';

/// Integration tests for LWI-151: Navigation patterns and back button behavior
///
/// Tests the following requirements:
/// - Home screen: No back button (top-level)
/// - Game screen: Back shows exit confirmation dialog
/// - Settings screen: Back returns to previous screen (no confirmation)
/// - History screen: Back returns to previous screen (no confirmation)
/// - History details: Back returns to history list
/// - AI difficulty: Back returns to previous screen (no confirmation)
/// - Android system back button respects same behavior
///
/// Note: Uses AppRouter.router singleton with proper cleanup in tearDown
void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(GameMode.vsAi);
  });

  group('Back Button Behavior - LWI-151', () {
    setUp(() async {
      // Reset router to home to ensure clean state before each test
      AppRouter.router.go('/');
      // Set up DI container with mocked dependencies
      await setupTestDI();
    });

    tearDown(() async {
      // Clean up DI container
      await teardownTestDI();
    });

    group('Home Page', () {
      testWidgets('does not show back button in AppBar', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Verify we're on home page
        expect(find.byType(HomePage), findsOneWidget);

        // Verify no back button in AppBar
        expect(find.byIcon(Icons.arrow_back), findsNothing);
      });

      testWidgets('is at root level and cannot pop', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Verify we're at root
        final context = tester.element(find.byType(Scaffold).first);
        expect(Navigator.of(context).canPop(), isFalse);
      });
    });

    group('Game Page', () {
      testWidgets('shows back button in AppBar', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to game using push to build navigation stack
        AppRouter.router.push('/game');
        await tester.pumpAndSettle();

        // Verify back button exists
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('back button shows exit confirmation dialog', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to game using push to build navigation stack
        AppRouter.router.push('/game');
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Verify exit dialog is shown
        expect(find.text('Exit Game?'), findsOneWidget);
        expect(find.text('Exit'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('cancel button keeps user on game page', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to game using push to build navigation stack
        AppRouter.router.push('/game');
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Tap Cancel in dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify still on game page
        expect(find.byType(GamePage), findsOneWidget);
        expect(find.text('Game Page'), findsOneWidget);
      });

      testWidgets('exit button navigates to home', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to game using push to build navigation stack
        AppRouter.router.push('/game');
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Tap Exit in dialog
        await tester.tap(find.text('Exit'));
        await tester.pumpAndSettle();

        // Verify navigated to home
        expect(find.byType(HomePage), findsOneWidget);
        expect(find.text('Select a game mode to begin'), findsOneWidget);
      });

      testWidgets('Android system back button shows exit confirmation', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to game using push to build navigation stack
        AppRouter.router.push('/game');
        await tester.pumpAndSettle();

        // Simulate Android system back button by attempting to pop
        final scaffoldContext = tester.element(find.byType(Scaffold).first);
        final bool canPop = Navigator.of(scaffoldContext).canPop();
        expect(canPop, isTrue); // Verify there is a route to pop

        // Attempt to pop the route which should trigger PopScope
        Navigator.of(scaffoldContext).maybePop();
        await tester.pumpAndSettle(); // Wait for dialog animation to complete

        // Verify exit dialog is shown
        expect(find.text('Exit Game?'), findsOneWidget);
      });
    });

    group('Settings Page', () {
      testWidgets('shows back button in AppBar', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to settings using push to build navigation stack
        AppRouter.router.push('/settings');
        await tester.pumpAndSettle();

        // Verify back button exists
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('back button returns to home without confirmation', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to settings using push to build navigation stack
        AppRouter.router.push('/settings');
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Verify no dialog shown and navigated to home
        expect(find.text('Exit Game?'), findsNothing);
        expect(find.byType(HomePage), findsOneWidget);
      });

      testWidgets('Android system back button returns to home directly', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to settings using push to build navigation stack
        AppRouter.router.push('/settings');
        await tester.pumpAndSettle();

        // Simulate Android system back button by attempting to pop
        final scaffoldContext = tester.element(find.byType(Scaffold).first);
        Navigator.of(scaffoldContext).maybePop();
        await tester.pumpAndSettle();

        // Verify no dialog and back at home
        expect(find.text('Exit Game?'), findsNothing);
        expect(find.byType(HomePage), findsOneWidget);
      });
    });

    group('History Page', () {
      testWidgets('shows back button in AppBar', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to history using push to build navigation stack
        AppRouter.router.push('/history');
        await tester.pumpAndSettle();

        // Verify back button exists
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('back button returns to home without confirmation', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to history using push to build navigation stack
        AppRouter.router.push('/history');
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Verify no dialog shown and navigated to home
        expect(find.text('Exit Game?'), findsNothing);
        expect(find.byType(HomePage), findsOneWidget);
      });
    });

    group('Game Details Page', () {
      testWidgets('shows back button in AppBar', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to game details using push to build navigation stack
        AppRouter.router.push('/history/game-123');
        await tester.pumpAndSettle();

        // Verify back button exists
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('back button returns to history list without confirmation', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // First navigate to history, then to details to build proper stack
        AppRouter.router.push('/history');
        await tester.pumpAndSettle();

        AppRouter.router.push('/history/game-123');
        await tester.pumpAndSettle();

        // Verify on details page
        expect(find.byType(GameDetailsPage), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Verify no dialog shown and back at history list
        expect(find.text('Exit Game?'), findsNothing);
        expect(find.byType(HistoryPage), findsOneWidget);
      });
    });

    group('AI Difficulty Page', () {
      testWidgets('shows back button in AppBar', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to AI difficulty using push to build navigation stack
        AppRouter.router.push('/ai-select');
        await tester.pumpAndSettle();

        // Verify back button exists
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('back button returns to home without confirmation', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to AI difficulty using push to build navigation stack
        AppRouter.router.push('/ai-select');
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Verify no dialog shown and navigated to home
        expect(find.text('Exit Game?'), findsNothing);
        expect(find.byType(HomePage), findsOneWidget);
      });
    });

    group('Navigation Flow', () {
      testWidgets('home -> settings -> back to home', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Start at home
        expect(find.byType(HomePage), findsOneWidget);

        // Go to settings using push to build stack
        AppRouter.router.push('/settings');
        await tester.pumpAndSettle();
        expect(find.byType(SettingsPage), findsOneWidget);

        // Back to home
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.byType(HomePage), findsOneWidget);
      });

      testWidgets('home -> history -> details -> back to history', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Start at home
        expect(find.byType(HomePage), findsOneWidget);

        // Go to history using push
        AppRouter.router.push('/history');
        await tester.pumpAndSettle();
        expect(find.byType(HistoryPage), findsOneWidget);

        // Go to game details using push
        AppRouter.router.push('/history/game-123');
        await tester.pumpAndSettle();
        expect(find.byType(GameDetailsPage), findsOneWidget);

        // Back to history
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.byType(HistoryPage), findsOneWidget);
      });

      testWidgets('game exit dialog navigates to home', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: AppRouter.router),
        );
        await tester.pumpAndSettle();

        // Navigate to game
        AppRouter.router.push('/game');
        await tester.pumpAndSettle();
        expect(find.byType(GamePage), findsOneWidget);

        // Try to go back - shows confirmation
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.text('Exit Game?'), findsOneWidget);

        // Cancel - stay in game
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(GamePage), findsOneWidget);

        // Try again and exit - this goes to home via context.go('/')
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Exit'));
        await tester.pumpAndSettle();

        // Should be at home (game page uses context.go('/') on exit)
        expect(find.byType(HomePage), findsOneWidget);
      });
    });
  });
}
