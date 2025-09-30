import '../../domain/models/game_result.dart';
import '../../domain/models/player.dart';
import 'player_extensions.dart';

// Re-export player extensions for convenience
export 'player_extensions.dart';

/// Presentation layer extensions for GameResult
/// Handles display text generation for game results
extension GameResultExtensions on GameResult {
  /// Returns the display text for the game result
  String displayText(Player winner) {
    switch (this) {
      case GameResult.win:
        return '${winner.symbol} Wins!';
      case GameResult.loss:
        return '${winner.symbol} Wins!';
      case GameResult.draw:
        return "It's a Draw!";
      case GameResult.ongoing:
        return '';
    }
  }
}
