import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/core/theme/app_theme.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/presentation/cubits/game_mode_cubit.dart';
import 'package:tictactoe_app/presentation/pages/home_page.dart';

class MockGameModeCubit extends Mock implements GameModeCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late GameModeCubit mockGameModeCubit;
  late GoRouter mockRouter;

  setUpAll(() {
    registerFallbackValue(GameMode.vsAi);
    registerFallbackValue(Uri.parse('/'));
  });

  setUp(() {
    mockGameModeCubit = MockGameModeCubit();
    mockRouter = MockGoRouter();

    // Default stub for state stream
    when(
      () => mockGameModeCubit.state,
    ).thenReturn(const GameModeState(lastPlayedMode: null, isLoading: false));

    when(() => mockGameModeCubit.stream).thenAnswer(
      (_) => Stream.value(
        const GameModeState(lastPlayedMode: null, isLoading: false),
      ),
    );

    // Stub close method
    when(() => mockGameModeCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await mockGameModeCubit.close();
  });

  Widget createTestWidget({GameModeState? initialState}) {
    if (initialState != null) {
      when(() => mockGameModeCubit.state).thenReturn(initialState);
      when(
        () => mockGameModeCubit.stream,
      ).thenAnswer((_) => Stream.value(initialState));
    }

    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: InheritedGoRouter(
        goRouter: mockRouter,
        child: BlocProvider<GameModeCubit>.value(
          value: mockGameModeCubit,
          child: const HomePageContent(),
        ),
      ),
    );
  }

  group('HomePageContent Widget Tests', () {
    testWidgets('should display app title and subtitle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tic-Tac-Toe'), findsNWidgets(2)); // AppBar + hero title
      expect(find.text('Select a game mode to begin'), findsOneWidget);
    });

    testWidgets('should display app icon/logo', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.grid_3x3), findsOneWidget);
    });

    testWidgets('should display both mode selection buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Play vs AI'), findsOneWidget);
      expect(find.text('Challenge the AI'), findsOneWidget);
      expect(find.text('Two Player'), findsOneWidget);
      expect(find.text('Pass & Play on this device'), findsOneWidget);
    });

    testWidgets('should display navigation buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Game History'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        createTestWidget(initialState: const GameModeState(isLoading: true)),
      );
      await tester.pump(); // Don't use pumpAndSettle for loading indicators

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should highlight vsAi mode as last played', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          initialState: const GameModeState(
            lastPlayedMode: GameMode.vsAi,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the "Last played" text which only appears on highlighted mode
      expect(find.text('Last played'), findsOneWidget);
    });

    testWidgets('should highlight twoPlayer mode as last played', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          initialState: const GameModeState(
            lastPlayedMode: GameMode.twoPlayer,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the "Last played" text
      expect(find.text('Last played'), findsOneWidget);
    });

    testWidgets('should not show last played indicator when no mode saved', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          initialState: const GameModeState(
            lastPlayedMode: null,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Last played'), findsNothing);
    });

    testWidgets('should call selectGameMode and navigate on vsAi tap', (
      tester,
    ) async {
      when(
        () => mockGameModeCubit.selectGameMode(any()),
      ).thenAnswer((_) async {});
      when(() => mockRouter.push(any())).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the Play vs AI button
      await tester.tap(find.text('Play vs AI'));
      await tester.pumpAndSettle();

      verify(() => mockGameModeCubit.selectGameMode(GameMode.vsAi)).called(1);
      verify(() => mockRouter.push('/ai-select')).called(1);
    });

    testWidgets('should call selectGameMode and navigate on twoPlayer tap', (
      tester,
    ) async {
      when(
        () => mockGameModeCubit.selectGameMode(any()),
      ).thenAnswer((_) async {});
      when(() => mockRouter.push(any())).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the Two Player button
      await tester.tap(find.text('Two Player'));
      await tester.pumpAndSettle();

      verify(
        () => mockGameModeCubit.selectGameMode(GameMode.twoPlayer),
      ).called(1);
      verify(() => mockRouter.push('/game')).called(1);
    });

    testWidgets('should navigate to history on history button tap', (
      tester,
    ) async {
      when(() => mockRouter.push(any())).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the button and scroll to it if needed
      await tester.ensureVisible(find.text('Game History'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Game History'));
      await tester.pumpAndSettle();

      verify(() => mockRouter.push('/history')).called(1);
    });

    testWidgets('should navigate to settings on settings button tap', (
      tester,
    ) async {
      when(() => mockRouter.push(any())).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      verify(() => mockRouter.push('/settings')).called(1);
    });

    testWidgets('should have proper semantics for accessibility', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that Semantics widgets exist for buttons
      expect(find.byType(Semantics), findsWidgets);

      // Check settings button has semantics (there may be multiple ancestor Semantics)
      final settingsButton = find.byIcon(Icons.settings_outlined);
      expect(
        find.ancestor(of: settingsButton, matching: find.byType(Semantics)),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('should be scrollable on small screens', (tester) async {
      // Set a small screen size
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The page should still render without overflow
      expect(tester.takeException(), isNull);

      // Clean up
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should display properly on large screens', (tester) async {
      // Set a large screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify all elements are still visible
      expect(find.text('Tic-Tac-Toe'), findsNWidgets(2));
      expect(find.text('Play vs AI'), findsOneWidget);
      expect(find.text('Two Player'), findsOneWidget);
      expect(find.text('Game History'), findsOneWidget);

      // Clean up
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should display mode icons correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for AI and people icons
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('should have proper button sizes for touch targets', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the FilledButton widgets
      final filledButtons = find.byType(FilledButton);
      expect(filledButtons, findsNWidgets(2));

      // Get sizes of both buttons
      final sizes = tester.getSize(filledButtons.first);

      // Verify minimum height (should be at least 80dp as per spec)
      expect(sizes.height, greaterThanOrEqualTo(80.0));
    });
  });
}
