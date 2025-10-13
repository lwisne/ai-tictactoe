import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/board_position.dart';
import 'package:tic_tac_toe/models/game_state.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/services/ai_hard_service.dart';
import 'package:tic_tac_toe/services/game_service.dart';

void main() {
  group('AiHardService', () {
    late GameService gameService;
    late AiHardService aiService;

    setUp(() {
      gameService = GameService();
      aiService = AiHardService(gameService);
    });

    group('getMove', () {
      test('throws StateError when no moves available', () {
        final board = List<Player?>.filled(9, Player.x);
        final state = GameState(board: board, currentPlayer: Player.o);

        expect(() => aiService.getMove(state), throwsStateError);
      });

      test('returns a valid empty position', () {
        final state = GameState.initial();

        final move = aiService.getMove(state);

        expect(move.index, greaterThanOrEqualTo(0));
        expect(move.index, lessThan(9));
        expect(state.board[move.index], isNull);
      });

      test('takes winning move when available', () {
        // Board state: O has two in a row (positions 0, 1)
        // O O _
        // X X _
        // _ _ _
        final board = List<Player?>.filled(9, null);
        board[0] = Player.o;
        board[1] = Player.o;
        board[3] = Player.x;
        board[4] = Player.x;

        final state = GameState(board: board, currentPlayer: Player.o);
        final move = aiService.getMove(state);

        // Should take position 2 to win
        expect(move.index, 2);
      });

      test('blocks opponent winning move', () {
        // Board state: X has two in a row (positions 0, 1)
        // X X _
        // O _ _
        // _ _ _
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;
        board[1] = Player.x;
        board[3] = Player.o;

        final state = GameState(board: board, currentPlayer: Player.o);
        final move = aiService.getMove(state);

        // Should block at position 2
        expect(move.index, 2);
      });

      test('chooses optimal move on empty board', () {
        final state = GameState.initial();
        final move = aiService.getMove(state);

        // On empty board, optimal moves are center or corners
        const optimalMoves = [0, 2, 4, 6, 8];
        expect(optimalMoves.contains(move.index), isTrue);
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
        final move = aiService.getMove(state);

        expect(move.index, 8);
      });

      test('takes corner when center is taken', () {
        // Board: Center taken by opponent
        // _ _ _
        // _ X _
        // _ _ _
        final board = List<Player?>.filled(9, null);
        board[4] = Player.x;

        final state = GameState(board: board, currentPlayer: Player.o);
        final move = aiService.getMove(state);

        // Should take a corner (0, 2, 6, or 8)
        const corners = [0, 2, 6, 8];
        expect(corners.contains(move.index), isTrue);
      });

      test('detects winning diagonal opportunity', () {
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
        final move = aiService.getMove(state);

        // Should take position 8 to win on diagonal
        expect(move.index, 8);
      });

      test('blocks opponent diagonal win', () {
        // Board state: X threatens diagonal win
        // X _ _
        // _ X _
        // O O _
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;
        board[4] = Player.x;
        board[6] = Player.o;
        board[7] = Player.o;

        final state = GameState(board: board, currentPlayer: Player.o);
        final move = aiService.getMove(state);

        // Should block at position 8
        expect(move.index, 8);
      });

      test('forces draw when opponent plays optimally', () {
        // Start from center (optimal opening)
        var board = List<Player?>.filled(9, null);
        board[4] = Player.x; // X takes center

        // O responds optimally (corner)
        board[0] = Player.o;

        // X makes next move
        board[8] = Player.x; // Opposite corner

        // Now O must respond optimally
        final state = GameState(board: board, currentPlayer: Player.o);
        final move = aiService.getMove(state);

        // O should take center edge or corner to prevent X from winning
        // Valid defensive moves: 1, 2, 3, 5, 6, 7
        const validMoves = [1, 2, 3, 5, 6, 7];
        expect(validMoves.contains(move.index), isTrue);
      });

      test('performance: completes move in under 100ms', () {
        final state = GameState.initial();

        final stopwatch = Stopwatch()..start();
        aiService.getMove(state);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100),
            reason: 'AI move should complete in under 100ms');
      });

      test('performance: mid-game move completes quickly', () {
        // Board with several moves played
        final board = List<Player?>.filled(9, null);
        board[4] = Player.x;
        board[0] = Player.o;
        board[8] = Player.x;
        board[2] = Player.o;

        final state = GameState(board: board, currentPlayer: Player.x);

        final stopwatch = Stopwatch()..start();
        aiService.getMove(state);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100),
            reason: 'Mid-game move should complete in under 100ms');
      });

      test('prefers faster wins with depth bonus', () {
        // Setup: O can win in one move at position 2, or set up longer win
        // O O _
        // X _ _
        // X _ _
        final board = List<Player?>.filled(9, null);
        board[0] = Player.o;
        board[1] = Player.o;
        board[3] = Player.x;
        board[6] = Player.x;

        final state = GameState(board: board, currentPlayer: Player.o);
        final move = aiService.getMove(state);

        // Should take immediate win at position 2
        expect(move.index, 2);
      });

      test('handles complex mid-game position correctly', () {
        // Complex board position
        // X O X
        // O X _
        // _ _ O
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;
        board[1] = Player.o;
        board[2] = Player.x;
        board[3] = Player.o;
        board[4] = Player.x;
        board[8] = Player.o;

        final state = GameState(board: board, currentPlayer: Player.o);
        final move = aiService.getMove(state);

        // AI should find the optimal move
        expect([5, 6, 7].contains(move.index), isTrue);
      });
    });

    group('optimal play verification', () {
      test('never loses against perfect opponent', () {
        // Play multiple games where both players play optimally
        for (int startPos in [4, 0, 2, 6, 8]) {
          // Various starting positions
          var state = GameState.initial();

          // First move by X (starting position)
          state = gameService.makeMove(state, BoardPosition(startPos));

          // Play until game ends
          while (!state.isGameOver) {
            final move = aiService.getMove(state);
            state = gameService.makeMove(state, move);
          }

          final winner = gameService.getWinner(state);

          // AI (O) should never lose - either win or draw
          expect(winner, isNot(Player.x),
              reason: 'AI should never lose when playing optimally');
        }
      });

      test('AI vs AI always results in draw', () {
        // Two perfect AIs playing against each other should always draw
        var state = GameState.initial();
        final aiX = AiHardService(gameService);
        final aiO = AiHardService(gameService);

        while (!state.isGameOver) {
          final ai = state.currentPlayer == Player.x ? aiX : aiO;
          final move = ai.getMove(state);
          state = gameService.makeMove(state, move);
        }

        final winner = gameService.getWinner(state);

        // Should always be a draw
        expect(winner, isNull, reason: 'Two perfect AIs should always draw');
        expect(gameService.isDraw(state), isTrue);
      });

      test('AI wins when opponent makes mistake', () {
        // Setup a game where opponent made a mistake
        var state = GameState.initial();

        // X makes suboptimal edge move
        state = gameService.makeMove(state, BoardPosition(1));

        // AI responds
        var move = aiService.getMove(state);
        state = gameService.makeMove(state, move);

        // X makes another weak move
        state = gameService.makeMove(state, BoardPosition(3));

        // Continue playing optimally as O
        while (!state.isGameOver) {
          if (state.currentPlayer == Player.o) {
            move = aiService.getMove(state);
            state = gameService.makeMove(state, move);
          } else {
            // X plays randomly/poorly
            final empty = gameService.getEmptyPositions(state);
            state = gameService.makeMove(state, empty[0]);
          }
        }

        // AI should exploit mistakes and not lose
        final winner = gameService.getWinner(state);
        expect(winner, isNot(Player.x));
      });

      test('blocks all winning threats correctly', () {
        // Various positions where opponent has winning threat
        final testCases = [
          // Row threats
          {
            'board': [
              Player.x,
              Player.x,
              null,
              null,
              Player.o,
              null,
              null,
              null,
              null
            ],
            'expected': 2,
            'description': 'Block row 0 win'
          },
          // Column threats
          {
            'board': [
              Player.x,
              null,
              null,
              Player.x,
              Player.o,
              null,
              null,
              null,
              null
            ],
            'expected': 6,
            'description': 'Block column 0 win'
          },
          // Diagonal threats
          {
            'board': [
              Player.x,
              null,
              Player.o,
              null,
              Player.x,
              null,
              null,
              null,
              null
            ],
            'expected': 8,
            'description': 'Block diagonal win'
          },
        ];

        for (final testCase in testCases) {
          final board = testCase['board'] as List<Player?>;
          final expected = testCase['expected'] as int;
          final description = testCase['description'] as String;

          final state = GameState(board: board, currentPlayer: Player.o);
          final move = aiService.getMove(state);

          expect(move.index, expected, reason: description);
        }
      });
    });

    group('minimax algorithm verification', () {
      test('evaluates all game tree paths', () {
        // Start with mostly empty board - minimax should evaluate all paths
        final board = List<Player?>.filled(9, null);
        board[4] = Player.x; // Just center occupied

        final state = GameState(board: board, currentPlayer: Player.o);

        // Should complete quickly despite evaluating many paths (due to pruning)
        final stopwatch = Stopwatch()..start();
        final move = aiService.getMove(state);
        stopwatch.stop();

        expect(move, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('alpha-beta pruning reduces computation', () {
        // Even on empty board, should complete fast due to pruning
        final state = GameState.initial();

        final stopwatch = Stopwatch()..start();
        aiService.getMove(state);
        stopwatch.stop();

        // With pruning, should be very fast
        expect(stopwatch.elapsedMilliseconds, lessThan(50),
            reason: 'Alpha-beta pruning should make computation efficient');
      });
    });
  });
}
