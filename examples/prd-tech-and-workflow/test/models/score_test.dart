import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/score.dart';

void main() {
  group('Score', () {
    group('initial', () {
      test('creates score with all zeros', () {
        final score = Score.initial();

        expect(score.xWins, 0);
        expect(score.oWins, 0);
        expect(score.draws, 0);
      });
    });

    group('totalGames', () {
      test('returns sum of all games', () {
        const score = Score(xWins: 3, oWins: 2, draws: 1);

        expect(score.totalGames, 6);
      });

      test('returns 0 for initial score', () {
        final score = Score.initial();

        expect(score.totalGames, 0);
      });
    });

    group('copyWith', () {
      test('copies with updated xWins', () {
        const original = Score(xWins: 1, oWins: 2, draws: 3);
        final updated = original.copyWith(xWins: 5);

        expect(updated.xWins, 5);
        expect(updated.oWins, 2);
        expect(updated.draws, 3);
      });

      test('copies with updated oWins', () {
        const original = Score(xWins: 1, oWins: 2, draws: 3);
        final updated = original.copyWith(oWins: 7);

        expect(updated.xWins, 1);
        expect(updated.oWins, 7);
        expect(updated.draws, 3);
      });

      test('copies with updated draws', () {
        const original = Score(xWins: 1, oWins: 2, draws: 3);
        final updated = original.copyWith(draws: 9);

        expect(updated.xWins, 1);
        expect(updated.oWins, 2);
        expect(updated.draws, 9);
      });

      test('copies without changes when no parameters provided', () {
        const original = Score(xWins: 1, oWins: 2, draws: 3);
        final updated = original.copyWith();

        expect(updated.xWins, 1);
        expect(updated.oWins, 2);
        expect(updated.draws, 3);
      });
    });

    group('JSON serialization', () {
      test('toJson serializes correctly', () {
        const score = Score(xWins: 3, oWins: 5, draws: 2);
        final json = score.toJson();

        expect(json, {
          'xWins': 3,
          'oWins': 5,
          'draws': 2,
        });
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'xWins': 7,
          'oWins': 4,
          'draws': 1,
        };
        final score = Score.fromJson(json);

        expect(score.xWins, 7);
        expect(score.oWins, 4);
        expect(score.draws, 1);
      });

      test('round trip serialization works', () {
        const original = Score(xWins: 10, oWins: 15, draws: 5);
        final json = original.toJson();
        final deserialized = Score.fromJson(json);

        expect(deserialized, original);
      });
    });

    group('equality', () {
      test('identical scores are equal', () {
        const score1 = Score(xWins: 1, oWins: 2, draws: 3);
        const score2 = Score(xWins: 1, oWins: 2, draws: 3);

        expect(score1, score2);
      });

      test('different xWins are not equal', () {
        const score1 = Score(xWins: 1, oWins: 2, draws: 3);
        const score2 = Score(xWins: 5, oWins: 2, draws: 3);

        expect(score1, isNot(score2));
      });

      test('different oWins are not equal', () {
        const score1 = Score(xWins: 1, oWins: 2, draws: 3);
        const score2 = Score(xWins: 1, oWins: 7, draws: 3);

        expect(score1, isNot(score2));
      });

      test('different draws are not equal', () {
        const score1 = Score(xWins: 1, oWins: 2, draws: 3);
        const score2 = Score(xWins: 1, oWins: 2, draws: 9);

        expect(score1, isNot(score2));
      });
    });
  });
}
