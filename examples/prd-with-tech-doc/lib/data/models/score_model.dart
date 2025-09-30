import '../../domain/entities/score.dart';

/// Data Transfer Object for Score persistence
///
/// This model handles serialization/deserialization between
/// the persistence layer and domain entities.
class ScoreModel {
  final int wins;
  final int losses;
  final int draws;

  const ScoreModel({
    required this.wins,
    required this.losses,
    required this.draws,
  });

  /// Creates a ScoreModel from JSON
  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
    );
  }

  /// Converts ScoreModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'wins': wins,
      'losses': losses,
      'draws': draws,
    };
  }

  /// Creates a ScoreModel from a domain Score entity
  factory ScoreModel.fromEntity(Score score) {
    return ScoreModel(
      wins: score.wins,
      losses: score.losses,
      draws: score.draws,
    );
  }

  /// Converts ScoreModel to domain Score entity
  Score toEntity() {
    return Score(
      wins: wins,
      losses: losses,
      draws: draws,
    );
  }

  /// Creates an empty ScoreModel
  factory ScoreModel.empty() {
    return const ScoreModel(
      wins: 0,
      losses: 0,
      draws: 0,
    );
  }
}
