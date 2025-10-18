import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/core/theme/app_theme.dart';
import 'package:tictactoe_app/presentation/widgets/game_cell_widget.dart';

void main() {
  group('GameCellWidget', () {
    testWidgets('renders empty cell with add icon when tappable', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(value: '', index: 0, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.text('X'), findsNothing);
      expect(find.text('O'), findsNothing);
    });

    testWidgets('renders empty cell without icon when not tappable', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(
              value: '',
              index: 0,
              onTap: null, // Not tappable
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add_circle_outline), findsNothing);
    });

    testWidgets('renders X symbol correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(value: 'X', index: 0, onTap: null),
          ),
        ),
      );

      // Assert
      expect(find.text('X'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsNothing);

      // Check text style
      final textWidget = tester.widget<Text>(find.text('X'));
      expect(textWidget.style?.fontSize, equals(40));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('renders O symbol correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(value: 'O', index: 0, onTap: null),
          ),
        ),
      );

      // Assert
      expect(find.text('O'), findsOneWidget);

      // Check text style
      final textWidget = tester.widget<Text>(find.text('O'));
      expect(textWidget.style?.fontSize, equals(40));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('X uses primary color', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(value: 'X', index: 0, onTap: null),
          ),
        ),
      );

      // Assert
      final textWidget = tester.widget<Text>(find.text('X'));
      final theme = AppTheme.lightTheme;
      expect(textWidget.style?.color, equals(theme.colorScheme.primary));
    });

    testWidgets('O uses secondary color', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(value: 'O', index: 0, onTap: null),
          ),
        ),
      );

      // Assert
      final textWidget = tester.widget<Text>(find.text('O'));
      final theme = AppTheme.lightTheme;
      expect(textWidget.style?.color, equals(theme.colorScheme.secondary));
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      // Arrange
      bool wasTapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(
              value: '',
              index: 0,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GameCellWidget));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('does not call onTap when onTap is null', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(value: 'X', index: 0, onTap: null),
          ),
        ),
      );

      // Should not throw error when tapped
      await tester.tap(find.byType(GameCellWidget));
      await tester.pump();

      // Assert - just verify it doesn't crash
      expect(find.byType(GameCellWidget), findsOneWidget);
    });

    testWidgets('has correct semantic label for empty tappable cell', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(
              value: '',
              index: 0, // Row 1, Column 1
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final semantics = tester.getSemantics(find.byType(GameCellWidget));
      expect(semantics.label, equals('Row 1, Column 1, empty cell, tappable'));
    });

    testWidgets('has correct semantic label for X cell', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(
              value: 'X',
              index: 4, // Row 2, Column 2 (middle cell)
              onTap: null,
            ),
          ),
        ),
      );

      // Assert - check that semantic label contains the expected text
      final semantics = tester.getSemantics(find.byType(GameCellWidget));
      expect(semantics.label, contains('Row 2, Column 2, X'));
    });

    testWidgets('has correct semantic label for O cell', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(
              value: 'O',
              index: 8, // Row 3, Column 3 (bottom-right)
              onTap: null,
            ),
          ),
        ),
      );

      // Assert - check that semantic label contains the expected text
      final semantics = tester.getSemantics(find.byType(GameCellWidget));
      expect(semantics.label, contains('Row 3, Column 3, O'));
    });

    testWidgets('calculates correct row and column for all indices', (
      tester,
    ) async {
      // Test mapping of indices to positions
      final expectedPositions = [
        (0, 1, 1), // Index 0 -> Row 1, Column 1
        (1, 1, 2), // Index 1 -> Row 1, Column 2
        (2, 1, 3), // Index 2 -> Row 1, Column 3
        (3, 2, 1), // Index 3 -> Row 2, Column 1
        (4, 2, 2), // Index 4 -> Row 2, Column 2
        (5, 2, 3), // Index 5 -> Row 2, Column 3
        (6, 3, 1), // Index 6 -> Row 3, Column 1
        (7, 3, 2), // Index 7 -> Row 3, Column 2
        (8, 3, 3), // Index 8 -> Row 3, Column 3
      ];

      for (final (index, row, column) in expectedPositions) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: GameCellWidget(value: 'X', index: index, onTap: null),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(GameCellWidget));
        expect(semantics.label, contains('Row $row, Column $column, X'));
      }
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GameCellWidget(value: 'X', index: 0, onTap: null),
          ),
        ),
      );

      // Assert
      expect(find.text('X'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('X'));
      final theme = AppTheme.darkTheme;
      expect(textWidget.style?.color, equals(theme.colorScheme.primary));
    });

    testWidgets('has rounded corners', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(value: '', index: 0, onTap: () {}),
          ),
        ),
      );

      // Assert
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(GameCellWidget),
          matching: find.byType(Material),
        ),
      );
      expect(material.borderRadius, equals(BorderRadius.circular(8)));

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, equals(BorderRadius.circular(8)));
    });

    testWidgets('has border decoration', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(value: '', index: 0, onTap: () {}),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.borderRadius, equals(BorderRadius.circular(8)));
    });

    testWidgets('empty tappable cell has subtle background', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameCellWidget(value: '', index: 0, onTap: () {}),
          ),
        ),
      );

      // Assert
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(GameCellWidget),
          matching: find.byType(Material),
        ),
      );
      // Should have a color with opacity
      expect(material.color, isNotNull);
      expect(material.color!.opacity, lessThan(1.0));
    });
  });
}
