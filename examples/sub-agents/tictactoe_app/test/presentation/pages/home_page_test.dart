import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/core/theme/app_theme.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/domain/models/persisted_game_state.dart';
import 'package:tictactoe_app/domain/services/game_service.dart';
import 'package:tictactoe_app/domain/models/game_config.dart';
import 'package:tictactoe_app/domain/models/player.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_bloc.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_event.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_state.dart'
    as game_states;
import 'package:tictactoe_app/presentation/cubits/game_mode_cubit.dart';
import 'package:tictactoe_app/presentation/pages/home_page.dart';

class MockGameModeCubit extends Mock implements GameModeCubit {}

class MockGameBloc extends Mock implements GameBloc {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late GameModeCubit mockGameModeCubit;
  late GameBloc mockGameBloc;
  late GoRouter mockRouter;

  setUpAll(() {
    registerFallbackValue(GameMode.vsAi);
    registerFallbackValue(Uri.parse('/'));
    registerFallbackValue(const game_states.GameInitial());
    registerFallbackValue(const ResumeGame());
    registerFallbackValue(const ClearSavedGameState());
  });

  setUp(() {
    mockGameModeCubit = MockGameModeCubit();
    mockGameBloc = MockGameBloc();
    mockRouter = MockGoRouter();

    // Default stubs for GameModeCubit
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

    // Default stubs for GameBloc
    when(() => mockGameBloc.state).thenReturn(const game_states.GameInitial());
    when(
      () => mockGameBloc.stream,
    ).thenAnswer((_) => Stream.value(const game_states.GameInitial()));
    when(() => mockGameBloc.close()).thenAnswer((_) async {});
    when(() => mockGameBloc.add(any())).thenReturn(null);
  });

  tearDown(() async {
    await mockGameModeCubit.close();
    await mockGameBloc.close();
  });

