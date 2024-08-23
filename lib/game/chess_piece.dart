class ChessPiece {
  final PieceType type;
  final PieceColour colour;
  bool hasMoved = false;
  (int, int)? previousMove;

  ChessPiece(this.type, this.colour);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChessPiece) return false;
    return other.type == type && other.colour == colour;
  }

  @override
  int get hashCode => type.hashCode ^ colour.hashCode;

  String get assetPath {
    return "assets/svg/${colour.name}-${type.name}.svg";
  }
}

enum PieceType {
  king,
  queen,
  bishop,
  knight,
  rook,
  pawn,
}

enum PieceColour {
  black,
  white,
}
