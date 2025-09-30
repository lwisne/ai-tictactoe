enum DifficultyLevel {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  String get description {
    switch (this) {
      case DifficultyLevel.easy:
        return 'AI makes random moves';
      case DifficultyLevel.medium:
        return 'AI blocks obvious wins';
      case DifficultyLevel.hard:
        return 'AI uses optimal strategy';
    }
  }
}
