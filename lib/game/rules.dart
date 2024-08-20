import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';

enum CaptureRule { captureOnly, moveOnly, both }

const Map moveRuleMap = {
  PieceType.king: [
    [(0, 1), false, CaptureRule.both],
    [(0, -1), false, CaptureRule.both],
    [(1, 0), false, CaptureRule.both],
    [(1, 1), false, CaptureRule.both],
    [(1, -1), false, CaptureRule.both],
    [(-1, 0), false, CaptureRule.both],
    [(-1, 1), false, CaptureRule.both],
    [(-1, -1), false, CaptureRule.both],
  ],
  PieceType.queen: [
    [(0, 1), true, CaptureRule.both],
    [(0, -1), true, CaptureRule.both],
    [(1, 0), true, CaptureRule.both],
    [(1, 1), true, CaptureRule.both],
    [(1, -1), true, CaptureRule.both],
    [(-1, 0), true, CaptureRule.both],
    [(-1, 1), true, CaptureRule.both],
    [(-1, -1), true, CaptureRule.both],
  ],
  PieceType.bishop: [
    [(1, 1), true, CaptureRule.both],
    [(1, -1), true, CaptureRule.both],
    [(-1, 1), true, CaptureRule.both],
    [(-1, -1), true, CaptureRule.both],
  ],
  PieceType.knight: [
    [(1, 2), false, CaptureRule.both],
    [(1, -2), false, CaptureRule.both],
    [(2, 1), false, CaptureRule.both],
    [(2, -1), false, CaptureRule.both],
    [(-1, 2), false, CaptureRule.both],
    [(-1, -2), false, CaptureRule.both],
    [(-2, 1), false, CaptureRule.both],
    [(-2, -1), false, CaptureRule.both],
  ],
  PieceType.rook: [
    [(0, 1), true, CaptureRule.both],
    [(0, -1), true, CaptureRule.both],
    [(1, 0), true, CaptureRule.both],
    [(-1, 0), true, CaptureRule.both],
  ],
  PieceType.pawn: [
    [(1, 0), false, CaptureRule.moveOnly],
    [(1, 1), false, CaptureRule.captureOnly],
    [(1, -1), false, CaptureRule.captureOnly],
  ]
};