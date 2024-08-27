import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/components/promo.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';
import 'package:nc_abcs_boardgame_frontend/game/game.dart';
import 'package:nc_abcs_boardgame_frontend/utils/custom_colors.dart';
import 'package:nc_abcs_boardgame_frontend/utils/websocket_service.dart';
import 'package:nc_abcs_boardgame_frontend/game/server_state.dart';

class Board extends StatefulWidget {
  final Game game;
  final Promo promo;
  final Function setPromo;

  const Board({
    super.key,
    required this.game,
    required this.promo,
    required this.setPromo,
  });

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final WebSocketService _webSocketService = WebSocketService();

  Set legalMoves = {};
  Set checkers = {};
  Set checkees = {};
  (int, int)? selected;
  (int, int)? previousMoveStart;
  (int, int)? previousMoveEnd;

  late final double tileWidth = MediaQuery.of(context).size.width / 8.0;

  handleClick(y, x) {
    setState(() {
      // no piece selected already
      if (selected == null && widget.game.board[y][x] == null) return;
      if (selected == null &&
          !widget.game.doesPieceAtSquareBelongToActivePlayer(y, x)) return;

      if (selected == null) {
        selected = (y, x);
        legalMoves = widget.game.getLegalMoves((y, x));
        // with piece selected
      } else {
        if (legalMoves.contains((y, x))) {
          ChessPiece? target = widget.game.board[y][x];

          previousMoveStart = selected;
          previousMoveEnd = (y, x);

          // widget.game.movePiece(selected!, (y, x));
          _webSocketService
              .sendMessage('move:${selected!.$1},${selected!.$2},$y,$x');

          checkers = widget.game.getChecks('attackers');
          checkees = widget.game.getChecks('kings');

          if (widget.game.canPromote((y, x))) {
            widget.setPromo(Promo(row: y, column: x, isMenuOpen: true));
          } else {
            widget.setPromo(Promo(row: null, column: null, isMenuOpen: false));
          }

          if (target != null) {
            showPopup(
                message: '${target.colour.name} ${target.type.name} captured!',
                backgroundColor: Colors.green);
          }

          legalMoves = {};
          selected = null;
        } else {
          // deselect piece if clicked again
          if (selected == (y, x)) {
            legalMoves = {};
            selected = null;
          }
          // select between pieces without illegal move message
          if (selected != (y, x) &&
              widget.game.doesPieceAtSquareBelongToActivePlayer(y, x)) {
            selected = (y, x);
            legalMoves = widget.game.getLegalMoves((y, x));
          } else {
            showPopup(message: 'Invalid move!', backgroundColor: Colors.red);
            legalMoves = {};
            selected = null;
          }
        }
      }
    });
  }

  showPopup({
    required String message,
    required Color? backgroundColor,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkForPieceAssignment();
  }

  void _checkForPieceAssignment() {
    if (server.myPieces == null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {}); // rebuild or check again
          _checkForPieceAssignment();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(server.myPieces);
    switch (server.myPieces) {
      case "white":
        return Column(children: generateWhiteBoard);
      case "black":
        return Column(children: generateBlackBoard);
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  List<Widget> get generateWhiteBoard {
    return [
      ...List.generate(
        widget.game.board.length,
        (y) => Row(
          children: [
            ...List.generate(
              widget.game.board[0].length,
              (x) => IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () => handleClick(y, x),
                icon: Container(
                  decoration: BoxDecoration(
                    border: getSquareBorder(y, x),
                    color: getSquareColor(y, x),
                  ),
                  width: tileWidth,
                  height: tileWidth,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: widget.game.getAssetPathAtSquare((y, x)) != ""
                        ? SvgPicture.asset(
                            widget.game.getAssetPathAtSquare((y, x)),
                            height: tileWidth,
                            width: tileWidth,
                            key: ValueKey(
                                widget.game.getAssetPathAtSquare((y, x))),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> get generateBlackBoard {
    return [
      ...List.generate(
        widget.game.board.length,
        (y) => Row(
          children: [
            ...List.generate(
              widget.game.board[0].length,
              (x) => IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () => handleClick(y, x),
                icon: Container(
                  decoration: BoxDecoration(
                    border: getSquareBorder(y, x),
                    color: getSquareColor(y, x),
                  ),
                  width: tileWidth,
                  height: tileWidth,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: widget.game.getAssetPathAtSquare((y, x)) != ""
                        ? SvgPicture.asset(
                            widget.game.getAssetPathAtSquare((y, x)),
                            height: tileWidth,
                            width: tileWidth,
                            key: ValueKey(
                                widget.game.getAssetPathAtSquare((y, x))),
                          )
                        : null,
                  ),
                ),
              ),
            ).reversed,
          ],
        ),
      ).reversed,
    ];
  }

  getSquareColor(y, x) {
    if ((y, x) == selected) {
      return const Color.fromARGB(218, 209, 91, 12);
    }
    if (legalMoves.contains((y, x))) {
      return const Color.fromARGB(180, 229, 155, 10);
    }
    return buildChessTileColour(x, y);
  }

  getSquareBorder(y, x) {
    if ((y, x) == previousMoveEnd || (y, x) == previousMoveStart) {
      return Border.all(color: Colors.blue, width: 3);
    }
    if (checkers.contains((y, x)) || checkees.contains((y, x))) {
      return Border.all(color: Colors.red, width: 3);
    }
    if (legalMoves.contains((y, x))) {
      return Border.all(color: Colors.black54);
    }
    return Border.all(color: Colors.black12);
  }
}
