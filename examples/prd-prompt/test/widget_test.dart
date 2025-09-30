// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TicTacToeApp());

    // Verify that the home screen loads with title
    expect(find.text('Tic-Tac-Toe'), findsOneWidget);
    expect(find.text('Two Player'), findsOneWidget);
    expect(find.text('vs AI'), findsOneWidget);
  });
}
