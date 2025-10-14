import 'package:flutter/material.dart';

import '../../domain/models/game_mode.dart';

/// UI presentation extensions for GameMode
///
/// Provides display properties for game modes that are specific to the
/// presentation layer. This keeps the domain model clean and focused on
/// business logic while allowing the UI layer to have mode-specific formatting.
///
/// Following Clean Architecture principles, presentation concerns are separated
/// from domain models.
extension GameModeUI on GameMode {
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
  IconData get icon {
    switch (this) {
      case GameMode.vsAi:
        return Icons.smart_toy;
      case GameMode.twoPlayer:
        return Icons.people;
    }
  }
}
