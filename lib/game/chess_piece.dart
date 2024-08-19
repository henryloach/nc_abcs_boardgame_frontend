import 'package:nc_abcs_boardgame_frontend/game/rules.dart';

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

Set<(int, int)> getLegalMoves(List<List<ChessPiece?>> board, (int, int) square) {
  final ChessPiece? piece = board[square.$1][square.$2];

  Set<(int, int)> seek(
    (int, int) direction,
    bool canRepeat,
    CaptureRule captureRule,
  ) {
    Set<(int, int)> resultSet = {};

    final int boardHeight = board.length;
    final int boardWidth = board[0].length;

    var y = square.$1;
    var x = square.$2;

    do {
      y = piece!.colour == PieceColour.white ? y - direction.$1 : y + direction.$1;
      x = x + direction.$2;

      if (y >= boardHeight || y < 0) break;
      if (x >= boardWidth || x < 0) break;

      final ChessPiece? targetPiece = board[y][x];

      if (captureRule == CaptureRule.captureOnly && targetPiece == null) break;
      if (captureRule == CaptureRule.moveOnly && targetPiece != null) break;
      if (targetPiece != null && targetPiece.colour == piece.colour) break;

      resultSet.add((y, x));
    } while (canRepeat);

    return resultSet;
  }

  if (piece == null) {
    return {};
  }

  Set<(int, int)> legalMoves = {};

  moveRuleMap[piece.type].forEach((moveRule) {
    legalMoves = {
      ...legalMoves,
      ...seek(moveRule[0], moveRule[1], moveRule[2])
    };
  });

  return legalMoves;
}


