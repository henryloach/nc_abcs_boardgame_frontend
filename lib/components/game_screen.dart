import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/components/board.dart';
import 'package:nc_abcs_boardgame_frontend/components/board_highlights.dart';
import 'package:nc_abcs_boardgame_frontend/components/captured_piece_display.dart';
import 'package:nc_abcs_boardgame_frontend/components/login_screen.dart';
import 'package:nc_abcs_boardgame_frontend/components/promo.dart';
import 'package:nc_abcs_boardgame_frontend/game/game.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';
import 'package:nc_abcs_boardgame_frontend/game/rules.dart';
import 'package:nc_abcs_boardgame_frontend/utils/websocket_service.dart';
import 'package:nc_abcs_boardgame_frontend/game/server_state.dart';

class GameScreen extends StatefulWidget {
  final String username;
  final NetworkOption networkOption;
  const GameScreen(
      {super.key, required this.username, required this.networkOption});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  var game = Game(gameVariant: GameVariant.normal);
  var boardHighlights = BoardHighlights();

  Promo promo = Promo();
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _webSocketService.onMessageReceived = (message) {
      _handleIncomingMessage(message);
      _checkForPieceAssignment();
      _checkForUsernameAssignment();
    };
  }

  void _handleIncomingMessage(String message) {
    if (message.startsWith("move:") &&
        widget.networkOption == NetworkOption.network) {
      _handleMove(message);
    }
    if (message.startsWith("promote:") &&
        widget.networkOption == NetworkOption.network) {
      print("from promate");
      final [_, payload] = message.split(":");
      final [row, column, pieceType] = payload.split(",");
      setState(() {
        game.promotePawn(int.parse(row), int.parse(column), pieceType);
      });
    }
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

  void _checkForUsernameAssignment() {
    if (server.myUsername == null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {});
          _checkForUsernameAssignment();
        }
      });
    }
  }

  void _handleMove(String message) {
    var [startY, startX, endY, endX] = message
        .substring(5)
        .split(',')
        .map((stringNum) => int.parse(stringNum))
        .toList();
    setState(() {
      game.movePiece((startY, startX), (endY, endX));

      boardHighlights.previousMoveStart = (startY, startX);
      boardHighlights.previousMoveEnd = (endY, endX);

      boardHighlights.checkers = game.getChecks('attackers');
      boardHighlights.checkees = game.getChecks('kings');
    });
  }

  void _setPromo(Promo newPromo) {
    setState(() {
      promo = newPromo;
    });
  }

  void handleResign() {
    _webSocketService.sendMessage("resign:resign");
    print("I resign!");
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        title: const Text(
          "Northchess",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              handleResign();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Resign"),
          )
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          SizedBox(
            width: 360,
            child: Text(
              widget.networkOption == NetworkOption.oneComputer
                  ? "black"
                  : server.opponentUsername ?? "Waiting for opponent...",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SomeVerticalSpace(),
          widget.networkOption != NetworkOption.network
              ? WhiteCapturedPieces(game: game)
              : server.opponentPieces == null
                  ? Container(
                      width: 360,
                      height: 32,
                      color: Colors.black12,
                    )
                  : server.opponentPieces == "black"
                      ? WhiteCapturedPieces(game: game)
                      : BlackCapturedPieces(game: game),
          Center(
            child: Board(
              game: game,
              promo: promo,
              setPromo: _setPromo,
              boardHighlights: boardHighlights,
              networkOption: widget.networkOption,
            ),
          ),
          widget.networkOption != NetworkOption.network
              ? BlackCapturedPieces(game: game)
              : server.opponentPieces == null
                  ? Container(
                      width: 360,
                      height: 32,
                      color: Colors.black12,
                    )
                  : server.opponentPieces == "white"
                      ? BlackCapturedPieces(game: game)
                      : WhiteCapturedPieces(game: game),
          const SomeVerticalSpace(),
          SizedBox(
            width: 360,
            child: Text(
              widget.networkOption == NetworkOption.oneComputer
                  ? "white"
                  : server.myUsername ?? "Joining...",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SomeVerticalSpace(),
          if (promo.isMenuOpen) ...[
            openPromoMenu(),
          ],
          ElevatedButton(
            onPressed: () {
              setState(() {
                game = Game(gameVariant: GameVariant.normal);
                boardHighlights = BoardHighlights();
              });
            },
            child: const Text('Reset'),
          ),
          const SomeVerticalSpace(),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            color: Colors.black87,
            child: Text(
              // '${gameStateMessageMap[game.gameState]}',
              gameStateMessage(game.gameState, server),
              style: const TextStyle(
                // fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
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
                        if (widget.networkOption == NetworkOption.network) {
                          _webSocketService.sendMessage(
                              'promote:${promo.row},${promo.column},$pieceType');
                        }
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

class SomeVerticalSpace extends StatelessWidget {
  const SomeVerticalSpace({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 10);
  }
}

class BlackCapturedPieces extends StatelessWidget {
  const BlackCapturedPieces({
    super.key,
    required this.game,
  });

  final Game game;

  @override
  Widget build(BuildContext context) {
    return CapturedPieceDisplay(
        capturedPieces: game.capturedPieces, colour: PieceColour.black);
  }
}

class WhiteCapturedPieces extends StatelessWidget {
  const WhiteCapturedPieces({
    super.key,
    required this.game,
  });

  final Game game;

  @override
  Widget build(BuildContext context) {
    return CapturedPieceDisplay(
        capturedPieces: game.capturedPieces, colour: PieceColour.white);
  }
}

Map<GameState, String> gameStateMessageMap = {
  GameState.whiteToMove: 'White To Move',
  GameState.blackToMove: 'Black To Move',
  GameState.whiteWin: 'White Wins!',
  GameState.blackWin: 'Black Wins!',
  GameState.draw: 'Draw',
  GameState.hasGameStarted: "false"
};

String gameStateMessage(gameState, server) {
  switch (server.myPieces) {
    case "white":
      if (gameState == GameState.whiteToMove) {
        return "Your turn...";
      } else {
        return "Opponent's turn...";
      }
    case "black":
      if (gameState == GameState.whiteToMove) {
        return "Opponent's turn...";
      } else {
        return "Your turn...";
      }
  }
  return "Enjoy game!";
}
