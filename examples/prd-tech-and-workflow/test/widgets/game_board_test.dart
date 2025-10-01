import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/board_position.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/widgets/game_board.dart';

void main() {
  group('GameBoard', () {
    late List<BoardPosition> tappedPositions;

    setUp(() {
      tappedPositions = [];
    });

    Widget createTestWidget({required List<Player?> board}) {
      return MaterialApp(
        home: Scaffold(
          body: GameBoard(
            board: board,
            onCellTapped: (position) => tappedPositions.add(position),
          ),
        ),
      );
    }

    testWidgets('renders 9 cells for empty board', (tester) async {
      await tester.pumpWidget(createTestWidget(
        board: List.filled(9, null),
      ));

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(InkWell), findsNWidgets(9));
    });

    testWidgets('displays X symbol in correct position', (tester) async {
      final board = List<Player?>.filled(9, null);
      board[0] = Player.x;

      await tester.pumpWidget(createTestWidget(board: board));

      expect(find.text('X'), findsOneWidget);
      expect(find.text('O'), findsNothing);
    });

    testWidgets('displays O symbol in correct position', (tester) async {
      final board = List<Player?>.filled(9, null);
      board[4] = Player.o;

      await tester.pumpWidget(createTestWidget(board: board));

      expect(find.text('O'), findsOneWidget);
      expect(find.text('X'), findsNothing);
    });

    testWidgets('displays multiple symbols correctly', (tester) async {
      final board = List<Player?>.filled(9, null);
      board[0] = Player.x;
      board[1] = Player.o;
      board[4] = Player.x;

      await tester.pumpWidget(createTestWidget(board: board));

      expect(find.text('X'), findsNWidgets(2));
      expect(find.text('O'), findsOneWidget);
    });

    testWidgets('calls onCellTapped when cell is tapped', (tester) async {
      await tester.pumpWidget(createTestWidget(
        board: List.filled(9, null),
      ));

      final cells = find.byType(InkWell);
      await tester.tap(cells.first);
      await tester.pump();

      expect(tappedPositions.length, 1);
      expect(tappedPositions.first.index, 0);
    });

    testWidgets('provides correct position when different cells are tapped',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        board: List.filled(9, null),
      ));

      final cells = find.byType(InkWell);

      // Tap first cell (index 0)
      await tester.tap(cells.at(0));
      await tester.pump();

      // Tap fifth cell (index 4)
      await tester.tap(cells.at(4));
      await tester.pump();

      // Tap last cell (index 8)
      await tester.tap(cells.at(8));
      await tester.pump();

      expect(tappedPositions.length, 3);
      expect(tappedPositions[0].index, 0);
      expect(tappedPositions[1].index, 4);
      expect(tappedPositions[2].index, 8);
    });

    testWidgets('can tap cell with existing symbol', (tester) async {
      final board = List<Player?>.filled(9, null);
      board[0] = Player.x;

      await tester.pumpWidget(createTestWidget(board: board));

      final cells = find.byType(InkWell);
      await tester.tap(cells.first);
      await tester.pump();

      expect(tappedPositions.length, 1);
      expect(tappedPositions.first.index, 0);
    });

    testWidgets('displays full board correctly', (tester) async {
      final board = [
        Player.x, Player.o, Player.x,
        Player.o, Player.x, Player.o,
        Player.x, Player.o, Player.x,
      ];

      await tester.pumpWidget(createTestWidget(board: board));

      expect(find.text('X'), findsNWidgets(5));
      expect(find.text('O'), findsNWidgets(4));
    });
  });
}
