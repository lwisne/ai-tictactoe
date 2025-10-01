/// Represents a player in the tic-tac-toe game
enum Player {
  x,
  o;

  /// Returns the opposite player
  Player get opponent {
    return this == Player.x ? Player.o : Player.x;
  }

  /// Returns the display symbol for the player
  String get symbol {
    return this == Player.x ? 'X' : 'O';
  }

  /// Converts player to JSON string
  String toJson() => name;

  /// Creates player from JSON string
  static Player fromJson(String json) {
    return Player.values.firstWhere((p) => p.name == json);
  }
}
