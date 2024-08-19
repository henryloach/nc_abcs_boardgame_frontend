import 'package:test/test.dart';

import 'package:nc_abcs_boardgame_frontend/utils/utils.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';

void main() {
  group("getLegalMoves()", () {
    group("Empty Board", () {
      test("legal moves for an eqmpty square is the empty set", () {
        final board = decodeFEN("8/8/8/8/8/8/8/8 w - - 0 1");

        const Set<Square> expectedResult = {};

        expect(getLegalMoves(board, const Square(3, 3)), expectedResult);
      });
    });

    group("Single piece", () {
      test("King on d5", () {
        final board = decodeFEN("8/8/8/3K4/8/8/8/8 w - - 0 1");

        final expectedResult = {
          const Square(2, 2),
          const Square(2, 3),
          const Square(2, 4),
          const Square(3, 2),
          const Square(3, 4),
          const Square(4, 2),
          const Square(4, 3),
          const Square(4, 4),
        };

        expect(getLegalMoves(board, const Square(3, 3)), expectedResult);
      });

      test("White queen on d1", () {
        final board = decodeFEN("8/8/8/8/8/8/8/3Q4 w - - 0 1");

        final expectedResult = {
          const Square(6, 3),
          const Square(5, 3),
          const Square(4, 3),
          const Square(3, 3),
          const Square(2, 3),
          const Square(1, 3),
          const Square(0, 3),
          //
          const Square(7, 0),
          const Square(7, 1),
          const Square(7, 2),
          const Square(7, 4),
          const Square(7, 5),
          const Square(7, 6),
          const Square(7, 7),
          //
          const Square(6, 2),
          const Square(5, 1),
          const Square(4, 0),
          //
          const Square(6, 4),
          const Square(5, 5),
          const Square(4, 6),
          const Square(3, 7),
        };

        expect(getLegalMoves(board, const Square(7, 3)), expectedResult);
      });

      test("White bishop on f1", () {
        final board = decodeFEN("8/8/8/8/8/8/8/5B2 w - - 0 1");

        final expectedResult = {
          const Square(6, 4),
          const Square(5, 3),
          const Square(4, 2),
          const Square(3, 1),
          const Square(2, 0),
          //
          const Square(6, 6),
          const Square(5, 7),
        };

        expect(getLegalMoves(board, const Square(7, 5)), expectedResult);
      });

      test("White knight on f5", () {
        final board = decodeFEN("8/8/8/5N2/8/8/8/8 w - - 0 1");

        final expectedResult = {
          const Square(1, 4),
          const Square(1, 6),
          const Square(2, 3),
          const Square(2, 7),
          const Square(4, 3),
          const Square(4, 7),
          const Square(5, 4),
          const Square(5, 6),
        };

        expect(getLegalMoves(board, const Square(3, 5)), expectedResult);
      });

      test("Black rook on a8", () {
        final board = decodeFEN("r7/8/8/8/8/8/8/8 b - - 0 1");

        final expectedResult = {
          const Square(0, 1),
          const Square(0, 2),
          const Square(0, 3),
          const Square(0, 4),
          const Square(0, 5),
          const Square(0, 6),
          const Square(0, 7),
          //
          const Square(1, 0),
          const Square(2, 0),
          const Square(3, 0),
          const Square(4, 0),
          const Square(5, 0),
          const Square(6, 0),
          const Square(7, 0),
        };

        expect(getLegalMoves(board, const Square(0, 0)), expectedResult);
      });

      test("White pawn on a2", () {
        final board = decodeFEN("8/8/8/8/8/8/P7/8 w - - 0 1");

        final expectedResult = {
          const Square(5, 0),
        };

        expect(getLegalMoves(board, const Square(6, 0)), expectedResult);
      });

      test("Black pawn on a7", () {
        final board = decodeFEN("8/p7/8/8/8/8/8/8 b - - 0 1");

        final expectedResult = {
          const Square(2, 0),
        };

        expect(getLegalMoves(board, const Square(1, 0)), expectedResult);
      });
    });

    group("Piece blocking", () {
      test("In the starting position no pieces but pawns and knights have legal moves", () {
        final board = decodeFEN(
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");

        const Set<Square> expectedResult = {};

        // black
        expect(getLegalMoves(board, const Square(0, 0)), expectedResult);
        expect(getLegalMoves(board, const Square(0, 2)), expectedResult);
        expect(getLegalMoves(board, const Square(0, 3)), expectedResult);
        expect(getLegalMoves(board, const Square(0, 4)), expectedResult);
        expect(getLegalMoves(board, const Square(0, 5)), expectedResult);
        expect(getLegalMoves(board, const Square(0, 7)), expectedResult);

        // white
        expect(getLegalMoves(board, const Square(7, 0)), expectedResult);
        expect(getLegalMoves(board, const Square(7, 2)), expectedResult);
        expect(getLegalMoves(board, const Square(7, 3)), expectedResult);
        expect(getLegalMoves(board, const Square(7, 4)), expectedResult);
        expect(getLegalMoves(board, const Square(7, 5)), expectedResult);
        expect(getLegalMoves(board, const Square(7, 7)), expectedResult);
      });
    });
  });
}
