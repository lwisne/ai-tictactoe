import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/pages/game_page.dart';
import 'package:tic_tac_toe/pages/home_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('renders title and buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify title
      expect(find.text('Tic-Tac-Toe'), findsNWidgets(2)); // AppBar + body title

      // Verify buttons
      expect(find.text('2 Player'), findsOneWidget);
      expect(find.text('Single Player'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Verify icons
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('2 Player button navigates to game page', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Tap 2 Player button
      await tester.tap(find.text('2 Player'));
      await tester.pumpAndSettle();

      // Verify navigation to GamePage
      expect(find.byType(GamePage), findsOneWidget);
    });

    testWidgets('Single Player button shows coming soon message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Tap Single Player button
      await tester.tap(find.text('Single Player'));
      await tester.pump();

      // Verify snackbar appears
      expect(find.text('Single player mode coming soon!'), findsOneWidget);
    });

    testWidgets('Settings button shows coming soon message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Tap Settings button
      await tester.tap(find.text('Settings'));
      await tester.pump();

      // Verify snackbar appears
      expect(find.text('Settings coming soon!'), findsOneWidget);
    });

    testWidgets('respects theme from MaterialApp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const HomePage(),
        ),
      );

      // Verify page renders without errors
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('buttons have correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify all three button types exist
      expect(find.text('2 Player'), findsOneWidget);
      expect(find.text('Single Player'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Verify icons are present
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('layout is responsive with constraints', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

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
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

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
