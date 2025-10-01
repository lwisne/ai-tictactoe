import '../../domain/models/player.dart';

/// Presentation layer helper for Player display
class PlayerDisplay {
  /// Returns the display symbol for the player
  static String symbol(Player player) {
    switch (player) {
      case Player.x:
        return 'X';
      case Player.o:
        return 'O';
      case Player.none:
        return '';
    }
  }
}

/// Presentation layer extensions for Player
/// Handles display symbols for players
extension PlayerExtensions on Player {
  /// Returns the display symbol for the player
  String get symbol => PlayerDisplay.symbol(this);
}
