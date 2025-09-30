import 'package:equatable/equatable.dart';
import 'player.dart';

enum GameStatus {
  playing,
  won,
  draw;

  bool get isPlaying => this == GameStatus.playing;
  bool get isWon => this == GameStatus.won;
  bool get isDraw => this == GameStatus.draw;
  bool get isOver => isWon || isDraw;
}

class GameResult extends Equatable {
  final GameStatus status;
  final Player? winner;
  final List<int>? winningLine;

  const GameResult({
    required this.status,
    this.winner,
    this.winningLine,
  });

  const GameResult.playing()
      : status = GameStatus.playing,
        winner = null,
        winningLine = null;

  const GameResult.won(this.winner, this.winningLine)
      : status = GameStatus.won;

  const GameResult.draw()
      : status = GameStatus.draw,
        winner = null,
        winningLine = null;

  @override
  List<Object?> get props => [status, winner, winningLine];
}