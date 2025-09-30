import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/presentation/blocs/score_bloc/score_bloc.dart';
import 'package:tic_tac_toe/presentation/blocs/score_bloc/score_event.dart';
import 'package:tic_tac_toe/presentation/blocs/score_bloc/score_state.dart';
import 'package:tic_tac_toe/presentation/pages/settings_page.dart';

import '../../helpers/builders.dart';

class MockScoreBloc extends MockBloc<ScoreEvent, ScoreState> implements ScoreBloc {}

void main() {
  late MockScoreBloc mockScoreBloc;

  setUp(() {
    mockScoreBloc = MockScoreBloc();
  });

  setUpAll(() {
    registerFallbackValue(const ResetScore());
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<ScoreBloc>.value(
        value: mockScoreBloc,
        child: const SettingsPage(),
      ),
    );
  }

  group('SettingsPage', () {
    testWidgets('should display app bar with title', (tester) async {
      // Arrange
      when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display Statistics section header', (tester) async {
      // Arrange
      when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('should display About section header', (tester) async {
      // Arrange
      when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('About'), findsOneWidget);
    });

    group('Statistics Section', () {
      testWidgets('should display loading indicator when state is not ScoreLoaded', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreLoading());

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Use pump() instead of pumpAndSettle() for loading indicators

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display statistics when state is ScoreLoaded', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 10, losses: 5, draws: 3);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Wins'), findsOneWidget);
        expect(find.text('Losses'), findsOneWidget);
        expect(find.text('Draws'), findsOneWidget);
        expect(find.text('Total Games'), findsOneWidget);
      });

      testWidgets('should display correct stat values', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 12, losses: 7, draws: 4);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('12'), findsOneWidget); // Wins
        expect(find.text('7'), findsOneWidget);  // Losses
        expect(find.text('4'), findsOneWidget);  // Draws
        expect(find.text('23'), findsOneWidget); // Total games
      });

      testWidgets('should display stat icons', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 5, losses: 3, draws: 2);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);
        expect(find.byIcon(Icons.sentiment_dissatisfied), findsOneWidget);
        expect(find.byIcon(Icons.handshake), findsOneWidget);
        expect(find.byIcon(Icons.games), findsOneWidget);
      });

      testWidgets('should display win rate when total games > 0', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 8, losses: 2, draws: 0);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Win Rate'), findsOneWidget);
        expect(find.text('80.0%'), findsOneWidget);
        expect(find.byIcon(Icons.percent), findsOneWidget);
      });

      testWidgets('should not display win rate when total games is 0', (tester) async {
        // Arrange
        const score = Score();
        when(() => mockScoreBloc.state).thenReturn(const ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Win Rate'), findsNothing);
        expect(find.byIcon(Icons.percent), findsNothing);
      });

      testWidgets('should display zero stats correctly', (tester) async {
        // Arrange
        const score = Score();
        when(() => mockScoreBloc.state).thenReturn(const ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('0'), findsNWidgets(4)); // Wins, Losses, Draws, Total
      });

      testWidgets('should display Reset Statistics button', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 5, losses: 3, draws: 2);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Reset Statistics'), findsOneWidget);
        expect(find.byIcon(Icons.delete_forever), findsOneWidget);
      });
    });

    group('Reset Confirmation Dialog', () {
      testWidgets('should show confirmation dialog when Reset button is tapped', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 5, losses: 3, draws: 2);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset Statistics'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Reset Statistics?'), findsOneWidget);
      });

      testWidgets('should display confirmation message in dialog', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 5, losses: 3, draws: 2);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset Statistics'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('permanently delete'), findsOneWidget);
        expect(find.textContaining('cannot be undone'), findsOneWidget);
      });

      testWidgets('should display Cancel and Reset buttons in dialog', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 5, losses: 3, draws: 2);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset Statistics'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Reset'), findsOneWidget);
      });

      testWidgets('should close dialog when Cancel is tapped', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 5, losses: 3, draws: 2);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset Statistics'));
        await tester.pumpAndSettle();

        expect(find.text('Reset Statistics?'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Reset Statistics?'), findsNothing);
        verifyNever(() => mockScoreBloc.add(const ResetScore()));
      });

      testWidgets('should trigger ResetScore event when Reset is confirmed', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 5, losses: 3, draws: 2);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset Statistics'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockScoreBloc.add(const ResetScore())).called(1);
      });

      testWidgets('should show snackbar after reset', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 5, losses: 3, draws: 2);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset Statistics'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Statistics reset successfully'), findsOneWidget);
      });

      testWidgets('should close dialog after reset is confirmed', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 5, losses: 3, draws: 2);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset Statistics'));
        await tester.pumpAndSettle();

        expect(find.text('Reset Statistics?'), findsOneWidget);

        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();

        // Assert - dialog should be closed
        expect(find.text('Reset Statistics?'), findsNothing);
      });
    });

    group('About Section', () {
      testWidgets('should display version information', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.text('Version'), findsOneWidget);
        expect(find.text('1.0.0'), findsOneWidget);
      });

      testWidgets('should display description', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.text('Description'), findsOneWidget);
        expect(find.textContaining('Tic-Tac-Toe game'), findsOneWidget);
      });

      testWidgets('should display built with information', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.text('Built with'), findsOneWidget);
        expect(find.text('Flutter & Material 3'), findsOneWidget);
      });

      testWidgets('should display about icons', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
        expect(find.byIcon(Icons.description), findsOneWidget);
        expect(find.byIcon(Icons.code), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('should render within a Scaffold', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should use ListView for content', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should have divider between sections', (tester) async {
        // Arrange
        when(() => mockScoreBloc.state).thenReturn(const ScoreInitial());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Divider), findsOneWidget);
      });

      testWidgets('should use ListTiles for stat items', (tester) async {
        // Arrange
        final score = TestDataBuilder.createScore(wins: 5, losses: 3, draws: 2);
        when(() => mockScoreBloc.state).thenReturn(ScoreLoaded(score));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ListTile), findsWidgets);
      });
    });
  });
}
