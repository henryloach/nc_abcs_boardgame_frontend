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

  //notification build widget
  
      if (game.gameState == GameState.whiteWin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultMessage(context, 'White Wins!');
      });
    } else if (game.gameState == GameState.blackWin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultMessage(context, 'Black Wins!');
      });
    } else if (game.gameState == GameState.draw) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultMessage(context, 'Draw');
      });
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("ABC's Chess"),
        ),
        body: Column(children: [
          const Spacer(),
          Text("Hello, ${widget.username}"),
          const Spacer(),
          Text(
            '${gameStateMessageMap[game.gameState]}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          const Spacer(),
          CapturedPieceDisplay(
              capturedPieces: game.capturedPieces, colour: PieceColour.white),
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
              capturedPieces: game.capturedPieces, colour: PieceColour.black),
          const Spacer(),
          if (promo.isMenuOpen) ...[
            openPromoMenu(),
          ],
          ElevatedButton(
              onPressed: () {
                setState(() {
                  game = Game();
                });
              },
              child: const Text('Reset')),
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

  // notification overlay

  void _showResultMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        top: MediaQuery.of(context).size.height / 3,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black.withOpacity(0.7),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}

Map<GameState, String> gameStateMessageMap = {
  GameState.whiteToMove: 'White To Move',
  GameState.blackToMove: 'Black To Move',
  GameState.whiteWin: 'White Wins!',
  GameState.blackWin: 'Black Wins!',
  GameState.draw: 'Draw',
};
