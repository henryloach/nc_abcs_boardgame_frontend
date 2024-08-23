import 'package:nc_abcs_boardgame_frontend/utils/utils.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';
import 'package:nc_abcs_boardgame_frontend/game/rules.dart';

class Game {
  // Use list for maybe adding more players in future
  // TODO maybe make a player class
  // List<String> players = ["player1", "player2"];

  List<List<ChessPiece?>> board;
  List<ChessPiece> capturedPieces = [];
  // added this state for en-passant
  (int, int)? previousTo;

  GameState gameState = GameState.whiteToMove;

  // Constructor with an optional named parameter for the FEN string
  Game(
      {String fenString =
          "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"})
      : board = decodeFEN(fenString),
        gameState = fenString.split(" ")[1] == "w"
            ? GameState.whiteToMove
            : GameState.blackToMove; // this is an "initializer list"

  // get the path to the svg file
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

    final (int, int) move = (
      moveToSquare.$1 - moveFromSquare.$1,
      moveToSquare.$2 - moveFromSquare.$2
    );

    // capture opponent's (or maybe your own) piece at the end square if one's there;
    if (target != null) {
      capturedPieces.add(target);
    }

    // en-passant's capture
    if (piece!.type == PieceType.pawn && move.$2 != 0 && target == null) {
      final ChessPiece? left = board[moveFromSquare.$1][moveFromSquare.$2 - 1];
      final ChessPiece? right = board[moveFromSquare.$1][moveFromSquare.$2 + 1];

      if (left != null) {
        capturedPieces.add(left);
        board[moveFromSquare.$1][moveFromSquare.$2 - 1] = null;
      }

      if (right != null) {
        capturedPieces.add(right);
        board[moveFromSquare.$1][moveFromSquare.$2 + 1] = null;
      }
    }

    // move selected piece to the end square;
    piece.hasMoved = true;
    piece.previousMove = move;
    previousTo = moveToSquare;
    board[endRow][endColumn] = piece;
    board[startRow][startColumn] = null;

    //checks = testBoardForChecks();

    swapTurn();

    testForWinCondition();

