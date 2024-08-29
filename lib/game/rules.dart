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

enum GameVariant {
  normal,
  edgeWrap,
  horde,
  endgame
}

const Map gameVariantFenMap = {
  GameVariant.normal: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
  GameVariant.edgeWrap: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
  GameVariant.horde : "rnbqkbnr/pppppppp/8/8/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP b kq - 0 1",
  GameVariant.endgame : "4k3/pppppppp/8/8/8/8/PPPPPPPP/4K3 w - - 0 1",
};

const Map gameVariantNameMap = {
  GameVariant.normal: 'Standard',
  GameVariant.edgeWrap: 'Edge Wrap',
  GameVariant.horde : 'Horde',
  GameVariant.endgame : 'Endgame',
};