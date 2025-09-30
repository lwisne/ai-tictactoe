import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TicTacToeApp());

    // Wait for all animations to complete
    await tester.pumpAndSettle();

    // Verify that the home page loads
    expect(find.text('Tic-Tac-Toe'), findsAtLeastNWidgets(1));
  });
}
