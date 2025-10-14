import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/core/theme/app_theme.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/presentation/widgets/mode_selection_button.dart';

void main() {
  group('ModeSelectionButton', () {
    testWidgets('should display vsAi mode content correctly', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Play vs AI'), findsOneWidget);
      expect(find.text('Challenge the AI'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    });

    testWidgets('should display twoPlayer mode content correctly', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.twoPlayer,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Two Player'), findsOneWidget);
      expect(find.text('Pass & Play on this device'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('should show last played indicator when isLastPlayed is true', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
              isLastPlayed: true,
            ),
          ),
        ),
      );

      expect(find.text('Last played'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets(
      'should not show last played indicator when isLastPlayed is false',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ModeSelectionButton(
                mode: GameMode.vsAi,
                onTap: () => tapped = true,
                isLastPlayed: false,
              ),
            ),
          ),
        );

        expect(find.text('Last played'), findsNothing);
        expect(find.byIcon(Icons.history), findsNothing);
      },
    );

    testWidgets('should call onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ModeSelectionButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('should have minimum height of 80dp', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = button.style!;
      final minimumSize = style.minimumSize!.resolve({});

      expect(minimumSize?.height, greaterThanOrEqualTo(80.0));
    });

    testWidgets('should display arrow icon', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('should have Semantics widget for accessibility', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
              isLastPlayed: false,
            ),
          ),
        ),
      );

      // Verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('should have Semantics widget when isLastPlayed is true', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
              isLastPlayed: true,
            ),
          ),
        ),
      );

      // Verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('should use primaryContainer color when isLastPlayed is true', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
              isLastPlayed: true,
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = button.style!;
      final backgroundColor = style.backgroundColor!.resolve({});
      final colorScheme = AppTheme.lightTheme.colorScheme;

      expect(backgroundColor, equals(colorScheme.primaryContainer));
    });

    testWidgets(
      'should use secondaryContainer color when isLastPlayed is false',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ModeSelectionButton(
                mode: GameMode.vsAi,
                onTap: () => tapped = true,
                isLastPlayed: false,
              ),
            ),
          ),
        );

        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        final style = button.style!;
        final backgroundColor = style.backgroundColor!.resolve({});
        final colorScheme = AppTheme.lightTheme.colorScheme;

        expect(backgroundColor, equals(colorScheme.secondaryContainer));
      },
    );

    testWidgets('should have border when isLastPlayed is true', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
              isLastPlayed: true,
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = button.style!;
      final shape = style.shape!.resolve({}) as RoundedRectangleBorder;
      final colorScheme = AppTheme.lightTheme.colorScheme;

      expect(shape.side.color, equals(colorScheme.primary));
      expect(shape.side.width, equals(2.0));
    });

    testWidgets('should not have border when isLastPlayed is false', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
              isLastPlayed: false,
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = button.style!;
      final shape = style.shape!.resolve({}) as RoundedRectangleBorder;

      expect(shape.side, equals(BorderSide.none));
    });

    testWidgets('should have proper padding', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = button.style!;
      final padding = style.padding!.resolve({});

      expect(
        padding,
        equals(
          const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
        ),
      );
    });

    testWidgets('should have rounded corners', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = button.style!;
      final shape = style.shape!.resolve({}) as RoundedRectangleBorder;

      expect(shape.borderRadius, equals(BorderRadius.circular(16)));
    });

    testWidgets('should display correct icon size', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Find the mode icon (smart_toy), not the arrow icon
      final modeIcon = tester.widget<Icon>(find.byIcon(Icons.smart_toy));

      expect(modeIcon.size, equals(32.0));
    });

    testWidgets('should work with both game modes', (tester) async {
      for (final mode in GameMode.values) {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ModeSelectionButton(mode: mode, onTap: () => tapped = true),
            ),
          ),
        );

        expect(find.text(mode.displayName), findsOneWidget);
        expect(find.text(mode.subtitle), findsOneWidget);

        await tester.tap(find.byType(ModeSelectionButton));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      }
    });

    testWidgets('should render correctly in dark theme', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ModeSelectionButton(
              mode: GameMode.vsAi,
              onTap: () => tapped = true,
              isLastPlayed: true,
            ),
          ),
        ),
      );

      expect(find.text('Play vs AI'), findsOneWidget);
      expect(find.text('Challenge the AI'), findsOneWidget);
      expect(find.text('Last played'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
