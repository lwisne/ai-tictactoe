import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/core/di/injection.dart';
import 'package:tictactoe_app/main.dart';
import 'package:tictactoe_app/presentation/pages/home_page.dart';

void main() {
  setUpAll(() {
    // Initialize dependency injection for tests
    configureDependencies();
  });

  testWidgets('App initializes and shows home page', (
    WidgetTester tester,
  ) async {
    // Build the app
    await tester.pumpWidget(const TicTacToeApp());

    // Pump to build initial frame
    await tester.pump();
    // Pump to complete async BLoC initialization
    await tester.pump();

    // Verify the home page is displayed (widget type, not text - more resilient)
    expect(find.byType(HomePage), findsOneWidget);

    // Verify app title is displayed
    expect(find.text('Tic-Tac-Toe'), findsAtLeastNWidgets(1));
  });

  testWidgets('App uses Material 3', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());
    await tester.pump();

    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify Material 3 is enabled in the theme
    expect(app.theme?.useMaterial3, isTrue);
  });

  testWidgets('App has dark theme configured', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());
    await tester.pump();

    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify dark theme is configured
    expect(app.darkTheme, isNotNull);
    expect(app.darkTheme?.useMaterial3, isTrue);
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());
    await tester.pump();

    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    expect(app.title, 'Tic-Tac-Toe');
  });

  testWidgets('App has router configuration', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());
    await tester.pump();

    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify router is configured
    expect(app.routerConfig, isNotNull);
  });

  testWidgets('App has debug banner disabled', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());
    await tester.pump();

    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    expect(app.debugShowCheckedModeBanner, isFalse);
  });
}
