import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/game_state.dart';
import '../models/game_state_model.dart';

/// Repository for GameState persistence
///
/// Responsibilities:
/// - Convert between domain entities (GameState) and data models (GameStateModel)
/// - Handle persistence using SharedPreferences
/// - Manage serialization/deserialization of game saves
///
/// Architecture Flow:
/// - Load: Storage → JSON → GameStateModel → GameState entity
/// - Save: GameState entity → GameStateModel → JSON → Storage
class GameStateRepository {
  static const String _savedGameKey = 'saved_game';

  /// Saves a game state for later resumption
  ///
  /// Converts domain entity to data model, then persists:
  /// 1. Convert GameState entity to GameStateModel
  /// 2. Serialize GameStateModel to JSON string
  /// 3. Save to SharedPreferences
  Future<void> saveGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final model = GameStateModel.fromEntity(state);
    final jsonString = jsonEncode(model.toJson());
    await prefs.setString(_savedGameKey, jsonString);
  }

  /// Loads a saved game state
  ///
  /// Returns a domain GameState entity by:
  /// 1. Loading JSON string from SharedPreferences
  /// 2. Deserializing to GameStateModel
  /// 3. Converting GameStateModel to GameState entity
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
      final model = GameStateModel.fromJson(json);
      return model.toEntity();
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
