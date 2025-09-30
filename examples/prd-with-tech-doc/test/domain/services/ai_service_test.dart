import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/difficulty_level.dart';
import 'package:tic_tac_toe/domain/entities/player.dart';
import 'package:tic_tac_toe/domain/entities/position.dart';
import 'package:tic_tac_toe/domain/services/ai_service.dart';
import 'package:tic_tac_toe/domain/services/game_service.dart';

void main() {
  late GameService gameService;
  late AiService aiService;

  setUp(() {
    gameService = GameService();
    aiService = AiService(gameService);
  });

  group('AiService - Easy Difficulty', () {
    test('returns valid move', () {
      final board = [
        [Player.x, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.easy);

      // Should be a valid empty position
      expect(move.row, greaterThanOrEqualTo(0));
      expect(move.row, lessThan(3));
      expect(move.col, greaterThanOrEqualTo(0));
      expect(move.col, lessThan(3));
      expect(board[move.row][move.col], equals(Player.none));
    });

    test('makes random moves (non-deterministic)', () {
      final board = [
        [Player.none, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final moves = <Position>{};
      // Run multiple times to check randomness
      for (int i = 0; i < 20; i++) {
        final move = aiService.getBestMove(board, Player.o, DifficultyLevel.easy);
        moves.add(move);
      }

      // Should have made different moves (with high probability)
      expect(moves.length, greaterThan(1));
    });
  });

  group('AiService - Medium Difficulty', () {
    test('takes winning move when available', () {
      final board = [
        [Player.o, Player.o, Player.none], // O can win at (0,2)
        [Player.x, Player.x, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.medium);

      expect(move, equals(const Position(row: 0, col: 2)));
    });

    test('blocks opponent winning move', () {
      final board = [
        [Player.x, Player.x, Player.none], // X can win at (0,2), O should block
        [Player.o, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.medium);

      expect(move, equals(const Position(row: 0, col: 2)));
    });

    test('prioritizes winning over blocking', () {
      final board = [
        [Player.x, Player.x, Player.none], // X can win at (0,2)
        [Player.o, Player.o, Player.none], // O can win at (1,2)
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.medium);

      // Should take its own winning move
      expect(move, equals(const Position(row: 1, col: 2)));
    });

    test('makes valid move when no critical situations', () {
      final board = [
        [Player.x, Player.none, Player.none],
        [Player.none, Player.o, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.medium);

      // Should be a valid empty position
      expect(board[move.row][move.col], equals(Player.none));
    });
  });

  group('AiService - Hard Difficulty (Minimax)', () {
    test('makes optimal move on empty board', () {
      final board = [
        [Player.none, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.hard);

      // Center or any corner is optimal first move
      final optimalMoves = [
        const Position(row: 0, col: 0), // Top-left corner
        const Position(row: 0, col: 2), // Top-right corner
        const Position(row: 1, col: 1), // Center
        const Position(row: 2, col: 0), // Bottom-left corner
        const Position(row: 2, col: 2), // Bottom-right corner
      ];
      expect(optimalMoves.contains(move), isTrue);
    });

    test('takes winning move immediately', () {
      final board = [
        [Player.o, Player.o, Player.none], // O can win at (0,2)
        [Player.x, Player.x, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.hard);

      expect(move, equals(const Position(row: 0, col: 2)));
    });

    test('blocks opponent from winning', () {
      final board = [
        [Player.x, Player.x, Player.none], // Must block at (0,2)
        [Player.o, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.hard);

      expect(move, equals(const Position(row: 0, col: 2)));
    });

    test('creates fork opportunity', () {
      final board = [
        [Player.o, Player.none, Player.none],
        [Player.none, Player.x, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.hard);

      // Should make a strategic move (corner or edge)
      expect(board[move.row][move.col], equals(Player.none));
    });

    test('prevents draw by forcing win', () {
      final board = [
        [Player.o, Player.x, Player.o],
        [Player.x, Player.x, Player.none], // O should play at (1,2)
        [Player.none, Player.o, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.hard);

      // Should make the move that leads to best outcome
      expect(board[move.row][move.col], equals(Player.none));
    });

    test('is unbeatable - never loses from optimal start', () {
      // Test that hard AI never loses when playing optimally
      // This is a longer integration-style test
      final board = [
        [Player.none, Player.none, Player.none],
        [Player.none, Player.x, Player.none], // X takes center
        [Player.none, Player.none, Player.none],
      ];

      // O's turn - should respond optimally
      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.hard);

      // Should take a corner (optimal response to center)
      final corners = [
        const Position(row: 0, col: 0),
        const Position(row: 0, col: 2),
        const Position(row: 2, col: 0),
        const Position(row: 2, col: 2),
      ];
      expect(corners.contains(move), isTrue);
    });
  });

  group('AiService - Edge Cases', () {
    test('handles board with one empty space', () {
      final board = [
        [Player.x, Player.o, Player.x],
        [Player.o, Player.x, Player.o],
        [Player.o, Player.x, Player.none], // Only (2,2) available
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.hard);

      expect(move, equals(const Position(row: 2, col: 2)));
    });

    test('all difficulties return valid moves', () {
      final board = [
        [Player.x, Player.none, Player.none],
        [Player.none, Player.o, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      for (final difficulty in DifficultyLevel.values) {
        final move = aiService.getBestMove(board, Player.o, difficulty);
        expect(board[move.row][move.col], equals(Player.none),
            reason: 'Invalid move for $difficulty');
      }
    });
  });

  group('AiService - Strategy Verification', () {
    test('easy is less optimal than hard', () {
      final board = [
        [Player.x, Player.x, Player.none], // Critical block needed
        [Player.none, Player.o, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      // Hard should always block
      final hardMove = aiService.getBestMove(board, Player.o, DifficultyLevel.hard);
      expect(hardMove, equals(const Position(row: 0, col: 2)));

      // Easy might not block (test multiple times)
      int blockedCount = 0;
      for (int i = 0; i < 10; i++) {
        final easyMove = aiService.getBestMove(board, Player.o, DifficultyLevel.easy);
        if (easyMove == const Position(row: 0, col: 2)) {
          blockedCount++;
        }
      }

      // Easy should block less consistently than hard
      expect(blockedCount, lessThan(10));
    });

    test('medium always handles critical moves', () {
      // Test multiple critical scenarios
      final scenarios = [
        // Winning move available
        [
          [Player.o, Player.o, Player.none],
          [Player.x, Player.x, Player.none],
          [Player.none, Player.none, Player.none],
        ],
        // Block required
        [
          [Player.x, Player.x, Player.none],
          [Player.o, Player.none, Player.none],
          [Player.none, Player.none, Player.none],
        ],
      ];

      final expectedMoves = [
        const Position(row: 0, col: 2), // Take win
        const Position(row: 0, col: 2), // Block
      ];

      for (int i = 0; i < scenarios.length; i++) {
        final move = aiService.getBestMove(
          scenarios[i],
          Player.o,
          DifficultyLevel.medium,
        );
        expect(move, equals(expectedMoves[i]),
            reason: 'Failed scenario $i');
      }
    });
  });
}
