import 'package:equatable/equatable.dart';
import 'game_config.dart';
import 'game_result.dart';
import 'player.dart';
import 'position.dart';

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
