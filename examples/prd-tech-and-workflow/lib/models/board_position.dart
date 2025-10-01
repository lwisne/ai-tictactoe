import 'package:equatable/equatable.dart';

/// Represents a position on the tic-tac-toe board (0-8)
class BoardPosition extends Equatable {
  final int index;

  const BoardPosition(this.index) : assert(index >= 0 && index < 9);

  /// Returns the row number (0-2)
  int get row => index ~/ 3;

  /// Returns the column number (0-2)
  int get col => index % 3;

  /// Creates a position from row and column
  factory BoardPosition.fromRowCol(int row, int col) {
    assert(row >= 0 && row < 3);
    assert(col >= 0 && col < 3);
    return BoardPosition(row * 3 + col);
  }

  @override
  List<Object?> get props => [index];

  @override
  String toString() => 'BoardPosition($index: row=$row, col=$col)';
}
