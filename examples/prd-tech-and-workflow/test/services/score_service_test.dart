import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/models/score.dart';
import 'package:tic_tac_toe/services/score_service.dart';

void main() {
  group('ScoreService', () {
    late SharedPreferences prefs;
    late ScoreService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = ScoreService(prefs);
    });

    group('loadScore', () {
      test('returns initial score when no saved data', () {
        final score = service.loadScore();

        expect(score, Score.initial());
      });

      test('loads saved score from preferences', () async {
        const savedScore = Score(xWins: 3, oWins: 2, draws: 1);
        await service.saveScore(savedScore);

        final loadedScore = service.loadScore();

        expect(loadedScore, savedScore);
      });

      test('returns initial score when JSON is malformed', () async {
        await prefs.setString('tic_tac_toe_scores', 'invalid json');

        final score = service.loadScore();

        expect(score, Score.initial());
      });
    });

    group('saveScore', () {
      test('saves score to preferences', () async {
        const score = Score(xWins: 5, oWins: 3, draws: 2);

        await service.saveScore(score);
        final loaded = service.loadScore();

        expect(loaded, score);
      });

      test('overwrites previous score', () async {
        const firstScore = Score(xWins: 1, oWins: 1, draws: 1);
        const secondScore = Score(xWins: 10, oWins: 20, draws: 30);

        await service.saveScore(firstScore);
        await service.saveScore(secondScore);

        final loaded = service.loadScore();
        expect(loaded, secondScore);
      });
    });

    group('recordWin', () {
      test('increments X wins when Player.x wins', () async {
        const currentScore = Score(xWins: 2, oWins: 3, draws: 1);

        final updatedScore = await service.recordWin(currentScore, Player.x);

        expect(updatedScore.xWins, 3);
        expect(updatedScore.oWins, 3);
        expect(updatedScore.draws, 1);
      });

      test('increments O wins when Player.o wins', () async {
        const currentScore = Score(xWins: 2, oWins: 3, draws: 1);

        final updatedScore = await service.recordWin(currentScore, Player.o);

        expect(updatedScore.xWins, 2);
        expect(updatedScore.oWins, 4);
        expect(updatedScore.draws, 1);
      });

      test('persists win to preferences', () async {
        final currentScore = Score.initial();

        await service.recordWin(currentScore, Player.x);
        final loadedScore = service.loadScore();

        expect(loadedScore.xWins, 1);
      });
    });

    group('recordDraw', () {
      test('increments draws count', () async {
        const currentScore = Score(xWins: 2, oWins: 3, draws: 1);

        final updatedScore = await service.recordDraw(currentScore);

        expect(updatedScore.xWins, 2);
        expect(updatedScore.oWins, 3);
        expect(updatedScore.draws, 2);
      });

      test('persists draw to preferences', () async {
        final currentScore = Score.initial();

        await service.recordDraw(currentScore);
        final loadedScore = service.loadScore();

        expect(loadedScore.draws, 1);
      });
    });

    group('resetScores', () {
      test('resets all scores to zero', () async {
        const currentScore = Score(xWins: 10, oWins: 20, draws: 5);
        await service.saveScore(currentScore);

        final resetScore = await service.resetScores();

        expect(resetScore, Score.initial());
      });

      test('persists reset to preferences', () async {
        const currentScore = Score(xWins: 10, oWins: 20, draws: 5);
        await service.saveScore(currentScore);

        await service.resetScores();
        final loadedScore = service.loadScore();

        expect(loadedScore, Score.initial());
      });
    });

    group('integration', () {
      test('multiple operations update correctly', () async {
        var score = Score.initial();

        // Record some wins
        score = await service.recordWin(score, Player.x);
        score = await service.recordWin(score, Player.o);
        score = await service.recordWin(score, Player.x);
        score = await service.recordDraw(score);

        expect(score.xWins, 2);
        expect(score.oWins, 1);
        expect(score.draws, 1);

        // Verify persistence
        final loadedScore = service.loadScore();
        expect(loadedScore, score);
      });

      test('reset clears all accumulated scores', () async {
        var score = Score.initial();

        // Accumulate some scores
        for (int i = 0; i < 5; i++) {
          score = await service.recordWin(score, Player.x);
          score = await service.recordWin(score, Player.o);
          score = await service.recordDraw(score);
        }

        expect(score.totalGames, 15);

        // Reset
        score = await service.resetScores();

        expect(score.totalGames, 0);
        expect(service.loadScore().totalGames, 0);
      });
    });
  });
}
