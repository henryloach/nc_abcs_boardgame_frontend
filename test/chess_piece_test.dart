import 'package:test/test.dart';

import 'package:nc_abcs_boardgame_frontend/utils/utils.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';

void main() {
  group("getLegalMoves()", () {
    group("Empty Board", () {
      test("legal moves for an empty square is the empty set", () {
        final board = decodeFEN("8/8/8/8/8/8/8/8 w - - 0 1");

        const Set<(int, int)> expectedResult = {};

        expect(getLegalMoves(board, (3, 3)), expectedResult);
      });
    });

    group("Single piece", () {
      test("King on d5", () {
        final board = decodeFEN("8/8/8/3K4/8/8/8/8 w - - 0 1");

        final expectedResult = {
          (2, 2),
          (2, 3),
          (2, 4),
          (3, 2),
          (3, 4),
          (4, 2),
          (4, 3),
          (4, 4),
        };

        expect(getLegalMoves(board, (3, 3)), expectedResult);
      });

      test("White queen on d1", () {
        final board = decodeFEN("8/8/8/8/8/8/8/3Q4 w - - 0 1");

        final expectedResult = {
          //
          (6, 3),
          (5, 3),
          (4, 3),
          (3, 3),
          (2, 3),
          (1, 3),
          (0, 3),
          //
          (7, 0),
          (7, 1),
          (7, 2),
          (7, 4),
          (7, 5),
          (7, 6),
          (7, 7),
          //
          (6, 2),
          (5, 1),
          (4, 0),
          //
          (6, 4),
          (5, 5),
          (4, 6),
          (3, 7),
        };

        expect(getLegalMoves(board, (7, 3)), expectedResult);
      });

      test("White bishop on f1", () {
        final board = decodeFEN("8/8/8/8/8/8/8/5B2 w - - 0 1");

        final expectedResult = {
          (6, 4),
          (5, 3),
          (4, 2),
          (3, 1),
          (2, 0),
          //
          (6, 6),
          (5, 7),
        };

        expect(getLegalMoves(board, (7, 5)), expectedResult);
      });

      test("White knight on f5", () {
        final board = decodeFEN("8/8/8/5N2/8/8/8/8 w - - 0 1");

        final expectedResult = {
          (1, 4),
          (1, 6),
          (2, 3),
          (2, 7),
          (4, 3),
          (4, 7),
          (5, 4),
          (5, 6),
        };

        expect(getLegalMoves(board, (3, 5)), expectedResult);
      });

      test("Black rook on a8", () {
        final board = decodeFEN("r7/8/8/8/8/8/8/8 b - - 0 1");

        final expectedResult = {
          (0, 1),
          (0, 2),
          (0, 3),
          (0, 4),
          (0, 5),
          (0, 6),
          (0, 7),
          //
          (1, 0),
          (2, 0),
          (3, 0),
          (4, 0),
          (5, 0),
          (6, 0),
          (7, 0),
        };

        expect(getLegalMoves(board, (0, 0)), expectedResult);
      });

      test("White pawn on a2", () {
        final board = decodeFEN("8/8/8/8/8/8/P7/8 w - - 0 1");

        final expectedResult = {
          (5, 0),
          (4, 0),
        };

        expect(getLegalMoves(board, (6, 0)), expectedResult);
      });

      test("Black pawn on a7", () {
        final board = decodeFEN("8/p7/8/8/8/8/8/8 b - - 0 1");

        final expectedResult = {
          (2, 0),
          (3, 0),
        };

        expect(getLegalMoves(board, (1, 0)), expectedResult);
      });

      test("Pawns can capture diagonaly", () {
        final board = decodeFEN("8/8/8/2n1b3/3P4/8/8/8 w - - 0 1");

        board[4][3]!.hasMoved = true;

        final expectedResult = {
          (3, 2),
          (3, 3),
          (3, 4),
        };

        expect(getLegalMoves(board, (4, 3)), expectedResult);
      });

      test("Pawns cannot capture an oposing piece directly in front of them",
          () {
        final board = decodeFEN("8/8/8/2nrb3/3P4/8/8/8 w - - 0 1");

        final expectedResult = {
          (3, 2),
          (3, 4),
        };

        expect(getLegalMoves(board, (4, 3)), expectedResult);
      });

      test("Pawns cannot capture using inital double move", () {
        final board = decodeFEN("8/8/8/8/p7/8/P7/8 w - - 0 1");

        final expectedResult = {
          (5, 0),
        };

        expect(getLegalMoves(board, (6, 0)), expectedResult);
      });
    });

    group("Piece blocking", () {
      test(
          "In the starting position pieces non-pawns and non-knights have no legal moves",
          () {
        final board = decodeFEN(
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");

        const Set<(int, int)> expectedResult = {};

        // black
        expect(getLegalMoves(board, (0, 0)), expectedResult);
        expect(getLegalMoves(board, (0, 2)), expectedResult);
        expect(getLegalMoves(board, (0, 3)), expectedResult);
        expect(getLegalMoves(board, (0, 4)), expectedResult);
        expect(getLegalMoves(board, (0, 5)), expectedResult);
        expect(getLegalMoves(board, (0, 7)), expectedResult);

        // white
        expect(getLegalMoves(board, (7, 0)), expectedResult);
        expect(getLegalMoves(board, (7, 2)), expectedResult);
        expect(getLegalMoves(board, (7, 3)), expectedResult);
        expect(getLegalMoves(board, (7, 4)), expectedResult);
        expect(getLegalMoves(board, (7, 5)), expectedResult);
        expect(getLegalMoves(board, (7, 7)), expectedResult);
      });

      test("In the starting position only pawns and knights have legal moves",
          () {
        final board = decodeFEN(
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");

        const Set<(int, int)> whiteQueensideKnightMoves = {(5, 0), (5, 2)};
        const Set<(int, int)> whiteKingsideKnightMoves = {(5, 5), (5, 7)};
        const Set<(int, int)> blackQueensideKnightMoves = {(2, 0), (2, 2)};
        const Set<(int, int)> blackKingsideKnightMoves = {(2, 5), (2, 7)};

        expect(getLegalMoves(board, (7, 1)), whiteQueensideKnightMoves);
        expect(getLegalMoves(board, (7, 6)), whiteKingsideKnightMoves);
        expect(getLegalMoves(board, (0, 1)), blackQueensideKnightMoves);
        expect(getLegalMoves(board, (0, 6)), blackKingsideKnightMoves);
      });

      test(
          "Sliding pieces may only capture first openent piece in direction of movement",
          () {
        final board = decodeFEN("p7/1p6/2p5/3p4/4p3/5p2/8/7B w - - 0 1");

        const expectedResult = {
          (6, 6),
          (5, 5),
        };

        expect(getLegalMoves(board, (7, 7)), expectedResult);
      });
    });
  });
}
