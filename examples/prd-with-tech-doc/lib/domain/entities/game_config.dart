import 'package:equatable/equatable.dart';
import 'difficulty_level.dart';
import 'game_mode.dart';
import 'player.dart';

class GameConfig extends Equatable {
  final GameMode gameMode;
  final DifficultyLevel? difficultyLevel;
  final Player firstPlayer;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const GameConfig({
    required this.gameMode,
    this.difficultyLevel,
    this.firstPlayer = Player.x,
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

  @override
  List<Object?> get props => [
        gameMode,
        difficultyLevel,
        firstPlayer,
        soundEnabled,
        vibrationEnabled,
      ];
}
