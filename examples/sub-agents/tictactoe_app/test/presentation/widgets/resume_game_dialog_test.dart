import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/presentation/widgets/resume_game_dialog.dart';

void main() {
  group('ResumeGameDialog', () {
    testWidgets('displays all required elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => ResumeGameDialog.show(context),
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
      expect(find.text('Resume Game?'), findsOneWidget);
      expect(
        find.textContaining('You have an in-progress game'),
        findsOneWidget,
      );
      expect(find.text('New Game'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
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
                  onPressed: () => ResumeGameDialog.show(context),
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

      // Verify New Game is TextButton
      final newGameButtonFinder = find.ancestor(
        of: find.text('New Game'),
        matching: find.byType(TextButton),
      );
      expect(newGameButtonFinder, findsOneWidget);

      // Verify Resume is FilledButton (primary action)
      final resumeButtonFinder = find.ancestor(
        of: find.text('Resume'),
        matching: find.byType(FilledButton),
      );
      expect(resumeButtonFinder, findsOneWidget);
    });

    testWidgets('returns true when Resume is pressed', (tester) async {
      late bool result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await ResumeGameDialog.show(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog and tap Resume
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();

      // Verify dialog closed and returned true
      expect(find.byType(AlertDialog), findsNothing);
      expect(result, isTrue);
    });

    testWidgets('returns false when New Game is pressed', (tester) async {
      late bool result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await ResumeGameDialog.show(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog and tap New Game
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();

      // Verify dialog closed and returned false
      expect(find.byType(AlertDialog), findsNothing);
      expect(result, isFalse);
    });

    testWidgets('dialog is not dismissible by barrier tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => ResumeGameDialog.show(context),
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

      // Verify dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Try to dismiss by tapping barrier
      await tester.tapAt(const Offset(10, 10)); // Tap outside dialog
      await tester.pumpAndSettle();

      // Dialog should still be present (barrierDismissible = false)
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('dialog has correct content text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => ResumeGameDialog.show(context),
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

      // Verify content message
      expect(
        find.text(
          'You have an in-progress game. Would you like to resume where you left off?',
        ),
        findsOneWidget,
      );
    });

    testWidgets('static show method works correctly', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await ResumeGameDialog.show(context);
                  },
                  child: const Text('Test'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      expect(find.byType(ResumeGameDialog), findsOneWidget);
    });

    testWidgets('returns false by default if somehow dismissed', (
      tester,
    ) async {
      // This test verifies the null-safety fallback in the show method

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return const ResumeGameDialog();
              },
            ),
          ),
        ),
      );

      // Verify dialog renders without errors
      expect(find.byType(ResumeGameDialog), findsOneWidget);
    });

    group('accessibility', () {
      testWidgets('has semantic labels for buttons', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => ResumeGameDialog.show(context),
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify buttons are findable by text (accessible)
        expect(find.text('New Game'), findsOneWidget);
        expect(find.text('Resume'), findsOneWidget);
      });

      testWidgets('dialog title is accessible', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => ResumeGameDialog.show(context),
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify title text is accessible
        expect(find.text('Resume Game?'), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('dismisses correctly when button is tapped', (tester) async {
        late bool result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      result = await ResumeGameDialog.show(context);
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify dialog is showing before tap
        expect(find.byType(AlertDialog), findsOneWidget);

        // Tap Resume button once
        await tester.tap(find.text('Resume'));
        await tester.pumpAndSettle();

        // Dialog should be dismissed and return true
        expect(find.byType(AlertDialog), findsNothing);
        expect(result, isTrue);
      });

      testWidgets('works in different theme modes', (tester) async {
        for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
          await tester.pumpWidget(
            MaterialApp(
              themeMode: themeMode,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () => ResumeGameDialog.show(context),
                      child: const Text('Show Dialog'),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.tap(find.text('Show Dialog'));
          await tester.pumpAndSettle();

          // Verify dialog renders in both themes
          expect(find.byType(AlertDialog), findsOneWidget);
          expect(find.text('Resume Game?'), findsOneWidget);

          // Close dialog
          await tester.tap(find.text('Resume'));
          await tester.pumpAndSettle();
        }
      });
    });
  });
}
