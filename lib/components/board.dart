import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/components/promo.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';
import 'package:nc_abcs_boardgame_frontend/game/game.dart';

class Board extends StatefulWidget {
  final Game game;
  final Promo promo;
  const Board({super.key, required this.game, required this.promo});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  Set highlighted = {};
  (int, int)? selected;
  (int, int)? previousMove;
  late final double tileWidth = MediaQuery.of(context).size.width / 8.0;

  handleClick(y, x) {
    setState(() {
      if (selected == null) {
        selected = (y, x);
        highlighted = widget.game.getLegalMoves((y, x));
      } else {
        if (highlighted.contains((y, x))) {
          previousMove = selected;

          ChessPiece? capturedPiece = widget.game.board[y][x];
          widget.game.movePiece(selected!, (y, x));

          if (widget.game.canPromote((y, x))) {
            setState(() {
              widget.promo.isMenuOpen = true;
              widget.promo.row = y;
              widget.promo.row = x;
            });
          } else {
            setState(() {
              widget.promo.isMenuOpen = false;
            });
          }

          if (capturedPiece != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${capturedPiece.colour.name} ${capturedPiece.type.name} captured!',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          highlighted = {};
          selected = null;
        } else {
          if (selected != null && selected != (y, x)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Invalid move!',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
            selected = previousMove;
          } else {
            selected = (y, x);
            highlighted = widget.game.getLegalMoves((y, x));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...(List.generate(
          8,
          (y) => Row(
            children: [
              ...List.generate(
                8,
                (x) => IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () => handleClick(y, x),
                  icon: Container(
                    decoration: BoxDecoration(
                      border: highlighted.contains((y, x))
                          ? Border.all(color: Colors.black54)
                          : (previousMove == (y, x)
                              ? Border.all(color: Colors.blue, width: 3)
                              : Border.all(color: Colors.black12)),
                      color: highlighted.contains((y, x))
                          ? const Color.fromARGB(255, 229, 155, 45)
                          : buildChessTileColour(x, y),
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
        )),
      ],
    );
  }
}

// TODO put in own file

// colours from https://www.rapidtables.com/web/color/blue-color.html
const Color deepskyblue = Color.fromRGBO(0, 191, 255, 100);
const Color aliceblue = Color.fromRGBO(240, 248, 255, 100);
const Color lightblue = Color.fromRGBO(173, 216, 230, 100);
const Color firebrick = Color.fromRGBO(178, 34, 34, 100);
const Color indianred = Color.fromRGBO(205, 92, 92, 100);
const Color lightsalmon = Color.fromRGBO(255, 160, 122, 100);

Color buildChessTileColour(int x, int y) {
  int val = x;
  if (y.isEven) {
    val++;
  }
  return val.isEven ? firebrick : lightsalmon;
}
