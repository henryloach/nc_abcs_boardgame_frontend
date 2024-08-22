import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/components/captured_piece_display.dart';
import 'package:nc_abcs_boardgame_frontend/game/game.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';

class GameScreen extends StatefulWidget {
  final String username;
  const GameScreen({super.key, required this.username});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class Promo {
  bool isMenuOpen;
  int? row;
  int? column;
  String? player;

  Promo({this.isMenuOpen = false, this.row, this.column, this.player});
}

class _GameScreenState extends State<GameScreen> {
  var game = Game();
  Set legalMoves = {};
  (int, int)? selected;
  (int, int)? previousMoveStart;
  (int, int)? previousMoveEnd;

  Promo promo = Promo();

  handleClick(y, x) {
    setState(() {
      // no piece selected already
      if (selected == null && game.board[y][x] == null) return;
      if (selected == null && !game.doesPieceAtSquareBelongToActivePlayer(y, x))
        return;

      if (selected == null) {
        selected = (y, x);
        legalMoves = game.getLegalMoves((y, x));
        // with piece selected
      } else {
        if (legalMoves.contains((y, x))) {
          ChessPiece? target = game.board[y][x];

          previousMoveStart = selected;
          previousMoveEnd = (y, x);
          game.movePiece(selected!, (y, x));

          if (game.canPromote((y, x))) {
            promo = Promo(row: y, column: x, isMenuOpen: true);
          } else {
            promo = Promo(row: null, column: null, isMenuOpen: false);
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
              game.doesPieceAtSquareBelongToActivePlayer(y, x)) {
            selected = (y, x);
            legalMoves = game.getLegalMoves((y, x));
          } else {
            showPopup(message: 'Invalid move!', backgroundColor: Colors.red);
            selected = previousMoveStart;
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

  late final double tileWidth = MediaQuery.of(context).size.width / 8.0;
  // colours from https://www.rapidtables.com/web/color/blue-color.html
  final Color deepskyblue = const Color.fromRGBO(0, 191, 255, 100);
  final Color aliceblue = const Color.fromRGBO(240, 248, 255, 100);
  final Color lightblue = const Color.fromRGBO(173, 216, 230, 100);
  final Color firebrick = const Color.fromRGBO(178, 34, 34, 100);
  final Color indianred = const Color.fromRGBO(205, 92, 92, 100);
  final Color lightsalmon = const Color.fromRGBO(255, 160, 122, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("ABC's Chess"),
        ),
        body: Column(children: [
          const Spacer(),
          Text("Hello, ${widget.username}"),
          const Spacer(),
          Text("${game.gameState}"),
          const Spacer(),
          if (game.gameState == GameState.whiteToMove) ...[
            const Text(
              "White's Turn",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            )
          ] else if (game.gameState == GameState.blackToMove) ...[
            const Text(
              "Black's Turn",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            )
          ],
          const Spacer(),
          CapturedPieceDisplay(
              capturedPieces: game.capturedPieces, colour: PieceColour.black),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: buildChessBoard(),
          ),
          const Spacer(),
          CapturedPieceDisplay(
              capturedPieces: game.capturedPieces, colour: PieceColour.white),
          const Spacer(),
          if (promo.isMenuOpen) ...[
            openPromoMenu(),
          ],
          const Spacer(),
        ]));
  }

  Container openPromoMenu() {
    return Container(
      color: const Color.fromARGB(255, 39, 3, 0),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Text(
            "Promote pawn to:",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ...["queen", "bishop", "rook", "knight"].map(
                (pieceType) => Container(
                  color: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      if (promo.row != null && promo.column != null) {
                        game.promotePawn(promo.row!, promo.column!, pieceType);
                        setState(() {
                          promo.isMenuOpen = false;
                        });
                      }
                    },
                    icon: SvgPicture.asset("assets/svg/black-$pieceType.svg"),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Column buildChessBoard() {
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
                      border: legalMoves.contains((y, x))
                          ? Border.all(color: Colors.black54)
                          : (previousMoveStart == (y, x)
                              ? Border.all(color: Colors.blue, width: 3)
                              : Border.all(color: Colors.black12)),
                      color: legalMoves.contains((y, x))
                          ? const Color.fromARGB(255, 229, 155, 45)
                          : buildChessTileColour(x, y),
                    ),
                    width: tileWidth,
                    height: tileWidth,
                    child: game.getAssetPathAtSquare((y, x)) != ""
                        ? Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: SvgPicture.asset(
                              game.getAssetPathAtSquare((y, x)),
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

  Color buildChessTileColour(int x, int y) {
    int val = x;
    if (y.isEven) {
      val++;
    }
    return val.isEven ? firebrick : lightsalmon;
  }
}
