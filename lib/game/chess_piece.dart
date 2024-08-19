class ChessPiece {
  final PieceType type;
  final PieceColour colour;
  bool hasMoved = false;

  ChessPiece(this.type, this.colour);
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