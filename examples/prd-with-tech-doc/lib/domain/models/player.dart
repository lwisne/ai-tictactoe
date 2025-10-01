enum Player {
  x,
  o,
  none;

  /// Returns the opponent player (domain logic)
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
}
