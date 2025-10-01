import 'package:equatable/equatable.dart';
import 'difficulty_level.dart';
import 'game_mode.dart';
import 'player.dart';

/// Game configuration model with JSON serialization
class GameConfig extends Equatable {
  final GameMode gameMode;
  final DifficultyLevel? difficultyLevel;
  final Player firstPlayer;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const GameConfig({
    required this.gameMode,
    this.difficultyLevel,
    required this.firstPlayer,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  GameConfig copyWith({
    GameMode? gameMode,
    DifficultyLevel? difficultyLevel,
    Player? firstPlayer,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return GameConfig(
      gameMode: gameMode ?? this.gameMode,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      firstPlayer: firstPlayer ?? this.firstPlayer,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  /// Creates a GameConfig from JSON
  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      gameMode: _stringToGameMode(json['gameMode'] as String),
      difficultyLevel: json['difficultyLevel'] != null
          ? _stringToDifficulty(json['difficultyLevel'] as String)
          : null,
      firstPlayer: _stringToPlayer(json['firstPlayer'] as String),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  /// Converts GameConfig to JSON
  Map<String, dynamic> toJson() {
    return {
      'gameMode': _gameModeToString(gameMode),
      'difficultyLevel': difficultyLevel != null ? _difficultyToString(difficultyLevel!) : null,
      'firstPlayer': _playerToString(firstPlayer),
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  // Helper methods for GameMode enum conversion
  static String _gameModeToString(GameMode mode) {
    switch (mode) {
      case GameMode.singlePlayer:
        return 'singlePlayer';
      case GameMode.twoPlayer:
        return 'twoPlayer';
    }
  }

  static GameMode _stringToGameMode(String value) {
    switch (value) {
      case 'singlePlayer':
        return GameMode.singlePlayer;
      case 'twoPlayer':
        return GameMode.twoPlayer;
      default:
        return GameMode.singlePlayer;
    }
  }

  // Helper methods for DifficultyLevel enum conversion
  static String _difficultyToString(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return 'easy';
      case DifficultyLevel.medium:
        return 'medium';
      case DifficultyLevel.hard:
        return 'hard';
    }
  }

  static DifficultyLevel _stringToDifficulty(String value) {
    switch (value) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'medium':
        return DifficultyLevel.medium;
      case 'hard':
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.easy;
    }
  }

  // Helper methods for Player enum conversion
  static String _playerToString(Player player) {
    switch (player) {
      case Player.x:
        return 'x';
      case Player.o:
        return 'o';
      case Player.none:
        return 'none';
    }
  }

  static Player _stringToPlayer(String value) {
    switch (value) {
      case 'x':
        return Player.x;
      case 'o':
        return Player.o;
      case 'none':
        return Player.none;
      default:
        return Player.none;
    }
  }

  @override
  List<Object?> get props => [
        gameMode,
        difficultyLevel,
        firstPlayer,
        soundEnabled,
        vibrationEnabled,
      ];
}
