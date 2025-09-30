import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/models/game_config.dart';
import 'package:tic_tac_toe/domain/models/game_mode.dart';
import 'package:tic_tac_toe/domain/models/game_state.dart' as domain;
import 'package:tic_tac_toe/domain/models/player.dart';
import 'package:tic_tac_toe/domain/models/position.dart';
import 'package:tic_tac_toe/presentation/widgets/board_cell.dart';
import 'package:tic_tac_toe/presentation/widgets/game_board.dart';

import '../../helpers/builders.dart';

void main() {
  Widget createTestWidget(domain.GameState gameState, {Function(Position)? onCellTap}) {
    return MaterialApp(
      home: Scaffold(
        body: GameBoard(
          gameState: gameState,
          onCellTap: onCellTap ?? (_) {},
        ),
      ),
    );
  }

  group('GameBoard Widget', () {
    testWidgets('should display 9 cells for tic-tac-toe board', (tester) async {
      // Arrange
      final gameState = TestDataBuilder.createGameState();

      // Act
      await tester.pumpWidget(createTestWidget(gameState));

      // Assert
      final cells = find.byType(BoardCell);
      expect(cells, findsNWidgets(9));
    });

    testWidgets('should display empty cells initially', (tester) async {
      // Arrange
      final gameState = TestDataBuilder.createGameState();

      // Act
      await tester.pumpWidget(createTestWidget(gameState));

      // Assert
      // All cells should show none (empty)
      for (int i = 0; i < 9; i++) {
        final cell = tester.widget<BoardCell>(find.byType(BoardCell).at(i));
        expect(cell.player, equals(Player.none));
      }
    });

    testWidgets('should display X and O symbols correctly', (tester) async {
      // Arrange
      final gameState = TestDataBuilder.createGameState(
        board: [
          [Player.x, Player.o, Player.none],
          [Player.none, Player.x, Player.none],
          [Player.o, Player.none, Player.none],
        ],
      );

      // Act
      await tester.pumpWidget(createTestWidget(gameState));
      await tester.pumpAndSettle();

      // Assert
      final cell0 = tester.widget<BoardCell>(find.byType(BoardCell).at(0));
      expect(cell0.player, equals(Player.x));

      final cell1 = tester.widget<BoardCell>(find.byType(BoardCell).at(1));
      expect(cell1.player, equals(Player.o));

      final cell4 = tester.widget<BoardCell>(find.byType(BoardCell).at(4));
      expect(cell4.player, equals(Player.x));
    });

    testWidgets('should call onCellTap when cell is tapped', (tester) async {
      // Arrange
      final gameState = TestDataBuilder.createGameState();
      Position? tappedPosition;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          gameState,
          onCellTap: (position) {
            tappedPosition = position;
          },
        ),
      );

      // Tap the center cell (row 1, col 1)
      await tester.tap(find.byType(BoardCell).at(4));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedPosition, isNotNull);
      expect(tappedPosition, equals(const Position(row: 1, col: 1)));
    });

    testWidgets('should call onCellTap with correct position for each cell', (tester) async {
      // Arrange
      final gameState = TestDataBuilder.createGameState();
      final tappedPositions = <Position>[];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          gameState,
          onCellTap: (position) {
            tappedPositions.add(position);
          },
        ),
      );

      // Tap top-left cell (0,0)
      await tester.tap(find.byType(BoardCell).at(0));
      await tester.pumpAndSettle();

      // Tap top-right cell (0,2)
      await tester.tap(find.byType(BoardCell).at(2));
      await tester.pumpAndSettle();

      // Tap bottom-left cell (2,0)
      await tester.tap(find.byType(BoardCell).at(6));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedPositions.length, equals(3));
      expect(tappedPositions[0], equals(const Position(row: 0, col: 0)));
      expect(tappedPositions[1], equals(const Position(row: 0, col: 2)));
      expect(tappedPositions[2], equals(const Position(row: 2, col: 0)));
    });

    testWidgets('should highlight winning line', (tester) async {
      // Arrange
      final winningBoard = TestDataBuilder.createWinningBoard(
        winner: Player.x,
        type: 'horizontal',
      );
      final gameState = TestDataBuilder.createGameState(
        board: winningBoard,
        winningLine: const [
          Position(row: 0, col: 0),
          Position(row: 0, col: 1),
          Position(row: 0, col: 2),
        ],
      );

      // Act
      await tester.pumpWidget(createTestWidget(gameState));
      await tester.pumpAndSettle();

      // Assert - check that winning cells are highlighted
      final cell0 = tester.widget<BoardCell>(find.byType(BoardCell).at(0));
      final cell1 = tester.widget<BoardCell>(find.byType(BoardCell).at(1));
      final cell2 = tester.widget<BoardCell>(find.byType(BoardCell).at(2));
      final cell3 = tester.widget<BoardCell>(find.byType(BoardCell).at(3));

      expect(cell0.isWinningCell, isTrue);
      expect(cell1.isWinningCell, isTrue);
      expect(cell2.isWinningCell, isTrue);
      expect(cell3.isWinningCell, isFalse);
    });

    testWidgets('should render board with correct layout', (tester) async {
      // Arrange
      final gameState = TestDataBuilder.createGameState();

      // Act
      await tester.pumpWidget(createTestWidget(gameState));

      // Assert - Board should have a GridView
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should handle partially filled board', (tester) async {
      // Arrange
      final gameState = TestDataBuilder.createGameState(
        board: [
          [Player.x, Player.o, Player.x],
          [Player.o, Player.x, Player.none],
          [Player.none, Player.none, Player.none],
        ],
      );

      // Act
      await tester.pumpWidget(createTestWidget(gameState));
      await tester.pumpAndSettle();

      // Assert
      final cells = find.byType(BoardCell);
      expect(cells, findsNWidgets(9));

      // Check specific cells
      final cell0 = tester.widget<BoardCell>(cells.at(0));
      expect(cell0.player, equals(Player.x));

      final cell5 = tester.widget<BoardCell>(cells.at(5));
      expect(cell5.player, equals(Player.none));

      final cell8 = tester.widget<BoardCell>(cells.at(8));
      expect(cell8.player, equals(Player.none));
    });
  });
}
