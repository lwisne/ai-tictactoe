import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/persisted_game_state.dart';

/// Repository for persisting game state across app sessions
///
/// Handles saving and loading of in-progress games to survive
/// app backgrounding or kill. Follows Clean Architecture - handles
/// data persistence only, no business logic.
@LazySingleton()
class GameStatePersistenceRepository {
  static const String _currentGameStateKey = 'current_game_state';

  /// Saves current game state to persistent storage
  ///
  /// This should be called:
  /// - On app lifecycle changes (paused/detached)
  /// - After each move in an in-progress game
  Future<void> saveGameState(PersistedGameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_currentGameStateKey, jsonString);
  }

  /// Loads saved game state from persistent storage
  ///
  /// Returns null if no saved state exists or if state is corrupted.
  /// Automatically cleans up corrupted state.
  Future<PersistedGameState?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_currentGameStateKey);

    if (jsonString == null) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PersistedGameState.fromJson(json);
    } catch (e) {
      // If corrupted data, clean it up and return null
      await clearGameState();
      return null;
    }
  }

  /// Checks if saved game state exists
  ///
  /// Returns true if there's a saved in-progress game.
  Future<bool> hasGameState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentGameStateKey);
  }

  /// Clears saved game state
  ///
  /// This should be called when:
  /// - Game ends normally (win/loss/draw)
  /// - User chooses "New Game" from resume dialog
  /// - Corrupted state is detected
  Future<void> clearGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentGameStateKey);
  }
}
