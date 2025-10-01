import 'package:equatable/equatable.dart';
import 'player.dart';

/// Represents the complete state of a tic-tac-toe game
class GameState extends Equatable {
  /// The 9-cell board (null = empty, X/O = occupied)
  final List<Player?> board;

  /// The current player's turn
  final Player currentPlayer;

  /// Whether the game is over
  final bool isGameOver;

  const GameState({
    required this.board,
    required this.currentPlayer,
    this.isGameOver = false,
  }) : assert(board.length == 9);

  /// Creates an initial empty game state
  factory GameState.initial() {
    return GameState(
      board: List.filled(9, null),
      currentPlayer: Player.x,
      isGameOver: false,
    );
  }

  /// Creates a copy with optional field updates
  GameState copyWith({
    List<Player?>? board,
    Player? currentPlayer,
    bool? isGameOver,
  }) {
    return GameState(
      board: board ?? List.from(this.board),
      currentPlayer: currentPlayer ?? this.currentPlayer,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'board': board.map((p) => p?.toJson()).toList(),
      'currentPlayer': currentPlayer.toJson(),
      'isGameOver': isGameOver,
    };
  }

  /// Creates from JSON
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      board: (json['board'] as List)
          .map((p) => p != null ? Player.fromJson(p as String) : null)
          .toList(),
      currentPlayer: Player.fromJson(json['currentPlayer'] as String),
      isGameOver: json['isGameOver'] as bool,
    );
  }

  @override
  List<Object?> get props => [board, currentPlayer, isGameOver];

  @override
  String toString() {
    final boardStr = StringBuffer();
    for (int i = 0; i < 9; i++) {
      if (i % 3 == 0 && i != 0) boardStr.write('\n');
      boardStr.write(board[i]?.symbol ?? '-');
      if (i % 3 != 2) boardStr.write(' ');
    }
    return 'GameState(\n$boardStr\nCurrent: ${currentPlayer.symbol}, GameOver: $isGameOver)';
  }
}
