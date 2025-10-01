import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/player.dart';

void main() {
  group('Player', () {
    group('opponent', () {
      test('returns O when player is X', () {
        expect(Player.x.opponent, Player.o);
      });

      test('returns X when player is O', () {
        expect(Player.o.opponent, Player.x);
      });
    });

    group('symbol', () {
      test('returns X for Player.x', () {
        expect(Player.x.symbol, 'X');
      });

      test('returns O for Player.o', () {
        expect(Player.o.symbol, 'O');
      });
    });

    group('JSON serialization', () {
      test('toJson returns correct string for X', () {
        expect(Player.x.toJson(), 'x');
      });

      test('toJson returns correct string for O', () {
        expect(Player.o.toJson(), 'o');
      });

      test('fromJson correctly parses X', () {
        expect(Player.fromJson('x'), Player.x);
      });

      test('fromJson correctly parses O', () {
        expect(Player.fromJson('o'), Player.o);
      });

      test('round trip serialization works', () {
        expect(Player.fromJson(Player.x.toJson()), Player.x);
        expect(Player.fromJson(Player.o.toJson()), Player.o);
      });
    });
  });
}
