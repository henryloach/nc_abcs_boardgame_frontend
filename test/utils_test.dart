import 'package:test/test.dart';

import 'package:nc_abcs_boardgame_frontend/utils/utils.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';

void main() {
  group("decodeFEN()", () {
    test(
        "the fen string for an empty 8x8 boards return an 8x8 2D array of nulls.",
        () {
      const inputString = "8/8/8/8/8/8/8/8 w - - 0 1";
      const expectedResult = [
        [null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null]
      ];

      expect(decodeFEN(inputString), expectedResult);
    });

    test("starting position", () {
      const inputString =
          "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

      final List<List<ChessPiece?>> expectedResult = [
        [
          ChessPiece(PieceType.rook, PieceColour.black),
          ChessPiece(PieceType.knight, PieceColour.black),
          ChessPiece(PieceType.bishop, PieceColour.black),
          ChessPiece(PieceType.queen, PieceColour.black),
          ChessPiece(PieceType.king, PieceColour.black),
          ChessPiece(PieceType.bishop, PieceColour.black),
          ChessPiece(PieceType.knight, PieceColour.black),
          ChessPiece(PieceType.rook, PieceColour.black)
        ],
        [
          ChessPiece(PieceType.pawn, PieceColour.black),
          ChessPiece(PieceType.pawn, PieceColour.black),
          ChessPiece(PieceType.pawn, PieceColour.black),
          ChessPiece(PieceType.pawn, PieceColour.black),
          ChessPiece(PieceType.pawn, PieceColour.black),
          ChessPiece(PieceType.pawn, PieceColour.black),
          ChessPiece(PieceType.pawn, PieceColour.black),
          ChessPiece(PieceType.pawn, PieceColour.black)
        ],
        [null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null],
        [
          ChessPiece(PieceType.pawn, PieceColour.white),
          ChessPiece(PieceType.pawn, PieceColour.white),
          ChessPiece(PieceType.pawn, PieceColour.white),
          ChessPiece(PieceType.pawn, PieceColour.white),
          ChessPiece(PieceType.pawn, PieceColour.white),
          ChessPiece(PieceType.pawn, PieceColour.white),
          ChessPiece(PieceType.pawn, PieceColour.white),
          ChessPiece(PieceType.pawn, PieceColour.white)
        ],
        [
          ChessPiece(PieceType.rook, PieceColour.white),
          ChessPiece(PieceType.knight, PieceColour.white),
          ChessPiece(PieceType.bishop, PieceColour.white),
          ChessPiece(PieceType.queen, PieceColour.white),
          ChessPiece(PieceType.king, PieceColour.white),
          ChessPiece(PieceType.bishop, PieceColour.white),
          ChessPiece(PieceType.knight, PieceColour.white),
          ChessPiece(PieceType.rook, PieceColour.white)
        ]
      ];

      expect(decodeFEN(inputString), expectedResult);
    });
  });

  group("recordToAlphanumeric()", () {
    test("8x8 board", () {
      expect(recordToAlphanumeric((0, 0), 8, 8), "A8");
      expect(recordToAlphanumeric((0, 7), 8, 8), "H8");
      expect(recordToAlphanumeric((7, 0), 8, 8), "A1");
      expect(recordToAlphanumeric((7, 7), 8, 8), "H1");
    });

    test("extended board", () {
      expect(recordToAlphanumeric((0, 0), 8, 16), "A8");
      expect(recordToAlphanumeric((0, 7), 8, 16), "H8");
      expect(recordToAlphanumeric((0, 15), 8, 16), "P8");
      expect(recordToAlphanumeric((7, 0), 8, 16), "A1");
      expect(recordToAlphanumeric((7, 7), 8, 16), "H1");
      expect(recordToAlphanumeric((7, 15), 8, 16), "P1");

      expect(recordToAlphanumeric((0, 0), 10, 10), "A10");
      expect(recordToAlphanumeric((9, 9), 10, 10), "J1");

      expect(recordToAlphanumeric((0,0), 3, 3), "A3");
    });
  });
}
