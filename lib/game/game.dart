import 'package:nc_abcs_boardgame_frontend/utils/utils.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';
import 'package:nc_abcs_boardgame_frontend/game/rules.dart';

class Game {
  // Use list for maybe adding more players in future
  // TODO maybe make a player class
  List<String> players = ["player1", "player2"];

  List<List<ChessPiece?>> board;
  List<ChessPiece> capturedPieces = [];

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

  void movePiece((int, int) start, (int, int) end) {
    final (startRow, startColumn) = start;
    final (endRow, endColumn) = end;
    if (board[endRow][endColumn] != null) {
      capturedPieces.add(board[endRow][endColumn]!);
    }

    board[startRow][startColumn]!.hasMoved = true;
    board[endRow][endColumn] = board[startRow][startColumn];
    board[startRow][startColumn] = null;
  }

  Set<(int, int)> getLegalMoves((int, int) square) {
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
}
