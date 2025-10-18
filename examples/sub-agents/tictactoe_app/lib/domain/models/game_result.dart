/// Represents the possible outcomes of a Tic-Tac-Toe game
///
/// This enum defines the four possible states a game can be in:
/// - [ongoing]: Game is still in progress
/// - [win]: Current player has won the game
/// - [loss]: Current player has lost the game (used in AI mode)
/// - [draw]: Game ended with no winner (board full)
///
/// Note: Display properties (messages, colors, etc.) are provided
/// via extensions in the presentation layer, following Clean Architecture principles.
enum GameResult {
  /// Game is still in progress, no winner yet
  ongoing,

  /// Current player has won the game
  win,

  /// Current player has lost the game
  loss,

  /// Game ended in a draw (board full, no winner)
  draw;

  /// Convert string to GameResult enum
  static GameResult? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return GameResult.values.firstWhere((result) => result.name == value);
    } catch (e) {
      return null;
    }
  }

  /// Convert GameResult enum to string for persistence
  String toStorageString() => name;
}
