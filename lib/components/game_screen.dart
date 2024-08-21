import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/game/game.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GameScreenState();
}

var game = Game();

class GameScreenState extends State<GameScreen> {
  Set highlighted = {};
  (int, int)? selected;
  (int, int)? previousMove;

  handleClick(y, x) {
    setState(() {
      if (selected == null) {
        selected = (y, x);
        highlighted = game.getLegalMoves((y, x));
      } else {
        if (highlighted.contains((y, x))) {
          previousMove = selected;

          ChessPiece? capturedPiece = game.board[y][x];
          game.movePiece(selected!, (y, x));

          if (capturedPiece != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${capturedPiece.colour.name} ${capturedPiece.type.name} captured!',
                  style: TextStyle(color: Colors.white),
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
          if (selected != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invalid move!',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          selected = (y, x);
          highlighted = game.getLegalMoves((y, x));
        }
      }
    });
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
          title: const Text("ABCs' Chess Game!"),
        ),
        body: Column(children: [
          const Spacer(),
          buildChessBoard(),
          const Spacer(),
        ]));
  }

  Column buildChessBoard() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ...game.capturedPieces
              .where((piece) => piece.colour.name == 'white')
              .map((piece) => SvgPicture.asset(
                    "assets/svg/${piece.colour.name}-${piece.type.name}.svg",
                    height: 25,
                    width: 25,
                  ))
        ]),
        ...(List.generate(
          8,
          (y) => Row(children: [
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
                  child: game.getAssetPathAtSquare((y, x)) != ""
                      ? SvgPicture.asset(
                          game.getAssetPathAtSquare((y, x)),
                        )
                      : null,
                ),
              ),
            ),
          ]),
        )),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ...game.capturedPieces
              .where((piece) => piece.colour.name == 'black')
              .map((piece) => SvgPicture.asset(
                    "assets/svg/${piece.colour.name}-${piece.type.name}.svg",
                    height: 25,
                    width: 25,
                  ))
        ]),
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
