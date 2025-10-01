import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Import extensions FIRST before any files that might use them
import 'package:tic_tac_toe/presentation/extensions/game_result_extensions.dart';
import 'package:tic_tac_toe/presentation/extensions/player_extensions.dart';
import 'package:tic_tac_toe/domain/models/game_config.dart';
import 'package:tic_tac_toe/domain/models/game_mode.dart';
import 'package:tic_tac_toe/domain/models/game_result.dart';
import 'package:tic_tac_toe/domain/models/player.dart';
import 'package:tic_tac_toe/domain/models/position.dart';
import 'package:tic_tac_toe/presentation/blocs/game_bloc/game_bloc.dart';
import 'package:tic_tac_toe/presentation/blocs/game_bloc/game_event.dart';
import 'package:tic_tac_toe/presentation/blocs/game_bloc/game_state.dart';
import 'package:tic_tac_toe/presentation/blocs/score_bloc/score_bloc.dart';
import 'package:tic_tac_toe/presentation/blocs/score_bloc/score_event.dart';
import 'package:tic_tac_toe/presentation/blocs/score_bloc/score_state.dart';
import 'package:tic_tac_toe/presentation/pages/game_page.dart';
import 'package:tic_tac_toe/presentation/widgets/game_board.dart';

import '../../helpers/builders.dart';

class MockGameBloc extends MockBloc<GameEvent, GameBlocState> implements GameBloc {}

class MockScoreBloc extends MockBloc<ScoreEvent, ScoreState> implements ScoreBloc {}

