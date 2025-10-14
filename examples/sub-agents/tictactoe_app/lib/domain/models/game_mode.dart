/// Represents the available game modes in the application
///
/// This enum defines the two primary ways users can play Tic-Tac-Toe:
/// - [vsAi]: Single player mode where the user plays against an AI opponent
/// - [twoPlayer]: Local multiplayer mode where two users play on the same device
///
/// Note: UI presentation properties (display names, icons, etc.) are provided
/// via the GameModeUI extension in the presentation layer, following Clean
/// Architecture principles.
enum GameMode {
  /// Play against an AI opponent with selectable difficulty
  vsAi,

  /// Local pass-and-play mode for two human players
  twoPlayer;

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
