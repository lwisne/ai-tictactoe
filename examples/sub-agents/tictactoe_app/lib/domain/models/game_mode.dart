/// Represents the available game modes in the application
///
/// This enum defines the two primary ways users can play Tic-Tac-Toe:
/// - [vsAi]: Single player mode where the user plays against an AI opponent
/// - [twoPlayer]: Local multiplayer mode where two users play on the same device
enum GameMode {
  /// Play against an AI opponent with selectable difficulty
  vsAi,

  /// Local pass-and-play mode for two human players
  twoPlayer;

  /// User-friendly display name for the game mode
  String get displayName {
    switch (this) {
      case GameMode.vsAi:
        return 'Play vs AI';
      case GameMode.twoPlayer:
        return 'Two Player';
    }
  }

  /// Descriptive subtitle explaining the game mode
  String get subtitle {
    switch (this) {
      case GameMode.vsAi:
        return 'Challenge the AI';
      case GameMode.twoPlayer:
        return 'Pass & Play on this device';
    }
  }

  /// Icon representation for the game mode
  String get iconName {
    switch (this) {
      case GameMode.vsAi:
        return 'smart_toy'; // Material Icons robot/AI icon
      case GameMode.twoPlayer:
        return 'people'; // Material Icons people icon
    }
  }

  /// Convert string to GameMode enum
  static GameMode? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return GameMode.values.firstWhere((mode) => mode.name == value);
    } catch (e) {
      // Return null if value doesn't match any mode
      return null;
    }
  }

  /// Convert GameMode enum to string for persistence
  String toStorageString() => name;
}
