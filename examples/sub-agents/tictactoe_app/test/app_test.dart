import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/main.dart';

void main() {
  testWidgets('App initializes and shows placeholder home page', (
    WidgetTester tester,
  ) async {
    // Build the app
    await tester.pumpWidget(const TicTacToeApp());
    await tester.pumpAndSettle();

    // Verify the app title is displayed (appears in AppBar and body)
    expect(find.text('Tic-Tac-Toe'), findsNWidgets(2));

    // Verify the placeholder success message
    expect(find.text('Project initialized successfully!'), findsOneWidget);

    // Verify the grid icon is displayed
    expect(find.byIcon(Icons.grid_3x3), findsOneWidget);
  });

  testWidgets('App uses Material 3', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify Material 3 is enabled in the theme
    expect(app.theme?.useMaterial3, isTrue);
  });

  testWidgets('App has dark theme configured', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify dark theme is configured
    expect(app.darkTheme, isNotNull);
    expect(app.darkTheme?.useMaterial3, isTrue);
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    expect(app.title, 'Tic-Tac-Toe');
  });

  testWidgets('App has router configuration', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify router is configured
    expect(app.routerConfig, isNotNull);
  });

  testWidgets('App has debug banner disabled', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    expect(app.debugShowCheckedModeBanner, isFalse);
  });
}
