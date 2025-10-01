import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/game_state.dart';

/// Repository for GameState persistence
///
/// Responsibilities:
/// - Handle persistence using SharedPreferences
/// - Manage serialization/deserialization of game saves
class GameStateRepository {
  static const String _savedGameKey = 'saved_game';

  /// Saves a game state for later resumption
  Future<void> saveGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_savedGameKey, jsonString);
  }

  /// Loads a saved game state
  ///
  /// Returns null if no saved game exists
  Future<GameState?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_savedGameKey);

    if (jsonString == null) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameState.fromJson(json);
    } catch (e) {
      // If deserialization fails, remove corrupted data
      await deleteSavedGame();
      return null;
    }
  }

  /// Checks if a saved game exists
  Future<bool> hasSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_savedGameKey);
  }

  /// Deletes the saved game
  Future<void> deleteSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedGameKey);
  }
}
