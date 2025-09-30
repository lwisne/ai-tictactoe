enum GameMode {
  twoPlayer,
  singlePlayer;

  bool get isSinglePlayer => this == GameMode.singlePlayer;
  bool get isTwoPlayer => this == GameMode.twoPlayer;
}

enum AiDifficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case AiDifficulty.easy:
        return 'Easy';
      case AiDifficulty.medium:
        return 'Medium';
      case AiDifficulty.hard:
        return 'Hard';
    }
  }
}