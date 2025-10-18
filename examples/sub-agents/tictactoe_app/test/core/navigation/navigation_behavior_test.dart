import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/core/navigation/navigation_behavior.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_bloc.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_event.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_state.dart'
    as game_states;
import 'package:tictactoe_app/presentation/pages/home_page.dart';
import 'package:tictactoe_app/presentation/pages/settings_page.dart';
import 'package:tictactoe_app/routes/app_router.dart';

import '../../helpers/test_helpers.dart';

class MockGameBloc extends Mock implements GameBloc {}

class FakeGameEvent extends Fake implements GameEvent {}

void main() {
  late GameBloc mockGameBloc;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(GameMode.vsAi);
    registerFallbackValue(const game_states.GameInitial());
    registerFallbackValue(FakeGameEvent());
  });

  group('NavigationBehavior', () {
    setUp(() async {
      // Set up DI container with mocked dependencies
      await setupTestDI();

      // Create mock GameBloc with default behavior
      mockGameBloc = MockGameBloc();
      when(
        () => mockGameBloc.state,
      ).thenReturn(const game_states.GameInitial());
      when(
        () => mockGameBloc.stream,
      ).thenAnswer((_) => Stream.value(const game_states.GameInitial()));
      when(() => mockGameBloc.close()).thenAnswer((_) async {});
      when(() => mockGameBloc.add(any())).thenAnswer((_) {});
    });

    tearDown(() async {
      // Clean up DI container
      await teardownTestDI();
      await mockGameBloc.close();
    });

    Widget createTestApp() {
      return BlocProvider<GameBloc>.value(
        value: mockGameBloc,
        child: MaterialApp.router(routerConfig: AppRouter.router),
      );
    }

    testWidgets('goBack pops navigation stack when canPop is true', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to settings using push() to create a navigation stack
      AppRouter.router.push('/settings');
      await tester.pumpAndSettle();

      // Verify we're on settings page by widget type
      expect(find.byType(SettingsPage), findsOneWidget);

      // Get context and go back
      final context = tester.element(find.byType(Scaffold).first);
      NavigationBehavior.goBack(context);
      await tester.pumpAndSettle();

      // Verify we're back at home by widget type
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('goBack does nothing when canPop is false', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // We're on home page (canPop is false with go_router at root)
      final context = tester.element(find.byType(Scaffold).first);

      // Verify we're at home before attempting to go back by widget type
      expect(find.byType(HomePage), findsOneWidget);

      // Try to go back - should stay on home (no-op when canPop is false)
      NavigationBehavior.goBack(context);
      await tester.pumpAndSettle();

      // Verify still on home - goBack() correctly did nothing
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('goHome navigates to home screen', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to settings (using go() is fine here since we're testing goHome())
      AppRouter.router.go('/settings');
      await tester.pumpAndSettle();

      // Verify we're on settings by widget type
      expect(find.byType(SettingsPage), findsOneWidget);

      // Get context and go home
      final context = tester.element(find.byType(Scaffold).first);
      NavigationBehavior.goHome(context);
      await tester.pumpAndSettle();

      // Verify we're at home by widget type
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('canNavigateBack returns true when stack has routes', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to settings using push() to create a navigation stack
      AppRouter.router.push('/settings');
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);
      expect(NavigationBehavior.canNavigateBack(context), isTrue);
    });

    testWidgets('canNavigateBack delegates to context.canPop', (tester) async {
      // Create a fresh router for this test to ensure clean state
      final testRouter = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Home'))),
          ),
        ],
      );

      await tester.pumpWidget(
        BlocProvider<GameBloc>.value(
          value: mockGameBloc,
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      // Get context and verify canNavigateBack matches GoRouter's canPop()
      final context = tester.element(find.byType(Scaffold).first);
      final canPop = GoRouter.of(context).canPop();
      final canNavigateBack = NavigationBehavior.canNavigateBack(context);

      // canNavigateBack should always match context.canPop() (via go_router)
      expect(canNavigateBack, equals(canPop));
    });

    testWidgets('showConfirmationDialog displays alert with correct text', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);

      // Show confirmation dialog without awaiting
      NavigationBehavior.showConfirmationDialog(
        context: context,
        title: 'Test Title',
        content: 'Test Content',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
      );

      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('showConfirmationDialog returns true on confirm', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);

      // Show confirmation dialog
      final resultFuture = NavigationBehavior.showConfirmationDialog(
        context: context,
        title: 'Test',
        content: 'Test',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
      );

      await tester.pumpAndSettle();

      // Tap confirm button
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      final result = await resultFuture;
      expect(result, isTrue);
    });

    testWidgets('showConfirmationDialog returns false on cancel', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);

      // Show confirmation dialog
      final resultFuture = NavigationBehavior.showConfirmationDialog(
        context: context,
        title: 'Test',
        content: 'Test',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
      );

      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final result = await resultFuture;
      expect(result, isFalse);
    });

    testWidgets('showExitGameConfirmation displays correct exit game dialog', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);

      // Show exit game confirmation
      NavigationBehavior.showExitGameConfirmation(context);
      await tester.pumpAndSettle();

      // Verify exit game dialog content
      expect(find.text('Exit Game?'), findsOneWidget);
      expect(find.textContaining('Your progress will be lost'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('showExitGameConfirmation returns true on exit', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);

      // Show exit game confirmation
      final resultFuture = NavigationBehavior.showExitGameConfirmation(context);
      await tester.pumpAndSettle();

      // Tap exit button
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      final result = await resultFuture;
      expect(result, isTrue);
    });

    testWidgets('showExitGameConfirmation returns false on cancel', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);

      // Show exit game confirmation
      final resultFuture = NavigationBehavior.showExitGameConfirmation(context);
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final result = await resultFuture;
      expect(result, isFalse);
    });
  });
}
