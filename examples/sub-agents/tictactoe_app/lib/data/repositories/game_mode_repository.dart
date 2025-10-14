import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/game_mode.dart';

/// Repository for persisting last played game mode
/// Follows Clean Architecture - handles data persistence only
@LazySingleton()
class GameModeRepository {
  static const String _lastPlayedModeKey = 'last_played_game_mode';

  /// Saves the last played game mode to persistent storage
  Future<void> saveLastPlayedMode(GameMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedModeKey, mode.toStorageString());
  }

  /// Loads the last played game mode from persistent storage
  /// Returns null if no saved mode exists
  Future<GameMode?> loadLastPlayedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_lastPlayedModeKey);

    if (modeString == null || modeString.isEmpty) {
      return null;
    }

    final mode = GameMode.fromString(modeString);

    // If corrupted data (invalid mode), clean up
    if (mode == null) {
      await deleteLastPlayedMode();
    }

    return mode;
  }

  /// Checks if a last played mode exists in storage
  Future<bool> hasLastPlayedMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_lastPlayedModeKey);
  }

  /// Deletes the saved last played mode
  Future<void> deleteLastPlayedMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastPlayedModeKey);
  }
}
