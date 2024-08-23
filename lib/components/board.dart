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

  Map<(int, int), bool> disappearingPieces = {};

  handleClick(y, x) {
    setState(() {
      if (selected == null && widget.game.board[y][x] == null) return;
      if (selected == null &&
          !widget.game.doesPieceAtSquareBelongToActivePlayer(y, x)) return;

      if (selected == null) {
        selected = (y, x);
        legalMoves = widget.game.getLegalMoves((y, x));
      } else {
        if (legalMoves.contains((y, x))) {
          ChessPiece? target = widget.game.board[y][x];

          previousMoveStart = selected;
          previousMoveEnd = (y, x);

          if (target != null) {
            setState(() {
              disappearingPieces[(y, x)] = true;
            });
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                widget.game.movePiece(selected!, (y, x));
                disappearingPieces.remove((y, x));
              });
            });
          } else {
            widget.game.movePiece(selected!, (y, x));
          }

          legalMoves = {};
          selected = null;
        } else {
          if (selected == (y, x)) {
            legalMoves = {};
            selected = null;
          } else if (widget.game.doesPieceAtSquareBelongToActivePlayer(y, x)) {
            selected = (y, x);
            legalMoves = widget.game.getLegalMoves((y, x));
          }
        }
      }
    });
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
              (x) {
                return IconButton(
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
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: disappearingPieces.containsKey((y, x))
                          ? Container() 
                          : widget.game.getAssetPathAtSquare((y, x)) != ""
                              ? SvgPicture.asset(
                                  widget.game.getAssetPathAtSquare((y, x)),
                                  height: tileWidth,
                                  width: tileWidth,
                                  key: ValueKey(widget.game.getAssetPathAtSquare((y, x))),
                                )
                              : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  getSquareColor(y, x) {
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
