part of 'game_ui_cubit.dart';

/// State for the game UI
///
/// Contains the current game board state and current player.
/// This is simplified for UI demonstration - real game state will include
/// win conditions, game status, move history, etc. in future iterations.
class GameUIState extends Equatable {
  /// The game board as a list of 9 strings ('X', 'O', or empty)
  final List<String> board;

  /// The current player ('X' or 'O')
  final String currentPlayer;

  /// Whether the game is over (placeholder - will be computed by GameService)
  final bool isGameOver;

  const GameUIState({
    required this.board,
    required this.currentPlayer,
    this.isGameOver = false,
  });

  /// Initial state with empty board and X as first player
  const GameUIState.initial()
    : board = const ['', '', '', '', '', '', '', '', ''],
      currentPlayer = 'X',
      isGameOver = false;

  /// Creates a copy of this state with the given fields replaced
  GameUIState copyWith({
    List<String>? board,
    String? currentPlayer,
    bool? isGameOver,
  }) {
    return GameUIState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }

  @override
  List<Object?> get props => [board, currentPlayer, isGameOver];
}
