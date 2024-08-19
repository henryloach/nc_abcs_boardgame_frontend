class ChessPiece {
  final PieceType type;
  final PieceColour colour;

  const ChessPiece(this.type, this.colour);
}

class Square {
  final int row;
  final int column;

  const Square(this.row, this.column);

  @override
  bool operator ==(Object other) {
    //if (identical(this, other)) return true;
    if (other is! Square) return false;
    return other.row == row && other.column == column;
  }

  @override
  int get hashCode => row.hashCode ^ column.hashCode;
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

enum CaptureRule { captureOnly, moveOnly, both }

Set<Square> getLegalMoves(List<List<ChessPiece?>> board, Square square) {
  final ChessPiece? piece = board[square.row][square.column];

  Set<Square> seek(
    int dy,
    int dx,
    bool canRepeat,
    CaptureRule captureRule,
  ) {
    Set<Square> resultSet = {};

    final int boardHeight = board.length;
    final int boardWidth = board[0].length;

    var y = square.row;
    var x = square.column;

    do {
      y = piece!.colour == PieceColour.white ? y - dy : y + dy;
      x = x + dx;

      if (y >= boardHeight || y < 0) break;
      if (x >= boardWidth || x < 0) break;

      final ChessPiece? targetPiece = board[y][x];

      if (captureRule == CaptureRule.captureOnly && targetPiece == null) break;
      if (captureRule == CaptureRule.moveOnly && targetPiece != null) break;
      if (targetPiece != null && targetPiece.colour == piece.colour) break;

      resultSet.add(Square(y, x));
    } while (canRepeat);

    return resultSet;
  }

  if (piece == null) {
    return {};
  }

  Set<Square> legalMoves = {};

  moveRuleMap[piece.type].forEach((moveRule) {
    legalMoves = {
      ...legalMoves,
      ...seek(moveRule[0], moveRule[1], moveRule[2], moveRule[3])
    };
  });

  return legalMoves;
}

Map moveRuleMap = {
  PieceType.king: [
    [0, 1, false, CaptureRule.both],
    [0, -1, false, CaptureRule.both],
    [1, 0, false, CaptureRule.both],
    [1, 1, false, CaptureRule.both],
    [1, -1, false, CaptureRule.both],
    [-1, 0, false, CaptureRule.both],
    [-1, 1, false, CaptureRule.both],
    [-1, -1, false, CaptureRule.both],
  ],
  PieceType.queen: [
    [0, 1, true, CaptureRule.both],
    [0, -1, true, CaptureRule.both],
    [1, 0, true, CaptureRule.both],
    [1, 1, true, CaptureRule.both],
    [1, -1, true, CaptureRule.both],
    [-1, 0, true, CaptureRule.both],
    [-1, 1, true, CaptureRule.both],
    [-1, -1, true, CaptureRule.both],
  ],
  PieceType.bishop: [
    [1, 1, true, CaptureRule.both],
    [1, -1, true, CaptureRule.both],
    [-1, 1, true, CaptureRule.both],
    [-1, -1, true, CaptureRule.both],
  ],
  PieceType.knight: [
    [1, 2, false, CaptureRule.both],
    [1, -2, false, CaptureRule.both],
    [2, 1, false, CaptureRule.both],
    [2, -1, false, CaptureRule.both],
    [-1, 2, false, CaptureRule.both],
    [-1, -2, false, CaptureRule.both],
    [-2, 1, false, CaptureRule.both],
    [-2, -1, false, CaptureRule.both],
  ],
  PieceType.rook: [
    [0, 1, true, CaptureRule.both],
    [0, -1, true, CaptureRule.both],
    [1, 0, true, CaptureRule.both],
    [-1, 0, true, CaptureRule.both],
  ],
  PieceType.pawn: [
    [1, 0, false, CaptureRule.moveOnly],
    [1, 1, false, CaptureRule.captureOnly],
    [1, -1, false, CaptureRule.captureOnly],
  ]
};
