import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/components/board.dart';
import 'package:nc_abcs_boardgame_frontend/components/captured_piece_display.dart';
import 'package:nc_abcs_boardgame_frontend/components/promo.dart';
import 'package:nc_abcs_boardgame_frontend/game/game.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';

class GameScreen extends StatefulWidget {
  final String username;
  const GameScreen({super.key, required this.username});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  var game = Game();

  Promo promo = Promo();

  void _setPromo(Promo newPromo) {
    setState(() {
      promo = newPromo;
    });
  }

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
              child: Board(
                game: game,
                promo: promo,
                setPromo: _setPromo,
              )),
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
}
