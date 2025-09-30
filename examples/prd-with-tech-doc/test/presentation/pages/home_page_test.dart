import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tic_tac_toe/domain/entities/difficulty_level.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/presentation/blocs/score_bloc/score_bloc.dart';
import 'package:tic_tac_toe/presentation/blocs/score_bloc/score_state.dart';
import 'package:tic_tac_toe/presentation/pages/home_page.dart';
import 'package:tic_tac_toe/routes/app_router.dart';

import '../../helpers/builders.dart';

class MockScoreBloc extends Mock implements ScoreBloc {}

class MockGoRouter extends Mock {
  void push(String path, {Object? extra});
}

void main() {
  late MockScoreBloc mockScoreBloc;
  late MockGoRouter mockRouter;

  setUp(() {
    mockScoreBloc = MockScoreBloc();
    mockRouter = MockGoRouter();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<ScoreBloc>.value(
        value: mockScoreBloc,
        child: const HomePage(),
      ),
    );
  }

  group('HomePage', () {
    testWidgets('should display app bar with title and settings button', (tester) async {
      // Arrange
      when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Tic-Tac-Toe'), findsNWidgets(2)); // Title in AppBar and body
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should display game icon', (tester) async {
      // Arrange
      when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.grid_3x3), findsOneWidget);
    });

    testWidgets('should display Single Player button', (tester) async {
      // Arrange
      when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Single Player'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should display Two Player button', (tester) async {
      // Arrange
      when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Two Player'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    group('Score Display', () {
      testWidgets('should not display score card when state is ScoreInitial', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Your Stats'), findsNothing);
      });

      testWidgets('should display score card when state is ScoreLoaded', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 10, losses: 5, draws: 3);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Your Stats'), findsOneWidget);
        expect(find.text('10'), findsOneWidget); // Wins
        expect(find.text('5'), findsOneWidget);  // Losses
        expect(find.text('3'), findsOneWidget);  // Draws
      });

      testWidgets('should display wins, losses, and draws labels', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 7, losses: 2, draws: 1);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Wins'), findsOneWidget);
        expect(find.text('Losses'), findsOneWidget);
        expect(find.text('Draws'), findsOneWidget);
      });

      testWidgets('should display win rate when total games > 0', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 8, losses: 2, draws: 0);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('Win Rate:'), findsOneWidget);
        expect(find.textContaining('80.0%'), findsOneWidget);
      });

      testWidgets('should not display win rate when total games is 0', (tester) async {
        // Arrange
        const score = Score();
        when(() => mockScoreBloc.state).thenReturn(const ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('Win Rate:'), findsNothing);
      });

      testWidgets('should display zero scores correctly', (tester) async {
        // Arrange
        const score = Score();
        when(() => mockScoreBloc.state).thenReturn(const ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('0'), findsNWidgets(3)); // Wins, Losses, Draws all 0
      });
    });

    group('Difficulty Dialog', () {
      testWidgets('should show difficulty dialog when Single Player button is tapped', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Single Player'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Select Difficulty'), findsOneWidget);
      });

      testWidgets('should display all difficulty levels in dialog', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Single Player'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Easy'), findsOneWidget);
        expect(find.text('Medium'), findsOneWidget);
        expect(find.text('Hard'), findsOneWidget);
      });

      testWidgets('should display difficulty descriptions', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Single Player'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(DifficultyLevel.easy.description), findsOneWidget);
        expect(find.text(DifficultyLevel.medium.description), findsOneWidget);
        expect(find.text(DifficultyLevel.hard.description), findsOneWidget);
      });

      testWidgets('should close dialog when difficulty is selected', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Single Player'));
        await tester.pumpAndSettle();

        expect(find.text('Select Difficulty'), findsOneWidget);

        await tester.tap(find.text('Easy'));
        await tester.pumpAndSettle();

        // Assert - dialog should be closed
        expect(find.text('Select Difficulty'), findsNothing);
      });
    });

    group('Layout', () {
      testWidgets('should render with SingleChildScrollView', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('should render within a Scaffold', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should have proper button styling', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final singlePlayerButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Single Player'),
        );
        expect(singlePlayerButton, isNotNull);

        final twoPlayerButton = tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Two Player'),
        );
        expect(twoPlayerButton, isNotNull);
      });
    });

    group('State Changes', () {
      testWidgets('should update score display when state changes', (tester) async {
        // Arrange
        final score1 = TestDataBuilder.createScore(wins: 5, losses: 3, draws: 2);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score1));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert initial state
        expect(find.text('5'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);

        // Update state
        final score2 = TestDataBuilder.createScore(wins: 10, losses: 5, draws: 3);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score2));
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert updated state
        expect(find.text('10'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('should handle loading state', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreLoading());

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - no score card should be displayed
        expect(find.text('Your Stats'), findsNothing);
      });
    });
  });
}