    // check if pawn is at either first row or last row
    // clicking on the pawn opens a promotion menu: users can select to upgrade it to any other piece
    // upgrade pawn to the selected piece
  }

  bool canPromote((int, int) square) {
    final (row, column) = square;
    final ChessPiece? piece = board[row][column];
    if (piece?.type.name == "pawn" && (row == 0 || row == 7)) {
      return true;
    }
    return false;
  }

  void promotePawn(int y, int x, String promoteTo) {
    late PieceType type;
    late PieceColour colour;

    switch (promoteTo) {
      case "queen":
        type = PieceType.queen;
        break;
      case "bishop":
        type = PieceType.bishop;
        break;
      case "rook":
        type = PieceType.rook;
        break;
      case "knight":
        type = PieceType.knight;
        break;
    }

    final currentPiece = board[y][x];
    final player = currentPiece?.colour.name;

    switch (player) {
      case "white":
        colour = PieceColour.white;
        break;
      case "black":
        colour = PieceColour.black;
        break;
    }

    board[y][x] = ChessPiece(type, colour);
  }

  Set<(int, int)> getLegalMoves((int, int) square, {bool testCheck = true}) {
    // return no legal moves if the game is over
    if (gameState == GameState.whiteWin ||
        gameState == GameState.blackWin ||
        gameState == GameState.draw) {
      return {};
    }

    // get the piece from the board position
    final (row, column) = square;
    final ChessPiece? piece = board[row][column];

    // returns the subset of legal moves for a single direction of movement
    Set<(int, int)> seek(
      (int, int) direction,
      bool canRepeat,
      CaptureRule captureRule,
    ) {
      // create the subSet to add to
      Set<(int, int)> resultSet = {};

      final int boardHeight = board.length;
      final int boardWidth = board[0].length;

      var (y, x) = square;
      var (dy, dx) = direction;

      // allows black and white pawns to share the same ruleset but move in opposite directions
      if (piece!.colour == PieceColour.white) dy = -dy;

      do {
        // get the coordinates of the considered move
        y = y + dy;
        x = x + dx;

        // board bounds check
        if (y >= boardHeight || y < 0) break;
        if (x >= boardWidth || x < 0) break;

        // get the piece(or null) at the target coordinates
        final ChessPiece? targetPiece = board[y][x];

        // can't move through friendly pieces and can only capture the first opposing piece in the direction of movement
        if (targetPiece != null) {
          if (targetPiece.colour == piece.colour) break;
          if (captureRule == CaptureRule.moveOnly)
            break; // pawns can't take forwards

          resultSet.add((y, x));

          break;
        } else {
          if (captureRule == CaptureRule.captureOnly)
            break; // pawns can't move diagonaly, only capture

          // square is available to move if it's empty
          resultSet.add((y, x));

          // pawn initial double-move
          if (piece.type == PieceType.pawn &&
              piece.hasMoved == false &&
              board[y + dy][x + dx] == null) {
            resultSet.add((y + dy, x + dx));
          }

          // "en passant"
          // notes:
          // the type of each piece
          // the previous move for each piece (store this against the piece)
          // validMoves: (for a pawn)
          // check if the piece to the left or right is a pawn, and has a previous move of y +/- 2
          // movePiece:
          // [x] for a pawn
          // [x] check if the move is diagonal and there is no piece in the square
          // [x] check for a piece at y +/- 1 and capture that instead

          if (piece.type == PieceType.pawn) {
            // vm = vertical move
            final vm = piece.colour == PieceColour.white ? -1 : 1;
            final ChessPiece? left = column > 0 ? board[row][column - 1] : null;
            final ChessPiece? right =
                column < 7 ? board[row][column + 1] : null;

            if (left?.type == PieceType.pawn && // is it a pawn?
                left?.colour != piece.colour && // is it not your pawn?
                previousTo ==
                    (row, column - 1) && // was it the last piece to move?
                (left?.previousMove?.$1 == 2 || left?.previousMove?.$1 == -2)) {
              // did it move by 2?
              resultSet.add((row + vm, column - 1));
            }

            if (right?.type == PieceType.pawn &&
                right?.colour != piece.colour &&
                previousTo == (row, column + 1) &&
                (right?.previousMove?.$1 == 2 ||
                    right?.previousMove?.$1 == -2)) {
              resultSet.add((row + vm, column + 1));
            }
          }
        }
      } while (canRepeat);

      return resultSet;
    }

    // return no legal moves if it's not the selected pieces turn to move
    if (piece == null ||
        (gameState == GameState.whiteToMove &&
            piece.colour == PieceColour.black) ||
        (gameState == GameState.blackToMove &&
            piece.colour == PieceColour.white)) {
      return {};
    }

    // create result set to add to
    Set<(int, int)> legalMoves = {};

    // add the subset from each of the pieces moverules using the seek function
    moveRuleMap[piece.type].forEach((moveRule) {
      legalMoves = {
        ...legalMoves,
        ...seek(moveRule[0], moveRule[1], moveRule[2])
      };
    });

    // remove moves that would result in placing your own king in check
    if (testCheck) {
      // <-- enable this again
      legalMoves.removeWhere((targetSquare) {
        return testMoveForOpposingChecks(square, targetSquare);
      });
    }

    // return the set of legal moves
    return legalMoves;
  }

  // get Checking Pieces
  Set<(int, int)> getChecks(option) {
    // save the inital gamestate to remeber who's turn it was
    GameState initial = gameState;

    // create the result set to add to
    Set<(int, int)> checks = {};

    // loop over every square on the board
    for (var row = 0; row < board.length; row++) {
      for (var column = 0; column < board[0].length; column++) {
        // get the piece(or null) at each square
        final piece = board[row][column];
        if (piece == null) continue;

        // set the gamestate to that pieces color to allow the getLegalMoves function to work
        gameState = piece.colour == PieceColour.white
            ? GameState.whiteToMove
            : GameState.blackToMove;

        // get the legal moves of the piece
        final moves = getLegalMoves((row, column), testCheck: false);

        // if any of the legal moves attack an oppsing king then add that piece to the set
        // or the king if that option is chosen
        for (final move in moves) {
          final (y, x) = move;
          final target = board[y][x];
          if (target == null) continue;
          if (target.type == PieceType.king && target.colour != piece.colour) {
            if (option == "kings") {
              checks.add((y, x));
            }
            if (option == "attackers") {
              checks.add((row, column));
            }
          }
        }
      }
    }
    // revert to the pre-function gameState
    gameState = initial;

    // return the set of checks
    return checks;
  }

  void swapTurn() {
    if (gameState == GameState.blackToMove) {
      gameState = GameState.whiteToMove;
    } else if (gameState == GameState.whiteToMove) {
      gameState = GameState.blackToMove;
    }
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

    final checks = getChecks('attackers');

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

  Set<(int, int)> getAllActivePlayerLegalMoves() {
    // create set to add to
    Set<(int, int)> resultSet = {};
    // loop over every board square
    for (var row = 0; row < board.length; row++) {
      for (var column = 0; column < board[0].length; column++) {
        // get the piece at that square, continue if square is empty
        final piece = board[row][column];
        if (piece == null) continue;

        // add that pieces legal moves to the set if it's colorr matches the active colour
        if (piece.colour == PieceColour.white &&
            gameState == GameState.whiteToMove) {
          resultSet.addAll(getLegalMoves((row, column)));
        }
        if (piece.colour == PieceColour.black &&
            gameState == GameState.blackToMove) {
          resultSet.addAll(getLegalMoves((row, column)));
        }
      }
    }
    return resultSet;
  }

  bool isActivePlayerInCheck() {
    // get all the checks and return true if the attacked king is of the active palyer
    for (final square in getChecks('attackers')) {
      final (row, column) = square;
      if (board[row][column]!.colour == PieceColour.white &&
          gameState == GameState.blackToMove) {
        return true;
      }
      if (board[row][column]!.colour == PieceColour.black &&
          gameState == GameState.whiteToMove) {
        return true;
      }
    }
    return false;
  }

  void testForWinCondition() {
    // if active player is in check and can't move they lose
    // if active player can't move and is not in check then it's stalemate
    if (getAllActivePlayerLegalMoves().isNotEmpty) return;
    if (isActivePlayerInCheck() && gameState == GameState.blackToMove) {
      gameState = GameState.whiteWin;
    } else if (isActivePlayerInCheck() && gameState == GameState.whiteToMove) {
      gameState = GameState.blackWin;
    } else {
      gameState = GameState.draw;
    }
  }

  bool doesPieceAtSquareBelongToActivePlayer(y, x) {
    if (board[y][x] == null) return false;
    if (board[y][x]!.colour == PieceColour.white &&
        gameState == GameState.whiteToMove) return true;
    if (board[y][x]!.colour == PieceColour.black &&
        gameState == GameState.blackToMove) return true;
    return false;
  }
}

enum GameState { whiteToMove, blackToMove, whiteWin, blackWin, draw }
