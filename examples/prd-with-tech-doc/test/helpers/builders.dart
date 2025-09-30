import 'package:tic_tac_toe/domain/entities/difficulty_level.dart';
import 'package:tic_tac_toe/domain/entities/game_config.dart';
import 'package:tic_tac_toe/domain/entities/game_mode.dart';
import 'package:tic_tac_toe/domain/entities/game_result.dart';
import 'package:tic_tac_toe/domain/entities/game_state.dart';
import 'package:tic_tac_toe/domain/entities/player.dart';
import 'package:tic_tac_toe/domain/entities/position.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';

/// Test data builders to keep tests readable and maintainable
class TestDataBuilder {
  /// Creates a default GameConfig for testing
  static GameConfig createGameConfig({
    GameMode? gameMode,
    Player? firstPlayer,
    DifficultyLevel? difficultyLevel,
  }) {
    return GameConfig(
      gameMode: gameMode ?? GameMode.singlePlayer,
      firstPlayer: firstPlayer ?? Player.x,
      difficultyLevel: difficultyLevel,
    );
  }

  /// Creates a GameState for testing
  static GameState createGameState({
    List<List<Player>>? board,
    Player? currentPlayer,
    GameConfig? config,
    GameResult? result,
    Player? winner,
    List<Position>? winningLine,
    List<Position>? moveHistory,
    DateTime? startTime,
  }) {
    return GameState(
      board: board ??
          [
            [Player.none, Player.none, Player.none],
            [Player.none, Player.none, Player.none],
            [Player.none, Player.none, Player.none],
          ],
      currentPlayer: currentPlayer ?? Player.x,
      config: config ??
          const GameConfig(
            gameMode: GameMode.twoPlayer,
            firstPlayer: Player.x,
          ),
      result: result ?? GameResult.ongoing,
      winner: winner,
      winningLine: winningLine,
      moveHistory: moveHistory ?? [],
      startTime: startTime ?? DateTime.now(),
    );
  }

  /// Creates a GameState with a specific board configuration
  static GameState createGameStateWithBoard(
    List<List<Player>> board, {
    Player? currentPlayer,
    GameConfig? config,
  }) {
    return GameState(
      board: board,
      currentPlayer: currentPlayer ?? Player.x,
      config: config ??
          const GameConfig(
            gameMode: GameMode.twoPlayer,
            firstPlayer: Player.x,
          ),
      result: GameResult.ongoing,
      moveHistory: [],
      startTime: DateTime.now(),
    );
  }

  /// Creates a Score for testing
  static Score createScore({
    int? wins,
    int? losses,
    int? draws,
  }) {
    return Score(
      wins: wins ?? 0,
      losses: losses ?? 0,
      draws: draws ?? 0,
    );
  }

  /// Creates a winning board state for testing
  static List<List<Player>> createWinningBoard({
    Player? winner,
    String type = 'horizontal',
  }) {
    final w = winner ?? Player.x;
    final o = w == Player.x ? Player.o : Player.x;

    switch (type) {
      case 'horizontal':
        return [
          [w, w, w],
          [o, o, Player.none],
          [Player.none, Player.none, Player.none],
        ];
      case 'vertical':
        return [
          [w, o, Player.none],
          [w, o, Player.none],
          [w, Player.none, Player.none],
        ];
      case 'diagonal_tlbr': // top-left to bottom-right
        return [
          [w, o, Player.none],
          [o, w, Player.none],
          [Player.none, Player.none, w],
        ];
      case 'diagonal_trbl': // top-right to bottom-left
        return [
          [Player.none, o, w],
          [o, w, Player.none],
          [w, Player.none, Player.none],
        ];
      default:
        return [
          [w, w, w],
          [o, o, Player.none],
          [Player.none, Player.none, Player.none],
        ];
    }
  }

  /// Creates a draw board state for testing
  static List<List<Player>> createDrawBoard() {
    return [
      [Player.x, Player.o, Player.x],
      [Player.o, Player.x, Player.o],
      [Player.o, Player.x, Player.o],
    ];
  }

  /// Creates an empty board for testing
  static List<List<Player>> createEmptyBoard() {
    return [
      [Player.none, Player.none, Player.none],
      [Player.none, Player.none, Player.none],
      [Player.none, Player.none, Player.none],
    ];
  }
}
