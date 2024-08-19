class ChessPiece {
  final PieceType type;
  final PieceColour colour;

  const ChessPiece(this.type, this.colour);
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
