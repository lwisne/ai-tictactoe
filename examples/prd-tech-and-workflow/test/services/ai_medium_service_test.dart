import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/board_position.dart';
import 'package:tic_tac_toe/models/game_state.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/services/ai_medium_service.dart';
import 'package:tic_tac_toe/services/game_service.dart';

void main() {
  group('AiMediumService', () {
    late GameService gameService;
    late AiMediumService aiService;

    setUp(() {
      gameService = GameService();
    });

    group('getMove', () {
      test('throws StateError when no moves available', () {
        final board = List<Player?>.filled(9, Player.x);
        final state = GameState(board: board, currentPlayer: Player.o);

        aiService = AiMediumService(gameService);

        expect(() => aiService.getMove(state), throwsStateError);
      });

      test('returns a valid empty position', () {
        final state = GameState.initial();
        aiService = AiMediumService(gameService);

        final move = aiService.getMove(state);

        expect(move.index, greaterThanOrEqualTo(0));
        expect(move.index, lessThan(9));
        expect(state.board[move.index], isNull);
      });

      test('takes winning move when available with high probability', () {
        // Board state: O has two in a row (positions 0, 1)
        // X _ _
        // X O _
        // _ O _
        final board = List<Player?>.filled(9, null);
        board[0] = Player.o;
        board[1] = Player.o;
        board[3] = Player.x;
        board[4] = Player.o;
        board[7] = Player.o;

        final state = GameState(board: board, currentPlayer: Player.o);

        // Use seed that makes AI always take strategic moves
        aiService = AiMediumService(
          gameService,
          random: Random(42), // Deterministic for testing
        );

        // Test multiple times to verify it finds the winning move
        int winningMoveCount = 0;
        for (int i = 0; i < 10; i++) {
          aiService = AiMediumService(
            gameService,
            random: Random(i),
          );
          final move = aiService.getMove(state);
          if (move.index == 2) {
            // Position 2 completes the row
            winningMoveCount++;
          }
        }

        // Should find winning move in most cases (at least 5 out of 10)
        expect(winningMoveCount, greaterThanOrEqualTo(5));
      });

      test('blocks opponent winning move with high probability', () {
        // Board state: X has two in a row (positions 0, 1)
        // X X _
        // O _ _
        // _ O _
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;
        board[1] = Player.x;
        board[3] = Player.o;
        board[7] = Player.o;

        final state = GameState(board: board, currentPlayer: Player.o);

        // Test multiple times to verify blocking behavior
        int blockingMoveCount = 0;
        for (int i = 0; i < 10; i++) {
          aiService = AiMediumService(
            gameService,
            random: Random(i),
          );
          final move = aiService.getMove(state);
          if (move.index == 2) {
            // Position 2 blocks X's win
            blockingMoveCount++;
          }
        }

        // Should block in most cases (at least 5 out of 10)
        expect(blockingMoveCount, greaterThanOrEqualTo(5));
      });

      test('prefers center on empty board occasionally', () {
        final state = GameState.initial();

        // Test with seeds that make strategic moves
        int centerMoveCount = 0;
        for (int i = 0; i < 20; i++) {
          aiService = AiMediumService(
            gameService,
            random: Random(i),
          );
          final move = aiService.getMove(state);
          if (move.index == 4) {
            centerMoveCount++;
          }
        }

        // Should prefer center sometimes (at least 3 out of 20)
        expect(centerMoveCount, greaterThanOrEqualTo(3));
      });

      test('prefers corners when center is taken occasionally', () {
        // Board state: Center taken by opponent
        final board = List<Player?>.filled(9, null);
        board[4] = Player.x;

        final state = GameState(board: board, currentPlayer: Player.o);

        // Test multiple times
        int cornerMoveCount = 0;
        const corners = [0, 2, 6, 8];

        for (int i = 0; i < 20; i++) {
          aiService = AiMediumService(
            gameService,
            random: Random(i),
          );
          final move = aiService.getMove(state);
          if (corners.contains(move.index)) {
            cornerMoveCount++;
          }
        }

        // Should prefer corners sometimes (at least 5 out of 20)
        expect(cornerMoveCount, greaterThanOrEqualTo(5));
      });

      test('makes random moves sometimes to simulate mistakes', () {
        // Board with winning and blocking opportunities
        // O X _
        // X O _
        // _ _ _
        final board = List<Player?>.filled(9, null);
        board[0] = Player.o;
        board[1] = Player.x;
        board[3] = Player.x;
        board[4] = Player.o;

        final state = GameState(board: board, currentPlayer: Player.o);

        // Test multiple times
        final moveDistribution = <int, int>{};
        for (int i = 0; i < 30; i++) {
          aiService = AiMediumService(
            gameService,
            random: Random(i),
          );
          final move = aiService.getMove(state);
          moveDistribution[move.index] = (moveDistribution[move.index] ?? 0) + 1;
        }

        // Should have some variety in moves (not always the same move)
        expect(moveDistribution.length, greaterThan(1),
            reason: 'AI should make varied moves, not always the same');
      });

      test('completes game without errors', () {
        var state = GameState.initial();
        aiService = AiMediumService(gameService);

        // Play a complete game
        while (!state.isGameOver) {
          final move = aiService.getMove(state);
          expect(gameService.isValidMove(state, move), isTrue);
          state = gameService.makeMove(state, move);
        }

        // Game should end in win or draw
        expect(state.isGameOver, isTrue);
      });

      test('performance: completes move in under 100ms', () {
        final state = GameState.initial();
        aiService = AiMediumService(gameService);

        final stopwatch = Stopwatch()..start();
        aiService.getMove(state);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100),
            reason: 'AI move should complete in under 100ms');
      });

      test('handles board with one empty position', () {
        // Full board except position 8
        final board = [
          Player.x,
          Player.o,
          Player.x,
          Player.o,
          Player.x,
          Player.o,
          Player.x,
          Player.o,
          null,
        ];

        final state = GameState(board: board, currentPlayer: Player.o);
        aiService = AiMediumService(gameService);

        final move = aiService.getMove(state);

        expect(move.index, 8);
      });

      test('detects diagonal winning opportunity', () {
        // Board state: O can win on diagonal
        // O _ _
        // _ O _
        // X X _
        final board = List<Player?>.filled(9, null);
        board[0] = Player.o;
        board[4] = Player.o;
        board[6] = Player.x;
        board[7] = Player.x;

        final state = GameState(board: board, currentPlayer: Player.o);

        // Test multiple times
        int diagonalWinCount = 0;
        for (int i = 0; i < 10; i++) {
          aiService = AiMediumService(
            gameService,
            random: Random(i),
          );
          final move = aiService.getMove(state);
          if (move.index == 8) {
            // Position 8 completes the diagonal
            diagonalWinCount++;
          }
        }

        // Should find diagonal win most of the time
        expect(diagonalWinCount, greaterThanOrEqualTo(5));
      });

    });

    group('strategy behavior', () {
      test('is more strategic than random AI', () {
        // Play multiple games and verify Medium AI performs better than random
        int mediumWins = 0;
        final randomGen = Random(123);

        for (int game = 0; game < 10; game++) {
          var state = GameState.initial();
          aiService = AiMediumService(gameService, random: Random(game));

          while (!state.isGameOver) {
            BoardPosition move;

            if (state.currentPlayer == Player.x) {
              // Medium AI playing as X
              move = aiService.getMove(state);
            } else {
              // Random player as O
              final empty = gameService.getEmptyPositions(state);
              move = empty[randomGen.nextInt(empty.length)];
            }

            state = gameService.makeMove(state, move);
          }

          final winner = gameService.getWinner(state);
          if (winner == Player.x) {
            mediumWins++;
          }
        }

        // Medium AI should win or draw most games against random
        expect(mediumWins, greaterThanOrEqualTo(6),
            reason: 'Medium AI should win most games against random player');
      });

      test('balances strategy with mistakes', () {
        // Verify that AI doesn't always make the perfect move
        // Setup: Multiple scenarios where optimal move exists
        final scenarios = [
          // Scenario 1: Win vs Block decision
          [Player.o, Player.o, null, Player.x, Player.x, null, null, null, null],
          // Scenario 2: Strategic position choice
          [Player.x, null, null, null, Player.o, null, null, null, null],
          // Scenario 3: Multiple good moves
          [null, Player.x, null, null, Player.o, null, null, null, null],
        ];

        for (final scenario in scenarios) {
          final moveVariety = <int>{};

          for (int i = 0; i < 20; i++) {
            final state = GameState(
              board: scenario,
              currentPlayer: Player.o,
            );
            aiService = AiMediumService(gameService, random: Random(i));
            final move = aiService.getMove(state);
            moveVariety.add(move.index);
          }

          // Should show some variety (not always the same move)
          expect(moveVariety.length, greaterThan(1),
              reason: 'AI should show some variety in decision-making');
        }
      });
    });
  });
}
