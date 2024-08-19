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

Set<(int, int)> getLegalMoves(
    List<List<ChessPiece?>> board, (int, int) square) {
  final ChessPiece? piece = board[square.$1][square.$2];

  Set<(int, int)> seek(
    (int, int) direction,
    bool canRepeat,
    CaptureRule captureRule,
  ) {
    Set<(int, int)> resultSet = {};

    final int boardHeight = board.length;
    final int boardWidth = board[0].length;

    var (y, x) = square;
    var (dy, dx) = direction;

    if (piece!.colour == PieceColour.white) dy = -dy;

    do {
      y = y + dy;
      x = x + dx;

      if (y >= boardHeight || y < 0) break;
      if (x >= boardWidth || x < 0) break;

      final ChessPiece? targetPiece = board[y][x];

      if (targetPiece != null) {
        if (targetPiece.colour == piece.colour) break;
        if (captureRule == CaptureRule.moveOnly) break;

        resultSet.add((y, x));

        break;
      } else {
        if (captureRule == CaptureRule.captureOnly) break;

        resultSet.add((y, x));

        if (piece.type == PieceType.pawn &&
            piece.hasMoved == false &&
            board[y + dy][x + dx] == null) {
          resultSet.add((y + dy, x + dx));
        }
      }
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