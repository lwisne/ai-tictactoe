import 'package:equatable/equatable.dart';
import 'game_state.dart';

/// Represents a complete persisted game session
///
/// This model contains everything needed to resume a game after
/// app backgrounding or kill:
/// - The current game state (board, turn, config, etc.)
/// - Session scores (player wins, AI wins, draws)
/// - Timestamp of when state was saved
///
/// This is a pure data model with no business logic.
class PersistedGameState extends Equatable {
  /// The current game state
  final GameState gameState;

  /// Number of player wins in this session
  final int playerWins;

  /// Number of AI wins in this session (0 for two-player mode)
  final int aiWins;

  /// Number of draws in this session
  final int draws;

  /// When this state was persisted
  final DateTime savedAt;

  const PersistedGameState({
    required this.gameState,
    this.playerWins = 0,
    this.aiWins = 0,
    this.draws = 0,
    required this.savedAt,
  });

  /// Creates a PersistedGameState from JSON
  factory PersistedGameState.fromJson(Map<String, dynamic> json) {
    return PersistedGameState(
      gameState: GameState.fromJson(json['gameState'] as Map<String, dynamic>),
      playerWins: json['playerWins'] as int? ?? 0,
      aiWins: json['aiWins'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  /// Converts PersistedGameState to JSON
  Map<String, dynamic> toJson() {
    return {
      'gameState': gameState.toJson(),
      'playerWins': playerWins,
      'aiWins': aiWins,
      'draws': draws,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this state with modified values
  PersistedGameState copyWith({
    GameState? gameState,
    int? playerWins,
    int? aiWins,
    int? draws,
    DateTime? savedAt,
  }) {
    return PersistedGameState(
      gameState: gameState ?? this.gameState,
      playerWins: playerWins ?? this.playerWins,
      aiWins: aiWins ?? this.aiWins,
      draws: draws ?? this.draws,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  List<Object?> get props => [gameState, playerWins, aiWins, draws, savedAt];
}
