import 'package:nc_abcs_boardgame_frontend/utils/utils.dart';
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

        expect(game.getLegalMoves((7, 1)), whiteQueensideKnightMoves);
        expect(game.getLegalMoves((7, 6)), whiteKingsideKnightMoves);
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
      test("pawn can't move if it's pinned", () {
        final game = Game(fenString: "7q/8/8/8/8/8/1P6/K7 w - - 0 1");

        Set expectedResult = {};

        expect(game.getLegalMoves((6, 1)), expectedResult);
      });
    });
  });

  group("movePiece()", () {
    test("e4", () {
      final game = Game();

      final expectedPosition = decodeFEN(
          "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1");

      game.movePiece((6, 4), (4, 4));

      expect(game.board, expectedPosition);
    });

    test("e4 e5", () {
      final game = Game();

      final expectedPosition = decodeFEN(
          "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2");

      game.movePiece((6, 4), (4, 4));
      game.movePiece((1, 4), (3, 4));

      expect(game.board, expectedPosition);
    });
  });

  group("testForChecks()", () {
    test("king attacked by one piece", () {
      final game = Game(fenString: "7q/8/8/8/8/8/8/K7 w - - 0 1");

      const expectedResult = {
        (0, 7),
      };

      expect(game.testBoardForChecks(), expectedResult);
    });
    test("king attacked by miltiple pieces", () {
      final game = Game(fenString: "q6q/8/8/8/8/8/8/K6q w - - 0 1");

      const expectedResult = {
        (0, 0),
        (0, 7),
        (7, 7),
      };

      expect(game.testBoardForChecks(), expectedResult);
    });
  });

  group("testMoveForOpposingChecks", () {
    test("board is the same after the function runs", () {
      final game = Game(fenString: "6q1/8/8/8/8/8/1P6/K7 w - - 0 1");

      final expectedBoard = decodeFEN("6q1/8/8/8/8/8/1P6/K7 w - - 0 1");

      game.testMoveForOpposingChecks((7, 0), (6, 0));

      expect(game.board, expectedBoard);
    });

    test("returns true for king attempting to move into check", () {
      final game = Game(fenString: "6q1/8/8/8/8/8/1P6/K7 w - - 0 1");

      expect(game.testMoveForOpposingChecks((7, 0), (6, 0)), true);
    });

    test("returns true for pinned pawn attempting to advance", () {
      final game = Game(fenString: "7q/8/8/8/8/8/1P6/K7 w - - 0 1");

      expect(game.testMoveForOpposingChecks((6, 1), (5, 1)), true);
    });

    test("returns false for bishop moving along the line of pin", () {
      final game = Game(fenString: "7q/8/8/8/8/8/1B6/K7 w - - 0 1");

      expect(game.testMoveForOpposingChecks((6, 1), (4, 3)), false);
    });

    test("doesn't prevent own discovered check", () {
      final game = Game(fenString: "3kq3/8/8/8/8/8/3K4/3Q4 w - - 0 1");

      expect(game.testMoveForOpposingChecks((6, 3), (6, 2)), false);
    });

    test("doesn't prevent attcking opponents king", () {
      final game = Game(
          fenString:
              "rnbqkbnr/pppp1ppp/8/4p3/4PP2/8/PPPP2PP/RNBQKBNR w KQkq - 0 1");

      expect(game.testMoveForOpposingChecks((0, 3), (4, 7)), false);
    });
  });

  group("testForWinCondition()", () {
    test("back rank-checkmate", () {
      final game = Game(fenString: "k3q3/8/8/8/8/8/PPP5/K7 b - - 0 1");
      game.movePiece((0, 4), (7, 4));
      expect(game.gameState, GameState.blackWin);
    });

    test("problem position from emulator test", () {
      final game = Game(
          fenString:
              "r1bqk1nr/p2nbppp/1p6/1Bp1P3/4PP2/6P1/P2B3P/R2QK2R w - - 0 1");
      game.movePiece((3, 1), (3, 1));
      expect(game.gameState, GameState.blackToMove);
    });

    test("stalemate", () {
      final game = Game(fenString: "7r/8/8/8/8/8/7r/K7 b - - 0 1");

      game.movePiece((0,7),(0,1));

      expect(game.gameState, GameState.draw);
    });
  });

  group("isActivePlayerInCheck()", () {
    test("returns true if in check", () {
      final game = Game(fenString: "3kq3/8/8/8/8/8/8/4K3 w - - 0 1");

      expect(game.isActivePlayerInCheck(), true);
    });
    test("returns false if not in check", () {
      final game = Game();

      expect(game.isActivePlayerInCheck(), false);
    });
  });

  group("getAllActivePlayerLegalMoves()", () {
    test("white's starting position legal moves", () {
      final game = Game();

      const expectedResult = {
        (5, 0),
        (5, 1),
        (5, 2),
        (5, 3),
        (5, 4),
        (5, 5),
        (5, 6),
        (5, 7),
        (4, 0),
        (4, 1),
        (4, 2),
        (4, 3),
        (4, 4),
        (4, 5),
        (4, 6),
        (4, 7),
      };

      expect(game.getAllActivePlayerLegalMoves(), expectedResult);
    });
  });
}