  Widget createTestWidget({
    GameModeState? gameModeState,
    game_states.GameState? gameState,
  }) {
    if (gameModeState != null) {
      when(() => mockGameModeCubit.state).thenReturn(gameModeState);
      when(
        () => mockGameModeCubit.stream,
      ).thenAnswer((_) => Stream.value(gameModeState));
    }

    if (gameState != null) {
      when(() => mockGameBloc.state).thenReturn(gameState);
      when(
        () => mockGameBloc.stream,
      ).thenAnswer((_) => Stream.value(gameState));
    }

    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: InheritedGoRouter(
        goRouter: mockRouter,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<GameModeCubit>.value(value: mockGameModeCubit),
            BlocProvider<GameBloc>.value(value: mockGameBloc),
          ],
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
        createTestWidget(gameModeState: const GameModeState(isLoading: true)),
      );
      await tester.pump(); // Don't use pumpAndSettle for loading indicators

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should highlight vsAi mode as last played', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          gameModeState: const GameModeState(
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
          gameModeState: const GameModeState(
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
          gameModeState: const GameModeState(
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
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The page should still render without overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display properly on large screens', (tester) async {
      // Set a large screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify all elements are still visible
      expect(find.text('Tic-Tac-Toe'), findsNWidgets(2));
      expect(find.text('Play vs AI'), findsOneWidget);
      expect(find.text('Two Player'), findsOneWidget);
      expect(find.text('Game History'), findsOneWidget);
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

  group('Resume Game Dialog Tests', () {
    testWidgets(
      'should show resume dialog when GameSavedStateDetected is emitted',
      (tester) async {
        // Create a saved game state
        final gameService = GameService();
        final gameState = gameService.createNewGame(
          const GameConfig(gameMode: GameMode.twoPlayer, firstPlayer: Player.x),
        );
        final persistedState = PersistedGameState(
          gameState: gameState,
          savedAt: DateTime.now(),
        );

        // Set up the GameBloc to emit GameSavedStateDetected
        when(() => mockGameBloc.stream).thenAnswer(
          (_) =>
              Stream.value(game_states.GameSavedStateDetected(persistedState)),
        );
        when(
          () => mockGameBloc.state,
        ).thenReturn(game_states.GameSavedStateDetected(persistedState));

        await tester.pumpWidget(
          createTestWidget(
            gameState: game_states.GameSavedStateDetected(persistedState),
          ),
        );
        await tester.pump(); // Trigger BlocListener

        // Verify dialog is shown
        expect(find.text('Resume Game?'), findsOneWidget);
        expect(
          find.text(
            'You have an in-progress game. Would you like to resume where you left off?',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should dispatch ResumeGame event and navigate when user taps Resume',
      (tester) async {
        // Create a saved game state
        final gameService = GameService();
        final gameState = gameService.createNewGame(
          const GameConfig(gameMode: GameMode.twoPlayer, firstPlayer: Player.x),
        );
        final persistedState = PersistedGameState(
          gameState: gameState,
          savedAt: DateTime.now(),
        );

        // Set up router stub
        when(() => mockRouter.push(any())).thenAnswer((_) async => null);

        // Set up the GameBloc to emit GameSavedStateDetected
        when(() => mockGameBloc.stream).thenAnswer(
          (_) =>
              Stream.value(game_states.GameSavedStateDetected(persistedState)),
        );
        when(
          () => mockGameBloc.state,
        ).thenReturn(game_states.GameSavedStateDetected(persistedState));

        await tester.pumpWidget(
          createTestWidget(
            gameState: game_states.GameSavedStateDetected(persistedState),
          ),
        );
        await tester.pump(); // Trigger BlocListener

        // Tap the Resume button
        await tester.tap(find.text('Resume'));
        await tester.pumpAndSettle();

        // Verify ResumeGame event was dispatched
        verify(() => mockGameBloc.add(const ResumeGame())).called(1);

        // Verify navigation to game page
        verify(() => mockRouter.push('/game')).called(1);
      },
    );

    testWidgets(
      'should dispatch ClearSavedGameState event when user taps New Game',
      (tester) async {
        // Create a saved game state
        final gameService = GameService();
        final gameState = gameService.createNewGame(
          const GameConfig(gameMode: GameMode.twoPlayer, firstPlayer: Player.x),
        );
        final persistedState = PersistedGameState(
          gameState: gameState,
          savedAt: DateTime.now(),
        );

        // Set up the GameBloc to emit GameSavedStateDetected
        when(() => mockGameBloc.stream).thenAnswer(
          (_) =>
              Stream.value(game_states.GameSavedStateDetected(persistedState)),
        );
        when(
          () => mockGameBloc.state,
        ).thenReturn(game_states.GameSavedStateDetected(persistedState));

        await tester.pumpWidget(
          createTestWidget(
            gameState: game_states.GameSavedStateDetected(persistedState),
          ),
        );
        await tester.pump(); // Trigger BlocListener

        // Tap the New Game button
        await tester.tap(find.text('New Game'));
        await tester.pumpAndSettle();

        // Verify ClearSavedGameState event was dispatched
        verify(() => mockGameBloc.add(const ClearSavedGameState())).called(1);

        // Should NOT navigate
        verifyNever(() => mockRouter.push(any()));
      },
    );

    testWidgets('should not show resume dialog when state is GameInitial', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify dialog is not shown
      expect(find.text('Resume Game?'), findsNothing);
    });

    testWidgets('should not show resume dialog when state is GameInProgress', (
      tester,
    ) async {
      final gameService = GameService();
      final gameState = gameService.createNewGame(
        const GameConfig(gameMode: GameMode.twoPlayer, firstPlayer: Player.x),
      );

      await tester.pumpWidget(
        createTestWidget(gameState: game_states.GameInProgress(gameState)),
      );
      await tester.pumpAndSettle();

      // Verify dialog is not shown
      expect(find.text('Resume Game?'), findsNothing);
    });
  });
}
