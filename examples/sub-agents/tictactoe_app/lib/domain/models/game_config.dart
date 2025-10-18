import 'package:equatable/equatable.dart';
import 'game_mode.dart';
import 'player.dart';

/// Configuration for a Tic-Tac-Toe game
///
/// Stores the initial settings for a game including:
/// - Game mode (vs AI or two player)
/// - Which player goes first
/// - Sound and vibration preferences
///
/// This is a pure data model with no business logic.
class GameConfig extends Equatable {
  /// The game mode (vs AI or two player)
  final GameMode gameMode;

  /// Which player makes the first move
  final Player firstPlayer;

  /// Whether sound effects are enabled
  final bool soundEnabled;

  /// Whether haptic feedback is enabled
  final bool vibrationEnabled;

  const GameConfig({
    required this.gameMode,
    required this.firstPlayer,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  /// Creates a GameConfig from JSON
  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      gameMode:
          GameMode.fromString(json['gameMode'] as String?) ??
          GameMode.twoPlayer,
      firstPlayer:
          Player.fromString(json['firstPlayer'] as String?) ?? Player.x,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  /// Converts GameConfig to JSON
  Map<String, dynamic> toJson() {
    return {
      'gameMode': gameMode.toStorageString(),
      'firstPlayer': firstPlayer.toStorageString(),
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  /// Creates a copy of this config with modified values
  GameConfig copyWith({
    GameMode? gameMode,
    Player? firstPlayer,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return GameConfig(
      gameMode: gameMode ?? this.gameMode,
      firstPlayer: firstPlayer ?? this.firstPlayer,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object?> get props => [
    gameMode,
    firstPlayer,
    soundEnabled,
    vibrationEnabled,
  ];
}
