import 'package:equatable/equatable.dart';

/// State for game management
///
/// This is a placeholder implementation for the game BLoC.
/// Future tasks will expand this with actual game state such as:
/// - Board state (3x3 grid)
/// - Current player
/// - Game status (in progress, won, draw)
/// - Score tracking
class GameState extends Equatable {
  final bool isInitialized;
  final bool isLoading;

  const GameState({this.isInitialized = false, this.isLoading = false});

  GameState copyWith({bool? isInitialized, bool? isLoading}) {
    return GameState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [isInitialized, isLoading];
}
