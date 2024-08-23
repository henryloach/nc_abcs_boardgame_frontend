import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/components/promo.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';
import 'package:nc_abcs_boardgame_frontend/game/game.dart';
import 'package:nc_abcs_boardgame_frontend/utils/custom_colors.dart';

class Board extends StatefulWidget {
  final Game game;
  final Promo promo;
  final Function setPromo;
  const Board(
      {super.key,
      required this.game,
      required this.promo,
      required this.setPromo});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  Set legalMoves = {};
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
          widget.game.movePiece(selected!, (y, x));

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
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
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
                  child: widget.game.getAssetPathAtSquare((y, x)) != ""
                      ? Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            widget.game.getAssetPathAtSquare((y, x)),
                            height: tileWidth,
                            width: tileWidth,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getSquareColor(y,x) {
    return legalMoves.contains((y, x))
                        ? const Color.fromARGB(255, 229, 155, 45)
                        : buildChessTileColour(x, y);
  }

  getSquareBorder(y, x) {
    return legalMoves.contains((y, x))
                        ? Border.all(color: Colors.black54)
                        : (previousMoveEnd == (y, x)
                            ? Border.all(color: Colors.blue, width: 3)
                            : Border.all(color: Colors.black12));
  }
}
