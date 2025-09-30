import 'package:equatable/equatable.dart';

class Position extends Equatable {
  final int row;
  final int col;

  const Position({
    required this.row,
    required this.col,
  });

  @override
  List<Object?> get props => [row, col];

  @override
  String toString() => 'Position(row: $row, col: $col)';
}
