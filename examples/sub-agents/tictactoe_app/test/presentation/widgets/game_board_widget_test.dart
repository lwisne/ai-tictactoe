import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/core/theme/app_theme.dart';
import 'package:tictactoe_app/presentation/widgets/game_board_widget.dart';
import 'package:tictactoe_app/presentation/widgets/game_cell_widget.dart';

void main() {
  group('GameBoardWidget', () {
    testWidgets('renders 3x3 grid with 9 cells', (tester) async {
      // Arrange
      final board = List.filled(9, '');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameBoardWidget(board: board, onCellTap: (_) {}),
          ),
        ),
      );

      // Assert
      expect(find.byType(GameCellWidget), findsNWidgets(9));
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('displays empty board correctly', (tester) async {
      // Arrange
      final board = List.filled(9, '');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameBoardWidget(board: board, onCellTap: (_) {}),
          ),
        ),
      );

      // Assert - all cells should be empty (show add icon)
      final addIcons = find.byIcon(Icons.add_circle_outline);
      expect(addIcons, findsNWidgets(9));
    });

    testWidgets('displays board with X and O symbols', (tester) async {
      // Arrange
      final board = ['X', 'O', '', 'X', '', 'O', '', '', 'X'];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameBoardWidget(board: board, onCellTap: (_) {}),
          ),
        ),
      );

      // Assert
      expect(find.text('X'), findsNWidgets(3));
      expect(find.text('O'), findsNWidgets(2));
      expect(find.byIcon(Icons.add_circle_outline), findsNWidgets(4));
    });

    testWidgets('calls onCellTap callback when empty cell is tapped', (
      tester,
    ) async {
      // Arrange
      final board = List.filled(9, '');
      int? tappedIndex;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameBoardWidget(
              board: board,
              onCellTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GameCellWidget).first);
      await tester.pump();

      // Assert
      expect(tappedIndex, equals(0));
    });

    testWidgets('does not call onCellTap when filled cell is tapped', (
      tester,
    ) async {
      // Arrange
      final board = ['X', '', '', '', '', '', '', '', ''];
      int? tappedIndex;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameBoardWidget(
              board: board,
              onCellTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('X'));
      await tester.pump();

      // Assert - should not update because cell is filled
      expect(tappedIndex, isNull);
    });

    testWidgets('disables all cells when isGameOver is true', (tester) async {
      // Arrange
      final board = ['X', 'O', 'X', '', '', '', '', '', ''];
      int? tappedIndex;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameBoardWidget(
              board: board,
              onCellTap: (index) => tappedIndex = index,
              isGameOver: true,
            ),
          ),
        ),
      );

      // Try to tap an empty cell
      final emptyCells = find.byWidgetPredicate(
        (widget) => widget is GameCellWidget && widget.value.isEmpty,
      );
      await tester.tap(emptyCells.first);
      await tester.pump();

      // Assert - callback should not be called
      expect(tappedIndex, isNull);
    });

    testWidgets('maintains square aspect ratio', (tester) async {
      // Arrange
      final board = List.filled(9, '');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameBoardWidget(board: board, onCellTap: (_) {}),
          ),
        ),
      );

      // Assert - find AspectRatio widget
      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, equals(1.0));
    });

    testWidgets('has correct semantic label for accessibility', (tester) async {
      // Arrange
      final board = List.filled(9, '');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameBoardWidget(board: board, onCellTap: (_) {}),
          ),
        ),
      );

      // Assert - check for Semantics widget with label
      expect(find.bySemanticsLabel('Tic-Tac-Toe game board'), findsOneWidget);
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      // Arrange
      final board = ['X', 'O', '', '', '', '', '', '', ''];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GameBoardWidget(board: board, onCellTap: (_) {}),
          ),
        ),
      );

      // Assert - should render without errors
      expect(find.byType(GameBoardWidget), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
      expect(find.text('O'), findsOneWidget);
    });

    testWidgets('board size adapts to available space with LayoutBuilder', (
      tester,
    ) async {
      // Arrange
      final board = List.filled(9, '');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: GameBoardWidget(board: board, onCellTap: (_) {}),
            ),
          ),
        ),
      );

      // Assert - LayoutBuilder should be used
      expect(find.byType(LayoutBuilder), findsOneWidget);
    });

    testWidgets('throws assertion error if board length is not 9', (
      tester,
    ) async {
      // Arrange & Assert
      expect(
        () => GameBoardWidget(
          board: ['X', 'O'], // Invalid: only 2 cells
          onCellTap: (_) {},
        ),
        throwsAssertionError,
      );
    });

    testWidgets('grid has correct spacing and cross axis count', (
      tester,
    ) async {
      // Arrange
      final board = List.filled(9, '');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameBoardWidget(board: board, onCellTap: (_) {}),
          ),
        ),
      );

      // Assert
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(3));
      expect(delegate.crossAxisSpacing, equals(2));
      expect(delegate.mainAxisSpacing, equals(2));
      expect(delegate.childAspectRatio, equals(1.0));
    });

    testWidgets('grid is not scrollable', (tester) async {
      // Arrange
      final board = List.filled(9, '');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GameBoardWidget(board: board, onCellTap: (_) {}),
          ),
        ),
      );

      // Assert
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.physics, isA<NeverScrollableScrollPhysics>());
    });
  });
}
