enum Player {
  x,
  o,
  none;

  bool get isX => this == Player.x;
  bool get isO => this == Player.o;
  bool get isEmpty => this == Player.none;

  Player get opponent => this == Player.x ? Player.o : Player.x;

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