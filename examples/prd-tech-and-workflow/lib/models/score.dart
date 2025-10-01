/// Model representing game scores
class Score {
  final int xWins;
  final int oWins;
  final int draws;

  const Score({
    required this.xWins,
    required this.oWins,
    required this.draws,
  });

  /// Initial score with all counters at zero
  factory Score.initial() {
    return const Score(xWins: 0, oWins: 0, draws: 0);
  }

  /// Total games played
  int get totalGames => xWins + oWins + draws;

  /// Copy with updated values
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

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'xWins': xWins,
      'oWins': oWins,
      'draws': draws,
    };
  }

  /// JSON deserialization
  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      xWins: json['xWins'] as int,
      oWins: json['oWins'] as int,
      draws: json['draws'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Score &&
        other.xWins == xWins &&
        other.oWins == oWins &&
        other.draws == draws;
  }

  @override
  int get hashCode => Object.hash(xWins, oWins, draws);
}
