/// Represents the players in a Tic-Tac-Toe game
///
/// This enum defines the three possible states for each cell on the board:
/// - [x]: First player (typically starts first)
/// - [o]: Second player
/// - [none]: Empty cell
///
/// Note: UI presentation properties (display symbols, colors, etc.) are provided
/// via extensions in the presentation layer, following Clean Architecture principles.
enum Player {
  /// First player, typically represented as 'X'
  x,

  /// Second player, typically represented as 'O'
  o,

  /// Empty cell with no player
  none;

  /// Gets the opponent player
  ///
  /// This is a domain business rule: in Tic-Tac-Toe, X's opponent is O and vice versa.
  /// Returns [Player.none] if called on [Player.none].
  Player get opponent {
    switch (this) {
      case Player.x:
        return Player.o;
      case Player.o:
        return Player.x;
      case Player.none:
        return Player.none;
    }
  }

  /// Convert string to Player enum
  static Player? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return Player.values.firstWhere((player) => player.name == value);
    } catch (e) {
      return null;
    }
  }

  /// Convert Player enum to string for persistence
  String toStorageString() => name;
}
