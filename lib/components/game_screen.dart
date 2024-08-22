import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/game/game.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key, required this.username}) : super(key: key);

  final String username;

  @override
  State<StatefulWidget> createState() => GameScreenState(username);
}

var game = Game();

class Promo {
  bool isMenuOpen;
  int? row;
  int? column;
  String? player;

  Promo({this.isMenuOpen = false, this.row, this.column, this.player});
}

class GameScreenState extends State<GameScreen> {
  GameScreenState(this.username);
  final String username;

  Set highlighted = {};
  (int, int)? selected;
  (int, int)? previousMove;

  Promo promo = Promo();

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

          if (game.canPromote((y, x))) {
            promo = Promo(row: y, column: x, isMenuOpen: true);
          } else {
            promo = Promo(row: null, column: null, isMenuOpen: false);
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
            highlighted = game.getLegalMoves((y, x));
          }
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
          title: const Text("ABC's Chess"),
        ),
        body: Column(children: [
          const Spacer(),
          Text("Hello, $username"),
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
          CapturedWhitePieces(),
          const Spacer(),
          buildChessBoard(),
          const Spacer(),
          CapturedBlackPieces(),
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

class CapturedBlackPieces extends StatelessWidget {
  const CapturedBlackPieces({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ...game.capturedPieces
          .where((piece) => piece.colour.name == 'black')
          .map((piece) => SvgPicture.asset(
                "assets/svg/${piece.colour.name}-${piece.type.name}.svg",
                height: 25,
                width: 25,
              ))
    ]);
  }
}

class CapturedWhitePieces extends StatelessWidget {
  const CapturedWhitePieces({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ...game.capturedPieces
          .where((piece) => piece.colour.name == 'white')
          .map((piece) => SvgPicture.asset(
                "assets/svg/${piece.colour.name}-${piece.type.name}.svg",
                height: 25,
                width: 25,
              ))
    ]);
  }
}
