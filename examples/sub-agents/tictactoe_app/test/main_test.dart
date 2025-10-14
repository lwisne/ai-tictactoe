import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/main.dart' as app;

void main() {
  testWidgets('main initializes app correctly', (WidgetTester tester) async {
    // Call the main function
    app.main();
    await tester.pumpAndSettle();

    // Verify the app is initialized
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