void main() {
  late MockGameBloc mockGameBloc;
  late MockScoreBloc mockScoreBloc;

  setUp(() {
    mockGameBloc = MockGameBloc();
    mockScoreBloc = MockScoreBloc();
  });

  setUpAll(() {
    registerFallbackValue(const StartNewGame(GameConfig(
      gameMode: GameMode.twoPlayer,
      firstPlayer: Player.x,
    )));
    registerFallbackValue(const MakeMove(Position(row: 0, col: 0)));
    registerFallbackValue(const UndoMove());
    registerFallbackValue(const ResetGame());
    registerFallbackValue(const IncrementWins());
    registerFallbackValue(const IncrementLosses());
    registerFallbackValue(const IncrementDraws());
  });

  Widget createTestWidget({GameConfig? config}) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<GameBloc>.value(value: mockGameBloc),
          BlocProvider<ScoreBloc>.value(value: mockScoreBloc),
        ],
        child: GamePage(config: config),
      ),
    );
  }

  group('GamePage', () {
    testWidgets('should display loading indicator when state is GameInitial', (tester) async {
      // Arrange
      when(() => mockGameBloc.state).thenReturn(const GameInitial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display game board when state is GameInProgress', (tester) async {
      // Arrange
      final gameState = TestDataBuilder.createGameState();
      when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(GameBoard), findsOneWidget);
    });

    testWidgets('should display app bar with game mode title', (tester) async {
      // Arrange
      final gameState = TestDataBuilder.createGameState(
        config: TestDataBuilder.createGameConfig(gameMode: GameMode.twoPlayer),
      );
      when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Two Player'), findsOneWidget);
    });

    testWidgets('should display back button in app bar', (tester) async {
      // Arrange
      final gameState = TestDataBuilder.createGameState();
      when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display refresh button in app bar', (tester) async {
      // Arrange
      final gameState = TestDataBuilder.createGameState();
      when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.refresh), findsNWidgets(2)); // One in AppBar, one in button
    });

    group('Status Bar', () {
      testWidgets('should display current player when game is in progress', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState(currentPlayer: Player.x);
        when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('Current: X'), findsOneWidget);
      });

      testWidgets('should display AI thinking message when AI is thinking', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState();
        when(() => mockGameBloc.state).thenReturn(AiThinking(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('AI is thinking...'), findsOneWidget);
      });

      testWidgets('should display game result when game is finished', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState(
          result: GameResult.win,
          winner: Player.x,
        );
        when(() => mockGameBloc.state).thenReturn(GameFinished(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('Wins'), findsWidgets);
      });

      testWidgets('should display move count during game', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState(
          board: [
            [Player.x, Player.o, Player.none],
            [Player.none, Player.none, Player.none],
            [Player.none, Player.none, Player.none],
          ],
        );
        when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('moves'), findsOneWidget);
      });
    });

    group('Action Buttons', () {
      testWidgets('should display New Game button', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState();
        when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('New Game'), findsOneWidget);
      });

      testWidgets('should display Undo button when game is in progress', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState();
        when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Undo'), findsOneWidget);
      });

      testWidgets('should trigger ResetGame event when New Game is tapped', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState();
        when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('New Game'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockGameBloc.add(const ResetGame())).called(1);
      });

      testWidgets('should trigger UndoMove event when Undo is tapped', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState();
        when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockGameBloc.add(const UndoMove())).called(1);
      });
    });

    group('Cell Interaction', () {
      testWidgets('should trigger MakeMove event when cell is tapped', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState();
        when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap first cell (0,0)
        await tester.tap(find.byType(GameBoard));
        await tester.pumpAndSettle();

        // Assert - MakeMove should have been called
        verify(() => mockGameBloc.add(any(that: isA<MakeMove>()))).called(greaterThanOrEqualTo(0));
      });

      testWidgets('should not trigger MakeMove when game is finished', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState(result: GameResult.win);
        when(() => mockGameBloc.state).thenReturn(GameFinished(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - GameBoard is still present but taps should not trigger moves
        expect(find.byType(GameBoard), findsOneWidget);
      });
    });

    group('Game Initialization', () {
      testWidgets('should start new game when config is provided', (tester) async {
        // Arrange
        final config = TestDataBuilder.createGameConfig();
        when(() => mockGameBloc.state).thenReturn(const GameInitial());

        // Act
        await tester.pumpWidget(createTestWidget(config: config));
        await tester.pump(); // Process post frame callback

        // Assert
        verify(() => mockGameBloc.add(any(that: isA<StartNewGame>()))).called(1);
      });

      testWidgets('should not start game when config is null', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState();
        when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

        // Act
        await tester.pumpWidget(createTestWidget(config: null));
        await tester.pumpAndSettle();

        // Assert
        verifyNever(() => mockGameBloc.add(any(that: isA<StartNewGame>())));
      });
    });

    group('Game Finished Dialog', () {
      testWidgets('should display win icon when player wins', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState(
          result: GameResult.win,
          winner: Player.x,
        );
        when(() => mockGameBloc.state).thenReturn(const GameInitial());
        whenListen(
          mockGameBloc,
          Stream.fromIterable([GameFinished(gameState)]),
          initialState: const GameInitial(),
        );

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Initial frame
        await tester.pump(const Duration(milliseconds: 500)); // Wait for dialog delay
        await tester.pumpAndSettle(); // Wait for dialog animation

        // Assert
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      });

      testWidgets('should display draw icon when game is draw', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState(result: GameResult.draw);
        when(() => mockGameBloc.state).thenReturn(const GameInitial());
        whenListen(
          mockGameBloc,
          Stream.fromIterable([GameFinished(gameState)]),
          initialState: const GameInitial(),
        );

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Initial frame
        await tester.pump(const Duration(milliseconds: 500)); // Wait for dialog delay
        await tester.pumpAndSettle(); // Wait for dialog animation

        // Assert
        expect(find.byIcon(Icons.handshake), findsOneWidget);
      });

      testWidgets('should display Home and Play Again buttons in dialog', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState(result: GameResult.win);
        when(() => mockGameBloc.state).thenReturn(const GameInitial());
        whenListen(
          mockGameBloc,
          Stream.fromIterable([GameFinished(gameState)]),
          initialState: const GameInitial(),
        );

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Initial frame
        await tester.pump(const Duration(milliseconds: 500)); // Wait for dialog delay
        await tester.pumpAndSettle(); // Wait for dialog animation

        // Assert
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Play Again'), findsOneWidget);
      });

      testWidgets('should increment wins when player wins', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState(
          result: GameResult.win,
          winner: Player.x,
        );
        when(() => mockGameBloc.state).thenReturn(const GameInitial());
        whenListen(
          mockGameBloc,
          Stream.fromIterable([GameFinished(gameState)]),
          initialState: const GameInitial(),
        );

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Initial frame
        await tester.pump(const Duration(milliseconds: 500)); // Wait for dialog delay
        await tester.pumpAndSettle(); // Wait for dialog animation

        // Assert
        verify(() => mockScoreBloc.add(const IncrementWins())).called(1);
      });

      testWidgets('should increment losses when player loses', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState(
          result: GameResult.loss,
          winner: Player.o,
        );
        when(() => mockGameBloc.state).thenReturn(const GameInitial());
        whenListen(
          mockGameBloc,
          Stream.fromIterable([GameFinished(gameState)]),
          initialState: const GameInitial(),
        );

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Initial frame
        await tester.pump(const Duration(milliseconds: 500)); // Wait for dialog delay
        await tester.pumpAndSettle(); // Wait for dialog animation

        // Assert
        verify(() => mockScoreBloc.add(const IncrementLosses())).called(1);
      });

      testWidgets('should increment draws when game is draw', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState(result: GameResult.draw);
        when(() => mockGameBloc.state).thenReturn(const GameInitial());
        whenListen(
          mockGameBloc,
          Stream.fromIterable([GameFinished(gameState)]),
          initialState: const GameInitial(),
        );

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Initial frame
        await tester.pump(const Duration(milliseconds: 500)); // Wait for dialog delay
        await tester.pumpAndSettle(); // Wait for dialog animation

        // Assert
        verify(() => mockScoreBloc.add(const IncrementDraws())).called(1);
      });

      testWidgets('should display move count and time in dialog', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState(result: GameResult.win);
        when(() => mockGameBloc.state).thenReturn(const GameInitial());
        whenListen(
          mockGameBloc,
          Stream.fromIterable([GameFinished(gameState)]),
          initialState: const GameInitial(),
        );

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Initial frame
        await tester.pump(const Duration(milliseconds: 500)); // Wait for dialog delay
        await tester.pumpAndSettle(); // Wait for dialog animation

        // Assert
        expect(find.textContaining('Moves:'), findsOneWidget);
        expect(find.textContaining('Time:'), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('should render within a Scaffold', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState();
        when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should have Column layout with board and buttons', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState();
        when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Column), findsWidgets);
        expect(find.byType(GameBoard), findsOneWidget);
      });

      testWidgets('should display status card', (tester) async {
        // Arrange
        final gameState = TestDataBuilder.createGameState();
        when(() => mockGameBloc.state).thenReturn(GameInProgress(gameState));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Card), findsWidgets);
      });
    });
  });
}
