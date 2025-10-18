import 'package:equatable/equatable.dart';
import 'game_config.dart';
import 'game_result.dart';
import 'player.dart';
import 'position.dart';

/// Represents the complete state of a Tic-Tac-Toe game
///
/// This model contains all information about the current game including:
/// - The 3x3 game board
/// - Current player whose turn it is
/// - Game result (ongoing, win, loss, draw)
/// - Winner information if game is finished
/// - Move history for undo functionality
/// - Game configuration
/// - Timing information
///
/// This is a pure data model with no business logic.
/// All game logic (turn management, win detection, etc.) is in GameService.
class GameState extends Equatable {
  /// The 3x3 game board
  /// Each cell contains Player.x, Player.o, or Player.none (empty)
  final List<List<Player>> board;

  /// The player whose turn it is
  final Player currentPlayer;

  /// The current result of the game
  final GameResult result;

  /// The winner of the game (null if game is ongoing or draw)
  final Player? winner;

  /// The positions that form the winning line (null if no winner)
  final List<Position>? winningLine;

  /// History of all moves made (for undo functionality)
  final List<Position> moveHistory;

  /// Game configuration settings
  final GameConfig config;

  /// When the game started
  final DateTime startTime;

  /// Time elapsed since game start
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

  /// Creates a GameState from JSON
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      board: (json['board'] as List)
          .map(
            (row) => (row as List)
                .map(
                  (cell) => Player.fromString(cell as String?) ?? Player.none,
                )
                .toList(),
          )
          .toList(),
      currentPlayer:
          Player.fromString(json['currentPlayer'] as String?) ?? Player.x,
      result:
          GameResult.fromString(json['result'] as String?) ??
          GameResult.ongoing,
      winner: json['winner'] != null
          ? Player.fromString(json['winner'] as String?)
          : null,
      winningLine: json['winningLine'] != null
          ? (json['winningLine'] as List)
                .map((pos) => Position.fromJson(pos as Map<String, dynamic>))
                .toList()
          : null,
      moveHistory: (json['moveHistory'] as List? ?? [])
          .map((pos) => Position.fromJson(pos as Map<String, dynamic>))
          .toList(),
      config: GameConfig.fromJson(json['config'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      elapsedTime: Duration(microseconds: json['elapsedTime'] as int? ?? 0),
    );
  }

  /// Converts GameState to JSON
  Map<String, dynamic> toJson() {
    return {
      'board': board
          .map((row) => row.map((cell) => cell.toStorageString()).toList())
          .toList(),
      'currentPlayer': currentPlayer.toStorageString(),
      'result': result.toStorageString(),
      'winner': winner?.toStorageString(),
      'winningLine': winningLine?.map((pos) => pos.toJson()).toList(),
      'moveHistory': moveHistory.map((pos) => pos.toJson()).toList(),
      'config': config.toJson(),
      'startTime': startTime.toIso8601String(),
      'elapsedTime': elapsedTime.inMicroseconds,
    };
  }

  /// Creates a copy of this state with modified values
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
