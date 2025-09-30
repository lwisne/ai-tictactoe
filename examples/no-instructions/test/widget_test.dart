import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_tictactoe/main.dart';

void main() {
  testWidgets('Initial game state test', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    expect(find.text('Player X\'s turn'), findsOneWidget);
    expect(find.text('Reset Game'), findsOneWidget);
  });

  testWidgets('Player can make a move', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final firstCell = find.byType(GestureDetector).first;
    await tester.tap(firstCell);
    await tester.pump();

    expect(find.text('X'), findsOneWidget);
    expect(find.text('Player O\'s turn'), findsOneWidget);
  });

  testWidgets('Players alternate turns', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final cells = find.byType(GestureDetector);

    await tester.tap(cells.at(0));
    await tester.pump();
    expect(find.text('Player O\'s turn'), findsOneWidget);

    await tester.tap(cells.at(1));
    await tester.pump();
    expect(find.text('Player X\'s turn'), findsOneWidget);
  });

  testWidgets('Cannot tap already filled cell', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final firstCell = find.byType(GestureDetector).first;

    await tester.tap(firstCell);
    await tester.pump();
    expect(find.text('X'), findsOneWidget);

    await tester.tap(firstCell);
    await tester.pump();
    expect(find.text('X'), findsOneWidget);
    expect(find.text('O'), findsNothing);
  });

  testWidgets('Horizontal win detection', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final cells = find.byType(GestureDetector);

    // X wins in top row: X X X
    await tester.tap(cells.at(0));
    await tester.pump();
    await tester.tap(cells.at(3));
    await tester.pump();
    await tester.tap(cells.at(1));
    await tester.pump();
    await tester.tap(cells.at(4));
    await tester.pump();
    await tester.tap(cells.at(2));
    await tester.pump();

    expect(find.text('Player X wins!'), findsOneWidget);
  });

  testWidgets('Vertical win detection', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final cells = find.byType(GestureDetector);

    // X wins in first column
    await tester.tap(cells.at(0));
    await tester.pump();
    await tester.tap(cells.at(1));
    await tester.pump();
    await tester.tap(cells.at(3));
    await tester.pump();
    await tester.tap(cells.at(2));
    await tester.pump();
    await tester.tap(cells.at(6));
    await tester.pump();

    expect(find.text('Player X wins!'), findsOneWidget);
  });

  testWidgets('Diagonal win detection', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final cells = find.byType(GestureDetector);

    // X wins diagonally
    await tester.tap(cells.at(0));
    await tester.pump();
    await tester.tap(cells.at(1));
    await tester.pump();
    await tester.tap(cells.at(4));
    await tester.pump();
    await tester.tap(cells.at(2));
    await tester.pump();
    await tester.tap(cells.at(8));
    await tester.pump();

    expect(find.text('Player X wins!'), findsOneWidget);
  });

  testWidgets('Draw detection', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final cells = find.byType(GestureDetector);

    // Create a draw scenario
    await tester.tap(cells.at(0)); // X
    await tester.pump();
    await tester.tap(cells.at(1)); // O
    await tester.pump();
    await tester.tap(cells.at(2)); // X
    await tester.pump();
    await tester.tap(cells.at(4)); // O
    await tester.pump();
    await tester.tap(cells.at(3)); // X
    await tester.pump();
    await tester.tap(cells.at(5)); // O
    await tester.pump();
    await tester.tap(cells.at(7)); // X
    await tester.pump();
    await tester.tap(cells.at(6)); // O
    await tester.pump();
    await tester.tap(cells.at(8)); // X
    await tester.pump();

    expect(find.text('It\'s a draw!'), findsOneWidget);
  });

  testWidgets('Reset game functionality', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final cells = find.byType(GestureDetector);

    await tester.tap(cells.at(0));
    await tester.pump();
    expect(find.text('X'), findsOneWidget);

    await tester.tap(find.text('Reset Game'));
    await tester.pump();

    expect(find.text('X'), findsNothing);
    expect(find.text('Player X\'s turn'), findsOneWidget);
  });

  testWidgets('Cannot play after game is won', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final cells = find.byType(GestureDetector);

    // X wins in top row
    await tester.tap(cells.at(0));
    await tester.pump();
    await tester.tap(cells.at(3));
    await tester.pump();
    await tester.tap(cells.at(1));
    await tester.pump();
    await tester.tap(cells.at(4));
    await tester.pump();
    await tester.tap(cells.at(2));
    await tester.pump();

    expect(find.text('Player X wins!'), findsOneWidget);

    // Try to make another move
    await tester.tap(cells.at(5));
    await tester.pump();

    expect(find.text('Player X wins!'), findsOneWidget);
  });
}