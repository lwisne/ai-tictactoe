import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/models/score.dart';
import 'package:tic_tac_toe/services/score_service.dart';

void main() {
  group('ScoreService', () {
    late ScoreService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = ScoreService(prefs);
    });

    test('loadScore returns empty score when no data exists', () {
      final score = service.loadScore();
      expect(score, Score.empty());
    });

    test('recordWin for Player X increments xWins', () async {
      await service.recordWin(Player.x);
      final score = service.loadScore();

      expect(score.xWins, 1);
      expect(score.oWins, 0);
      expect(score.draws, 0);
    });

    test('recordWin for Player O increments oWins', () async {
      await service.recordWin(Player.o);
      final score = service.loadScore();

      expect(score.xWins, 0);
      expect(score.oWins, 1);
      expect(score.draws, 0);
    });

    test('recordDraw increments draws', () async {
      await service.recordDraw();
      final score = service.loadScore();

      expect(score.xWins, 0);
      expect(score.oWins, 0);
      expect(score.draws, 1);
    });

    test('multiple wins accumulate correctly', () async {
      await service.recordWin(Player.x);
      await service.recordWin(Player.x);
      await service.recordWin(Player.o);
      await service.recordDraw();

      final score = service.loadScore();
      expect(score.xWins, 2);
      expect(score.oWins, 1);
      expect(score.draws, 1);
    });

    test('resetScores clears all scores', () async {
      await service.recordWin(Player.x);
      await service.recordWin(Player.o);
      await service.recordDraw();
      await service.resetScores();

      final score = service.loadScore();
      expect(score, Score.empty());
    });

    test('scores persist across service instances', () async {
      final prefs = await SharedPreferences.getInstance();

      final service1 = ScoreService(prefs);
      await service1.recordWin(Player.x);

      final service2 = ScoreService(prefs);
      final score = service2.loadScore();

      expect(score.xWins, 1);
    });

    test('loadScore handles corrupted JSON gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('game_score', 'invalid json');

      final score = service.loadScore();
      expect(score, Score.empty());
    });
  });
}
