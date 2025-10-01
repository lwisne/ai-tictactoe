import '../../domain/models/game_result.dart';
import '../../domain/models/player.dart';
import 'player_extensions.dart';

/// Presentation layer helper for GameResult display
class GameResultDisplay {
  /// Returns the display text for the game result
  static String displayText(GameResult result, Player winner) {
    switch (result) {
      case GameResult.win:
        return '${PlayerDisplay.symbol(winner)} Wins!';
      case GameResult.loss:
        return '${PlayerDisplay.symbol(winner)} Wins!';
      case GameResult.draw:
        return "It's a Draw!";
      case GameResult.ongoing:
        return '';
    }
  }
}

/// Presentation layer extensions for GameResult
/// Handles display text generation for game results
extension GameResultExtensions on GameResult {
  /// Returns the display text for the game result
  String displayText(Player winner) => GameResultDisplay.displayText(this, winner);
}
