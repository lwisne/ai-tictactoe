import 'package:equatable/equatable.dart';
import '../models/game_board.dart';
import '../models/game_mode.dart';
import '../models/game_result.dart';

class GameState extends Equatable {
  final GameBoard board;
  final GameMode gameMode;
  final AiDifficulty? aiDifficulty;
  final GameResult result;
  final bool isAiThinking;

  const GameState({
    required this.board,
    required this.gameMode,
    this.aiDifficulty,
    required this.result,
    this.isAiThinking = false,
  });

  factory GameState.initial({
    required GameMode gameMode,
    AiDifficulty? aiDifficulty,
  }) {
    return GameState(
      board: GameBoard.initial(),
      gameMode: gameMode,
      aiDifficulty: aiDifficulty,
      result: const GameResult.playing(),
      isAiThinking: false,
    );
  }

  GameState copyWith({
    GameBoard? board,
    GameMode? gameMode,
    AiDifficulty? aiDifficulty,
    GameResult? result,
    bool? isAiThinking,
  }) {
    return GameState(
      board: board ?? this.board,
      gameMode: gameMode ?? this.gameMode,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      result: result ?? this.result,
      isAiThinking: isAiThinking ?? this.isAiThinking,
    );
  }

  bool get isGameOver => result.status.isOver;
  bool get canMakeMove => !isGameOver && !isAiThinking;

  @override
  List<Object?> get props => [
        board,
        gameMode,
        aiDifficulty,
        result,
        isAiThinking,
      ];
}