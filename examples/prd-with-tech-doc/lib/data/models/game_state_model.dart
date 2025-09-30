import '../../domain/entities/difficulty_level.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_mode.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/position.dart';

/// Data Transfer Object for GameState persistence
///
/// This model handles serialization/deserialization between
/// the persistence layer and domain entities.
///
/// Responsibilities:
/// - JSON serialization/deserialization
/// - Converting between data format and domain entities
/// - Handling nested entities (board, config, positions)
class GameStateModel {
  final List<List<String>> board;
  final String currentPlayer;
  final String result;
  final String? winner;
  final List<Map<String, int>>? winningLine;
  final List<Map<String, int>> moveHistory;
  final GameConfigModel config;
  final String startTime;
  final int elapsedTimeMs;

  const GameStateModel({
    required this.board,
    required this.currentPlayer,
    required this.result,
    this.winner,
    this.winningLine,
    required this.moveHistory,
    required this.config,
    required this.startTime,
    required this.elapsedTimeMs,
  });

  /// Creates a GameStateModel from JSON
  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    return GameStateModel(
      board: (json['board'] as List)
          .map((row) => (row as List).map((cell) => cell as String).toList())
          .toList(),
      currentPlayer: json['currentPlayer'] as String,
      result: json['result'] as String,
      winner: json['winner'] as String?,
      winningLine: json['winningLine'] != null
          ? (json['winningLine'] as List)
              .map((pos) => Map<String, int>.from(pos as Map))
              .toList()
          : null,
      moveHistory: (json['moveHistory'] as List)
          .map((pos) => Map<String, int>.from(pos as Map))
          .toList(),
      config: GameConfigModel.fromJson(json['config'] as Map<String, dynamic>),
      startTime: json['startTime'] as String,
      elapsedTimeMs: json['elapsedTimeMs'] as int,
    );
  }

  /// Converts GameStateModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'currentPlayer': currentPlayer,
      'result': result,
      'winner': winner,
      'winningLine': winningLine,
      'moveHistory': moveHistory,
      'config': config.toJson(),
      'startTime': startTime,
      'elapsedTimeMs': elapsedTimeMs,
    };
  }

  /// Creates a GameStateModel from a domain GameState entity
  factory GameStateModel.fromEntity(GameState state) {
    return GameStateModel(
      board: state.board
          .map((row) => row.map((player) => _playerToString(player)).toList())
          .toList(),
      currentPlayer: _playerToString(state.currentPlayer),
      result: _resultToString(state.result),
      winner: state.winner != null ? _playerToString(state.winner!) : null,
      winningLine: state.winningLine
          ?.map((pos) => {'row': pos.row, 'col': pos.col})
          .toList(),
      moveHistory:
          state.moveHistory.map((pos) => {'row': pos.row, 'col': pos.col}).toList(),
      config: GameConfigModel.fromEntity(state.config),
      startTime: state.startTime.toIso8601String(),
      elapsedTimeMs: state.elapsedTime.inMilliseconds,
    );
  }

  /// Converts GameStateModel to domain GameState entity
  GameState toEntity() {
    return GameState(
      board: board
          .map((row) => row.map((cell) => _stringToPlayer(cell)).toList())
          .toList(),
      currentPlayer: _stringToPlayer(currentPlayer),
      result: _stringToResult(result),
      winner: winner != null ? _stringToPlayer(winner!) : null,
      winningLine: winningLine
          ?.map((pos) => Position(row: pos['row']!, col: pos['col']!))
          .toList(),
      moveHistory: moveHistory
          .map((pos) => Position(row: pos['row']!, col: pos['col']!))
          .toList(),
      config: config.toEntity(),
      startTime: DateTime.parse(startTime),
      elapsedTime: Duration(milliseconds: elapsedTimeMs),
    );
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

  // Helper methods for GameResult enum conversion
  static String _resultToString(GameResult result) {
    switch (result) {
      case GameResult.ongoing:
        return 'ongoing';
      case GameResult.win:
        return 'win';
      case GameResult.loss:
        return 'loss';
      case GameResult.draw:
        return 'draw';
    }
  }

  static GameResult _stringToResult(String value) {
    switch (value) {
      case 'ongoing':
        return GameResult.ongoing;
      case 'win':
        return GameResult.win;
      case 'loss':
        return GameResult.loss;
      case 'draw':
        return GameResult.draw;
      default:
        return GameResult.ongoing;
    }
  }
}

/// Data Transfer Object for GameConfig persistence
class GameConfigModel {
  final String gameMode;
  final String? difficultyLevel;
  final String firstPlayer;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const GameConfigModel({
    required this.gameMode,
    this.difficultyLevel,
    required this.firstPlayer,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  /// Creates a GameConfigModel from JSON
  factory GameConfigModel.fromJson(Map<String, dynamic> json) {
    return GameConfigModel(
      gameMode: json['gameMode'] as String,
      difficultyLevel: json['difficultyLevel'] as String?,
      firstPlayer: json['firstPlayer'] as String,
      soundEnabled: json['soundEnabled'] as bool,
      vibrationEnabled: json['vibrationEnabled'] as bool,
    );
  }

  /// Converts GameConfigModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'gameMode': gameMode,
      'difficultyLevel': difficultyLevel,
      'firstPlayer': firstPlayer,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  /// Creates a GameConfigModel from a domain GameConfig entity
  factory GameConfigModel.fromEntity(GameConfig config) {
    return GameConfigModel(
      gameMode: _gameModeToString(config.gameMode),
      difficultyLevel: config.difficultyLevel != null
          ? _difficultyToString(config.difficultyLevel!)
          : null,
      firstPlayer: GameStateModel._playerToString(config.firstPlayer),
      soundEnabled: config.soundEnabled,
      vibrationEnabled: config.vibrationEnabled,
    );
  }

  /// Converts GameConfigModel to domain GameConfig entity
  GameConfig toEntity() {
    return GameConfig(
      gameMode: _stringToGameMode(gameMode),
      difficultyLevel: difficultyLevel != null
          ? _stringToDifficulty(difficultyLevel!)
          : null,
      firstPlayer: GameStateModel._stringToPlayer(firstPlayer),
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
    );
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
}
