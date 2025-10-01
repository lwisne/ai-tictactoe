import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/game_state.dart';
import 'package:tic_tac_toe/models/player.dart';

void main() {
  group('GameState', () {
    group('initial factory', () {
      test('creates empty board', () {
        final state = GameState.initial();
        expect(state.board.length, 9);
        expect(state.board.every((cell) => cell == null), isTrue);
      });

      test('sets current player to X', () {
        final state = GameState.initial();
        expect(state.currentPlayer, Player.x);
      });

      test('sets isGameOver to false', () {
        final state = GameState.initial();
        expect(state.isGameOver, isFalse);
      });
    });

    group('copyWith', () {
      test('copies with updated board', () {
        final state = GameState.initial();
        final newBoard = List<Player?>.from(state.board);
        newBoard[0] = Player.x;

        final newState = state.copyWith(board: newBoard);

        expect(newState.board[0], Player.x);
        expect(newState.currentPlayer, state.currentPlayer);
        expect(newState.isGameOver, state.isGameOver);
      });

      test('copies with updated current player', () {
        final state = GameState.initial();
        final newState = state.copyWith(currentPlayer: Player.o);

        expect(newState.currentPlayer, Player.o);
        expect(newState.board, state.board);
        expect(newState.isGameOver, state.isGameOver);
      });

      test('copies with updated isGameOver', () {
        final state = GameState.initial();
        final newState = state.copyWith(isGameOver: true);

        expect(newState.isGameOver, isTrue);
        expect(newState.board, state.board);
        expect(newState.currentPlayer, state.currentPlayer);
      });

      test('copies without changes when no parameters provided', () {
        final state = GameState.initial();
        final newState = state.copyWith();

        expect(newState.currentPlayer, state.currentPlayer);
        expect(newState.isGameOver, state.isGameOver);
        // Board should be a new list but with same values
        expect(newState.board, state.board);
        expect(newState.board, isNot(same(state.board)));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes empty state correctly', () {
        final state = GameState.initial();
        final json = state.toJson();

        expect(json['board'], List.filled(9, null));
        expect(json['currentPlayer'], 'x');
        expect(json['isGameOver'], false);
      });

      test('toJson serializes state with moves correctly', () {
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;
        board[4] = Player.o;

        final state = GameState(
          board: board,
          currentPlayer: Player.x,
          isGameOver: false,
        );

        final json = state.toJson();
        expect(json['board'][0], 'x');
        expect(json['board'][4], 'o');
        expect(json['currentPlayer'], 'x');
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'board': [
            'x', null, null,
            null, 'o', null,
            null, null, null,
          ],
          'currentPlayer': 'x',
          'isGameOver': false,
        };

        final state = GameState.fromJson(json);

        expect(state.board[0], Player.x);
        expect(state.board[4], Player.o);
        expect(state.currentPlayer, Player.x);
        expect(state.isGameOver, isFalse);
      });

      test('round trip serialization works', () {
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;
        board[4] = Player.o;

        final original = GameState(
          board: board,
          currentPlayer: Player.o,
          isGameOver: true,
        );

        final json = original.toJson();
        final restored = GameState.fromJson(json);

        expect(restored.board, original.board);
        expect(restored.currentPlayer, original.currentPlayer);
        expect(restored.isGameOver, original.isGameOver);
      });
    });

    group('equality', () {
      test('identical states are equal', () {
        final state1 = GameState.initial();
        final state2 = GameState.initial();

        expect(state1, state2);
      });

      test('states with different boards are not equal', () {
        final state1 = GameState.initial();
        final board = List<Player?>.filled(9, null);
        board[0] = Player.x;
        final state2 = GameState(
          board: board,
          currentPlayer: Player.x,
        );

        expect(state1, isNot(state2));
      });

      test('states with different current player are not equal', () {
        final state1 = GameState.initial();
        final state2 = state1.copyWith(currentPlayer: Player.o);

        expect(state1, isNot(state2));
      });
    });
  });
}
