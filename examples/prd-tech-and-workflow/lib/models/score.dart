import 'package:equatable/equatable.dart';

/// Score tracking for wins, losses, and draws
class Score extends Equatable {
  final int xWins;
  final int oWins;
  final int draws;

  const Score({
    required this.xWins,
    required this.oWins,
    required this.draws,
  });

  factory Score.empty() {
    return const Score(xWins: 0, oWins: 0, draws: 0);
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      xWins: json['xWins'] as int? ?? 0,
      oWins: json['oWins'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xWins': xWins,
      'oWins': oWins,
      'draws': draws,
    };
  }

  Score copyWith({
    int? xWins,
    int? oWins,
    int? draws,
  }) {
    return Score(
      xWins: xWins ?? this.xWins,
      oWins: oWins ?? this.oWins,
      draws: draws ?? this.draws,
    );
  }

  int get totalGames => xWins + oWins + draws;

  @override
  List<Object?> get props => [xWins, oWins, draws];
}
