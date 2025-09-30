enum GameMode {
  singlePlayer,
  twoPlayer;

  String get displayName {
    switch (this) {
      case GameMode.singlePlayer:
        return 'Single Player';
      case GameMode.twoPlayer:
        return 'Two Player';
    }
  }
}
