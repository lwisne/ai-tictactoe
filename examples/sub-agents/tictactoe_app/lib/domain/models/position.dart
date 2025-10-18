import 'package:equatable/equatable.dart';

/// Represents a position on the Tic-Tac-Toe board
///
/// A position is defined by a row and column, both ranging from 0 to 2
/// for a standard 3x3 Tic-Tac-Toe board.
///
/// This is a pure data model with no business logic.
class Position extends Equatable {
  /// Row index (0-2)
  final int row;

  /// Column index (0-2)
  final int col;

  const Position({required this.row, required this.col});

  /// Creates a Position from JSON
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(row: json['row'] as int, col: json['col'] as int);
  }

  /// Converts Position to JSON
  Map<String, dynamic> toJson() {
    return {'row': row, 'col': col};
  }

  @override
  List<Object?> get props => [row, col];

  @override
  String toString() => 'Position(row: $row, col: $col)';
}
