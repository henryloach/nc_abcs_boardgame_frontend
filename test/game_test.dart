import 'package:test/test.dart';

import 'package:nc_abcs_boardgame_frontend/game/game.dart';

void main() {
  group("getLegalMoves()", () {
    group("Empty Board", () {
      test("legal moves for an empty square is the empty set", () {
        final game = Game(fenString: "8/8/8/8/8/8/8/8 w - - 0 1");

        const Set<(int, int)> expectedResult = {};

        expect(game.getLegalMoves((3, 3)), expectedResult);
      });
    });

    group("Single piece", () {
      test("King on d5", () {
        final game = Game(fenString: "8/8/8/3K4/8/8/8/8 w - - 0 1");

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

        expect(game.getLegalMoves((3, 3)), expectedResult);
      });

      test("White queen on d1", () {
        final game = Game(fenString: "8/8/8/8/8/8/8/3Q4 w - - 0 1");

        final expectedResult = {
          (6, 3),
          (5, 3),
          (4, 3),
          (3, 3),
          (2, 3),
          (1, 3),
          (0, 3),
          (7, 0),
          (7, 1),
          (7, 2),
          (7, 4),
          (7, 5),
          (7, 6),
          (7, 7),
          (6, 2),
          (5, 1),
          (4, 0),
          (6, 4),
          (5, 5),
          (4, 6),
          (3, 7),
        };

        expect(game.getLegalMoves((7, 3)), expectedResult);
      });

      test("White bishop on f1", () {
        final game = Game(fenString: "8/8/8/8/8/8/8/5B2 w - - 0 1");

        final expectedResult = {
          (6, 4),
          (5, 3),
          (4, 2),
          (3, 1),
          (2, 0),
          (6, 6),
          (5, 7),
        };

        expect(game.getLegalMoves((7, 5)), expectedResult);
      });

      test("White knight on f5", () {
        final game = Game(fenString: "8/8/8/5N2/8/8/8/8 w - - 0 1");

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

        expect(game.getLegalMoves((3, 5)), expectedResult);
      });

      test("Black rook on a8", () {
        final game = Game(fenString: "r7/8/8/8/8/8/8/8 b - - 0 1");

        final expectedResult = {
          (0, 1),
          (0, 2),
          (0, 3),
          (0, 4),
          (0, 5),
          (0, 6),
          (0, 7),
          (1, 0),
          (2, 0),
          (3, 0),
          (4, 0),
          (5, 0),
          (6, 0),
          (7, 0),
        };

        expect(game.getLegalMoves((0, 0)), expectedResult);
      });

      test("White pawn on a2", () {
        final game = Game(fenString: "8/8/8/8/8/8/P7/8 w - - 0 1");

        final expectedResult = {
          (5, 0),
          (4, 0),
        };

        expect(game.getLegalMoves((6, 0)), expectedResult);
      });

      test("Black pawn on a7", () {
        final game = Game(fenString: "8/p7/8/8/8/8/8/8 b - - 0 1");

        final expectedResult = {
          (2, 0),
          (3, 0),
        };

        expect(game.getLegalMoves((1, 0)), expectedResult);
      });

      test("Pawns can capture diagonally", () {
        final game = Game(fenString: "8/8/8/2n1b3/3P4/8/8/8 w - - 0 1");

        game.board[4][3]!.hasMoved = true;

        final expectedResult = {
          (3, 2),
          (3, 3),
          (3, 4),
        };

        expect(game.getLegalMoves((4, 3)), expectedResult);
      });

      test("Pawns cannot capture an opposing piece directly in front of them",
          () {
        final game = Game(fenString: "8/8/8/2nrb3/3P4/8/8/8 w - - 0 1");

        final expectedResult = {
          (3, 2),
          (3, 4),
        };

        expect(game.getLegalMoves((4, 3)), expectedResult);
      });

      test("Pawns cannot capture using initial double move", () {
        final game = Game(fenString: "8/8/8/8/p7/8/P7/8 w - - 0 1");

        final expectedResult = {
          (5, 0),
        };

        expect(game.getLegalMoves((6, 0)), expectedResult);
      });
    });

    group("Piece blocking", () {
      test(
          "In the starting position, non-pawns and non-knights have no legal moves",
          () {
        final game = Game(
            fenString:
                "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");

        const Set<(int, int)> expectedResult = {};

        // black
        expect(game.getLegalMoves((0, 0)), expectedResult);
        expect(game.getLegalMoves((0, 2)), expectedResult);
        expect(game.getLegalMoves((0, 3)), expectedResult);
        expect(game.getLegalMoves((0, 4)), expectedResult);
        expect(game.getLegalMoves((0, 5)), expectedResult);
        expect(game.getLegalMoves((0, 7)), expectedResult);

        // white
        expect(game.getLegalMoves((7, 0)), expectedResult);
        expect(game.getLegalMoves((7, 2)), expectedResult);
        expect(game.getLegalMoves((7, 3)), expectedResult);
        expect(game.getLegalMoves((7, 4)), expectedResult);
        expect(game.getLegalMoves((7, 5)), expectedResult);
        expect(game.getLegalMoves((7, 7)), expectedResult);
      });

      test("In the starting position only pawns and knights have legal moves",
          () {
        final game = Game(
            fenString:
                "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");

        const Set<(int, int)> whiteQueensideKnightMoves = {(5, 0), (5, 2)};
        const Set<(int, int)> whiteKingsideKnightMoves = {(5, 5), (5, 7)};
        const Set<(int, int)> blackQueensideKnightMoves = {(2, 0), (2, 2)};
        const Set<(int, int)> blackKingsideKnightMoves = {(2, 5), (2, 7)};

        expect(game.getLegalMoves((7, 1)), whiteQueensideKnightMoves);
        expect(game.getLegalMoves((7, 6)), whiteKingsideKnightMoves);
        expect(game.getLegalMoves((0, 1)), blackQueensideKnightMoves);
        expect(game.getLegalMoves((0, 6)), blackKingsideKnightMoves);
      });

      test(
          "Sliding pieces may only capture the first opponent piece in the direction of movement",
          () {
        final game = Game(fenString: "p7/1p6/2p5/3p4/4p3/5p2/8/7B w - - 0 1");

        const expectedResult = {
          (6, 6),
          (5, 5),
        };

        expect(game.getLegalMoves((7, 7)), expectedResult);
      });
    });
  });
}