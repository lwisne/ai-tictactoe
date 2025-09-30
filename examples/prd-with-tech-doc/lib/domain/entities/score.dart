import 'package:equatable/equatable.dart';

class Score extends Equatable {
  final int wins;
  final int losses;
  final int draws;

  const Score({
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
  });

  int get totalGames => wins + losses + draws;

  double get winRate => totalGames > 0 ? wins / totalGames : 0.0;

  Score copyWith({
    int? wins,
    int? losses,
    int? draws,
  }) {
    return Score(
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
    );
  }

  @override
  List<Object?> get props => [wins, losses, draws];
}
