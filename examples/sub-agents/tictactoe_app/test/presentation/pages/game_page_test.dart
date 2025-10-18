import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/core/theme/app_theme.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/presentation/cubits/game_ui_cubit.dart';
import 'package:tictactoe_app/presentation/pages/game_page.dart';
import 'package:tictactoe_app/presentation/widgets/exit_game_dialog.dart';
import 'package:tictactoe_app/presentation/widgets/game_board_widget.dart';
import '../../helpers/test_helpers.dart';

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(GameMode.vsAi);
  });

  group('GamePage', () {
    late GoRouter router;

    setUp(() async {
      await setupTestDI();

      router = GoRouter(
        initialLocation: '/game',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Home'))),
          ),
          GoRoute(path: '/game', builder: (context, state) => const GamePage()),
        ],
      );
    });

    tearDown(() async {
      await teardownTestDI();
    });

    testWidgets('renders game board', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert
      expect(find.byType(GameBoardWidget), findsOneWidget);
    });

    testWidgets('displays current player indicator', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert
      expect(find.text('Current Player: X'), findsOneWidget);
    });

    testWidgets('displays reset button', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert
      expect(find.text('Reset Game'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays title in app bar', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert
      expect(find.widgetWithText(AppBar, 'Game'), findsOneWidget);
    });

    testWidgets('has back button in app bar', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.arrow_back),
        ),
        findsOneWidget,
      );
    });

    testWidgets('player alternates between X and O on cell tap', (
      tester,
    ) async {
      // Arrange
      final mockCubit = getTestGameUICubit();
      final stateController = StreamController<GameUIState>.broadcast();
      var currentState = const GameUIState.initial();

      when(() => mockCubit.state).thenAnswer((_) => currentState);
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
      when(() => mockCubit.handleCellTap(any())).thenAnswer((_) {
        if (currentState.board[0].isEmpty) {
          currentState = currentState.copyWith(
            board: ['X', '', '', '', '', '', '', '', ''],
            currentPlayer: 'O',
          );
        } else if (currentState.board[1].isEmpty) {
          currentState = currentState.copyWith(
            board: ['X', 'O', '', '', '', '', '', '', ''],
            currentPlayer: 'X',
          );
        }
        when(() => mockCubit.state).thenReturn(currentState);
        stateController.add(currentState);
      });

      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert - initially X
      expect(find.text('Current Player: X'), findsOneWidget);

      // Tap first cell
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();

      // Assert - should switch to O
      expect(find.text('Current Player: O'), findsOneWidget);

      // Tap another cell
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();

      // Assert - should switch back to X
      expect(find.text('Current Player: X'), findsOneWidget);

      await stateController.close();
    });

    testWidgets('places X on first tap', (tester) async {
      // Arrange
      final mockCubit = getTestGameUICubit();
      final stateController = StreamController<GameUIState>.broadcast();
      var currentState = const GameUIState.initial();

      when(() => mockCubit.state).thenAnswer((_) => currentState);
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
      when(() => mockCubit.handleCellTap(any())).thenAnswer((_) {
        currentState = currentState.copyWith(
          board: ['X', '', '', '', '', '', '', '', ''],
          currentPlayer: 'O',
        );
        when(() => mockCubit.state).thenReturn(currentState);
        stateController.add(currentState);
      });

      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('X'), findsOneWidget);

      await stateController.close();
    });

    testWidgets('places O on second tap', (tester) async {
      // Arrange
      final mockCubit = getTestGameUICubit();
      final stateController = StreamController<GameUIState>.broadcast();
      var currentState = const GameUIState.initial();

      when(() => mockCubit.state).thenAnswer((_) => currentState);
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
      when(() => mockCubit.handleCellTap(any())).thenAnswer((_) {
        if (currentState.board[0].isEmpty) {
          currentState = currentState.copyWith(
            board: ['X', '', '', '', '', '', '', '', ''],
            currentPlayer: 'O',
          );
        } else if (currentState.board[1].isEmpty) {
          currentState = currentState.copyWith(
            board: ['X', 'O', '', '', '', '', '', '', ''],
            currentPlayer: 'X',
          );
        }
        when(() => mockCubit.state).thenReturn(currentState);
        stateController.add(currentState);
      });

      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Tap first cell (X)
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();

      // Tap second cell (O)
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('X'), findsOneWidget);
      expect(find.text('O'), findsOneWidget);

      await stateController.close();
    });

    testWidgets('reset button clears the board', (tester) async {
      // Arrange
      final mockCubit = getTestGameUICubit();
      final stateController = StreamController<GameUIState>.broadcast();
      var currentState = const GameUIState.initial().copyWith(
        board: ['X', 'O', 'X', '', '', '', '', '', ''],
        currentPlayer: 'O',
      );

      when(() => mockCubit.state).thenAnswer((_) => currentState);
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
      when(() => mockCubit.resetGame()).thenAnswer((_) {
        currentState = const GameUIState.initial();
        when(() => mockCubit.state).thenReturn(currentState);
        stateController.add(currentState);
      });

      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert board has X and O
      expect(find.text('X'), findsWidgets);
      expect(find.text('O'), findsWidgets);

      // Tap reset button using icon finder
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Assert board is cleared
      expect(find.text('X'), findsNothing);
      expect(find.text('O'), findsNothing);
      expect(find.byIcon(Icons.add_circle_outline), findsNWidgets(9));

      // Verify resetGame was called
      verify(() => mockCubit.resetGame()).called(1);

      await stateController.close();
    });

    testWidgets('reset button resets current player to X', (tester) async {
      // Arrange
      final mockCubit = getTestGameUICubit();
      final stateController = StreamController<GameUIState>.broadcast();
      var currentState = const GameUIState.initial().copyWith(
        board: ['X', '', '', '', '', '', '', '', ''],
        currentPlayer: 'O',
      );

      when(() => mockCubit.state).thenAnswer((_) => currentState);
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
      when(() => mockCubit.resetGame()).thenAnswer((_) {
        currentState = const GameUIState.initial();
        when(() => mockCubit.state).thenReturn(currentState);
        stateController.add(currentState);
      });

      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      expect(find.text('Current Player: O'), findsOneWidget);

      // Tap reset button using icon finder
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Assert current player is back to X
      expect(find.text('Current Player: X'), findsOneWidget);

      await stateController.close();
    });

    testWidgets('turn indicator shows correct color for X', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert
      final textWidget = tester.widget<Text>(find.text('Current Player: X'));
      final theme = AppTheme.lightTheme;
      expect(textWidget.style?.color, equals(theme.colorScheme.primary));
    });

    testWidgets('turn indicator shows correct color for O', (tester) async {
      // Arrange
      final mockCubit = getTestGameUICubit();
      final stateWithO = const GameUIState.initial().copyWith(
        board: ['X', '', '', '', '', '', '', '', ''],
        currentPlayer: 'O',
      );

      when(() => mockCubit.state).thenReturn(stateWithO);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(stateWithO));

      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert
      final textWidget = tester.widget<Text>(find.text('Current Player: O'));
      final theme = AppTheme.lightTheme;
      expect(textWidget.style?.color, equals(theme.colorScheme.secondary));
    });

    testWidgets('turn indicator has semantic label', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert
      final textWidget = tester.widget<Text>(find.text('Current Player: X'));
      expect(textWidget.semanticsLabel, equals('Current player is X'));
    });

    testWidgets('cannot tap already filled cell', (tester) async {
      // Arrange
      final mockCubit = getTestGameUICubit();
      final stateController = StreamController<GameUIState>.broadcast();
      final stateWithX = const GameUIState.initial().copyWith(
        board: ['X', '', '', '', '', '', '', '', ''],
        currentPlayer: 'O',
      );

      when(() => mockCubit.state).thenReturn(stateWithX);
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);

      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      expect(find.text('X'), findsOneWidget);
      expect(find.text('Current Player: O'), findsOneWidget);

      // Try to tap the same cell again - state should not change
      await tester.tap(find.text('X'));
      await tester.pumpAndSettle();

      // Assert - still only one X, player still O (no state change because cell is filled)
      expect(find.text('X'), findsOneWidget);
      expect(find.text('Current Player: O'), findsOneWidget);

      await stateController.close();
    });

    testWidgets('back button shows exit confirmation dialog', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Act - tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert - dialog should be shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Exit Game?'), findsOneWidget);
    });

    testWidgets('exit dialog Exit button navigates to home route', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Act - tap back button to show dialog
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Act - tap Exit button
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      // Assert - dialog is dismissed and navigation occurred to home
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(GamePage), findsNothing);
    });

    testWidgets('exit dialog Cancel button stays on game page', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Act - tap back button to show dialog
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Act - tap Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - dialog is dismissed and still on game page
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(GamePage), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('renders in dark theme', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
      );

      // Assert - should render without errors
      expect(find.byType(GamePage), findsOneWidget);
      expect(find.byType(GameBoardWidget), findsOneWidget);
    });

    testWidgets('uses SafeArea for proper spacing', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert - find SafeArea within Scaffold body
      expect(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(SafeArea),
        ),
        findsWidgets,
      );
    });

    testWidgets('has proper padding around content', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert - find padding widget that contains the game board
      final paddingWidgets = tester.widgetList<Padding>(
        find.descendant(
          of: find.byType(GamePage),
          matching: find.byType(Padding),
        ),
      );

      // Find the padding that wraps the main content
      final contentPadding = paddingWidgets.firstWhere(
        (p) => p.padding == const EdgeInsets.all(16.0),
        orElse: () => throw Exception('Expected padding not found'),
      );
      expect(contentPadding.padding, equals(const EdgeInsets.all(16.0)));
    });

    testWidgets('game board is in Expanded widget for responsive layout', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Assert
      expect(
        find.descendant(
          of: find.byType(Expanded),
          matching: find.byType(GameBoardWidget),
        ),
        findsOneWidget,
      );
    });

    testWidgets('calls handleCellTap on cubit when cell is tapped', (
      tester,
    ) async {
      // Arrange
      final mockCubit = getTestGameUICubit();

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Act - tap first empty cell
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pump();

      // Assert - verify cubit method was called
      verify(() => mockCubit.handleCellTap(any())).called(1);
    });

    testWidgets('calls resetGame on cubit when reset button is tapped', (
      tester,
    ) async {
      // Arrange
      final mockCubit = getTestGameUICubit();

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );

      // Act - tap reset button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Assert - verify cubit method was called
      verify(() => mockCubit.resetGame()).called(1);
    });
  });
}
