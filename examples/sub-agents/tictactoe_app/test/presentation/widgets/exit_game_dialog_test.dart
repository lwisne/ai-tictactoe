import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/presentation/widgets/exit_game_dialog.dart';

void main() {
  group('ExitGameDialog', () {
    testWidgets('displays all required elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => ExitGameDialog.show(context),
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify all dialog elements are present
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
      expect(find.text('Exit Game?'), findsOneWidget);
      expect(find.textContaining('Your progress will be lost'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
    });

    testWidgets('has correct button styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => ExitGameDialog.show(context),
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify button types
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);

      // Verify Cancel is TextButton
      final cancelButtonFinder = find.ancestor(
        of: find.text('Cancel'),
        matching: find.byType(TextButton),
      );
      expect(cancelButtonFinder, findsOneWidget);

      // Verify Exit is FilledButton with error color
      final exitButtonFinder = find.ancestor(
        of: find.text('Exit'),
        matching: find.byType(FilledButton),
      );
      expect(exitButtonFinder, findsOneWidget);
    });

    testWidgets('returns true when Exit is pressed', (tester) async {
      late bool result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await ExitGameDialog.show(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Exit button
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed and result is true
      expect(find.byType(AlertDialog), findsNothing);
      expect(result, isTrue);
    });

    testWidgets('returns false when Cancel is pressed', (tester) async {
      late bool result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await ExitGameDialog.show(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed and result is false
      expect(find.byType(AlertDialog), findsNothing);
      expect(result, isFalse);
    });

    testWidgets('is not dismissible by tapping barrier', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => ExitGameDialog.show(context),
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to tap outside dialog (on barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog should still be visible (barrierDismissible: false)
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('warning icon uses error color from theme', (tester) async {
      const testErrorColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light().copyWith(
              error: testErrorColor,
            ),
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => ExitGameDialog.show(context),
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find the warning icon
      final iconWidget = tester.widget<Icon>(
        find.byIcon(Icons.warning_rounded),
      );

      // Verify icon color matches theme error color
      expect(iconWidget.color, testErrorColor);
    });

    testWidgets('returns false if dialog is somehow dismissed without action', (
      tester,
    ) async {
      late bool result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await ExitGameDialog.show(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Manually dismiss dialog via Navigator (simulates edge case)
      final context = tester.element(find.byType(AlertDialog));
      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      // Should default to false
      expect(result, isFalse);
    });
  });
}
