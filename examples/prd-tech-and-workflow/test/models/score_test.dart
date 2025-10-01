import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/score.dart';

void main() {
  group('Score', () {
    test('empty() creates score with all zeros', () {
      final score = Score.empty();

      expect(score.xWins, 0);
      expect(score.oWins, 0);
      expect(score.draws, 0);
    });

    test('fromJson creates score from valid JSON', () {
      final json = {'xWins': 5, 'oWins': 3, 'draws': 2};
      final score = Score.fromJson(json);

      expect(score.xWins, 5);
      expect(score.oWins, 3);
      expect(score.draws, 2);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};
      final score = Score.fromJson(json);

      expect(score.xWins, 0);
      expect(score.oWins, 0);
      expect(score.draws, 0);
    });

    test('toJson converts score to JSON', () {
      const score = Score(xWins: 5, oWins: 3, draws: 2);
      final json = score.toJson();

      expect(json['xWins'], 5);
      expect(json['oWins'], 3);
      expect(json['draws'], 2);
    });

    test('copyWith updates xWins', () {
      const score = Score(xWins: 5, oWins: 3, draws: 2);
      final updated = score.copyWith(xWins: 10);

      expect(updated.xWins, 10);
      expect(updated.oWins, 3);
      expect(updated.draws, 2);
    });

    test('copyWith updates oWins', () {
      const score = Score(xWins: 5, oWins: 3, draws: 2);
      final updated = score.copyWith(oWins: 8);

      expect(updated.xWins, 5);
      expect(updated.oWins, 8);
      expect(updated.draws, 2);
    });

    test('copyWith updates draws', () {
      const score = Score(xWins: 5, oWins: 3, draws: 2);
      final updated = score.copyWith(draws: 7);

      expect(updated.xWins, 5);
      expect(updated.oWins, 3);
      expect(updated.draws, 7);
    });

    test('totalGames calculates sum of all games', () {
      const score = Score(xWins: 5, oWins: 3, draws: 2);
      expect(score.totalGames, 10);
    });

    test('totalGames is zero for empty score', () {
      final score = Score.empty();
      expect(score.totalGames, 0);
    });

    test('equality works correctly', () {
      const score1 = Score(xWins: 5, oWins: 3, draws: 2);
      const score2 = Score(xWins: 5, oWins: 3, draws: 2);
      const score3 = Score(xWins: 4, oWins: 3, draws: 2);

      expect(score1, equals(score2));
      expect(score1, isNot(equals(score3)));
    });
  });
}
