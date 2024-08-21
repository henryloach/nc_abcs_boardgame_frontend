import 'package:nc_abcs_boardgame_frontend/components/game_screen.dart';
import 'package:nc_abcs_boardgame_frontend/utils/utils.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';
import 'package:nc_abcs_boardgame_frontend/game/rules.dart';

class Game {
  // Use list for maybe adding more players in future
  // TODO maybe make a player class
  List<String> players = ["player1", "player2"];

  List<List<ChessPiece?>> board;
  List<ChessPiece> capturedPieces = [];

  GameState gameState = GameState.whiteToMove;

  Set<(int, int)> checks = {};

  // Constructor with an optional named parameter for the FEN string
  Game(
      {String fenString =
          "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"})
      : board = decodeFEN(fenString); // this is an "initializer list"

  String getAssetPathAtSquare((int, int) square) {
    final (row, column) = square;
    final target = board[row][column];
    if (target == null) return "";
    return target.assetPath;
  }

  // safety of this function relies on args coming from legal move set.
  // This function has no restrictions on what can be moved where.
  void movePiece((int, int) moveFromSquare, (int, int) moveToSquare) {
    final (startRow, startColumn) = moveFromSquare;
    final (endRow, endColumn) = moveToSquare;
    final ChessPiece? piece = board[startRow][startColumn];
    final ChessPiece? target = board[endRow][endColumn];

    // capture opponent's (or maybe your own) piece at the end square if one's there;
    if (target != null) {
      capturedPieces.add(target);
    }

    // move selected piece to the end square;
    piece!.hasMoved = true;
    board[endRow][endColumn] = piece;
    board[startRow][startColumn] = null;

    checks = testBoardForChecks();

    if (gameState == GameState.whiteToMove) {
      gameState = GameState.blackToMove;
    } else if (gameState == GameState.blackToMove) {
      gameState = GameState.whiteToMove;
    }
  }

  Set<(int, int)> getLegalMoves((int, int) square, {bool testCheck = true}) {
    final (row, column) = square;
    final ChessPiece? piece = board[row][column];

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

          // pawn initial double-move
          if (piece.type == PieceType.pawn &&
              piece.hasMoved == false &&
              board[y + dy][x + dx] == null) {
            resultSet.add((y + dy, x + dx));
          }
        }
      } while (canRepeat);

      return resultSet;
    }

    if (piece == null ||
        (gameState == GameState.whiteToMove &&
            piece.colour == PieceColour.black) ||
        (gameState == GameState.blackToMove &&
            piece.colour == PieceColour.white)) {
      return {};
    }

    Set<(int, int)> legalMoves = {};

    moveRuleMap[piece.type].forEach((moveRule) {
      legalMoves = {
        ...legalMoves,
        ...seek(moveRule[0], moveRule[1], moveRule[2])
      };
    });

    if (testCheck) {
      legalMoves.removeWhere((targetSquare) {
        return testMoveForOpposingChecks(square, targetSquare);
      });
    }

    return legalMoves;
  }

  Set<(int, int)> testBoardForChecks() {
    Set<(int, int)> checks = {};
    for (var row = 0; row < board.length; row++) {
      for (var column = 0; column < board[0].length; column++) {
        final piece = board[row][column];
        final moves = getLegalMoves((row, column), testCheck: false);
        if (moves.any(
          (move) {
            final (y, x) = move;
            final target = board[y][x];
            return target != null &&
                target.type == PieceType.king &&
                target.colour != piece!.colour;
          },
        )) {
          checks.add((row, column));
        }
      }
    }
    return checks;
  }

  bool testMoveForOpposingChecks(
      (int, int) moveFromSquare, (int, int) moveToSquare) {
    final (startRow, startColumn) = moveFromSquare;
    final (endRow, endColumn) = moveToSquare;
    final piece = board[startRow][startColumn];
    final target = board[endRow][endColumn];

    // provisional move
    board[endRow][endColumn] = piece;
    board[startRow][startColumn] = null;

    final checks = testBoardForChecks();

    // remove this move
    checks.remove(moveToSquare);

    // restore position
    board[startRow][startColumn] = piece;
    board[endRow][endColumn] = target;

    return checks.any((check) {
      final checkingPiece = board[check.$1][check.$2];
      return checkingPiece!.colour != piece!.colour;
    });
  }
}

enum GameState { whiteToMove, blackToMove, whiteWin, blackWin, draw }


/*

  intially start with white's turn
  when white piece moves, change to black's turn
  when black piece moves, change to white's turn

*/