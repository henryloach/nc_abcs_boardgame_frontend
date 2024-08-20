import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/game/game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GameScreenState();
}

var game = Game();

class GameScreenState extends State<GameScreen> {
  Set highlighted = {};

  // media query - size of the screen
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
        ...(List.generate(
            8,
            (y) => Row(children: [
                  ...List.generate(
                      8,
                      (x) => IconButton(
                            onPressed: () {
                              setState(() {
                                highlighted = game.getLegalMoves((y, x));
                              });
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                color: highlighted.contains((y,x)) ? Colors.red :
                                buildChessTileColour(x, y),
                              ),
                              width: tileWidth,
                              height: tileWidth,
                              child: game.getAssetPathAtSquare((y, x)) != ""
                                  ? SvgPicture.asset(
                                      game.getAssetPathAtSquare((y, x)),
                                    )
                                  : Text("$highlighted"),
                            ),
                          ))
                  // to reverse the list's coordinates
                ])).toList())
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
