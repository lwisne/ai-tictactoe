import '../../domain/models/player.dart';

/// Presentation layer extensions for Player
/// Handles display symbols for players
extension PlayerExtensions on Player {
  /// Returns the display symbol for the player
  String get symbol {
    switch (this) {
      case Player.x:
        return 'X';
      case Player.o:
        return 'O';
      case Player.none:
        return '';
    }
  }
}
