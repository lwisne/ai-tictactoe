import 'package:equatable/equatable.dart';
import 'game_result.dart';
import 'player.dart';
import 'position.dart';
import 'game_config.dart';

/// Game state model with JSON serialization
class GameState extends Equatable {
  final List<List<Player>> board;
  final Player currentPlayer;
  final GameResult result;
  final Player? winner;
  final List<Position>? winningLine;
  final List<Position> moveHistory;
  final GameConfig config;
  final DateTime startTime;
  final Duration elapsedTime;

  const GameState({
    required this.board,
    required this.currentPlayer,
    this.result = GameResult.ongoing,
    this.winner,
    this.winningLine,
    this.moveHistory = const [],
    required this.config,
    required this.startTime,
    this.elapsedTime = Duration.zero,
  });

  GameState copyWith({
    List<List<Player>>? board,
    Player? currentPlayer,
    GameResult? result,
    Player? winner,
    List<Position>? winningLine,
    List<Position>? moveHistory,
    GameConfig? config,
    DateTime? startTime,
    Duration? elapsedTime,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      result: result ?? this.result,
      winner: winner ?? this.winner,
      winningLine: winningLine ?? this.winningLine,
      moveHistory: moveHistory ?? this.moveHistory,
      config: config ?? this.config,
      startTime: startTime ?? this.startTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
    );
  }

  /// Creates a GameState from JSON
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      board: (json['board'] as List)
          .map((row) => (row as List)
              .map((cell) => _stringToPlayer(cell as String))
              .toList())
          .toList(),
      currentPlayer: _stringToPlayer(json['currentPlayer'] as String),
      result: _stringToResult(json['result'] as String),
      winner: json['winner'] != null ? _stringToPlayer(json['winner'] as String) : null,
      winningLine: json['winningLine'] != null
          ? (json['winningLine'] as List)
              .map((pos) => Position(
                    row: (pos as Map<String, dynamic>)['row'] as int,
                    col: (pos as Map<String, dynamic>)['col'] as int,
                  ))
              .toList()
          : null,
      moveHistory: (json['moveHistory'] as List)
          .map((pos) => Position(
                row: (pos as Map<String, dynamic>)['row'] as int,
                col: (pos as Map<String, dynamic>)['col'] as int,
              ))
          .toList(),
      config: GameConfig.fromJson(json['config'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      elapsedTime: Duration(milliseconds: json['elapsedTimeMs'] as int),
    );
  }

  /// Converts GameState to JSON
  Map<String, dynamic> toJson() {
    return {
      'board': board
          .map((row) => row.map((player) => _playerToString(player)).toList())
          .toList(),
      'currentPlayer': _playerToString(currentPlayer),
      'result': _resultToString(result),
      'winner': winner != null ? _playerToString(winner!) : null,
      'winningLine': winningLine?.map((pos) => {'row': pos.row, 'col': pos.col}).toList(),
      'moveHistory': moveHistory.map((pos) => {'row': pos.row, 'col': pos.col}).toList(),
      'config': config.toJson(),
      'startTime': startTime.toIso8601String(),
      'elapsedTimeMs': elapsedTime.inMilliseconds,
    };
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

  @override
  List<Object?> get props => [
        board,
        currentPlayer,
        result,
        winner,
        winningLine,
        moveHistory,
        config,
        startTime,
        elapsedTime,
      ];
}
