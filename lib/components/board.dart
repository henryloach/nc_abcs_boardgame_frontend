import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/components/board_highlights.dart';
import 'package:nc_abcs_boardgame_frontend/components/game_screen.dart';
import 'package:nc_abcs_boardgame_frontend/components/login_screen.dart';
import 'package:nc_abcs_boardgame_frontend/components/promo.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';
import 'package:nc_abcs_boardgame_frontend/game/game.dart';
import 'package:nc_abcs_boardgame_frontend/utils/custom_colors.dart';
import 'package:nc_abcs_boardgame_frontend/utils/websocket_service.dart';
import 'package:nc_abcs_boardgame_frontend/game/server_state.dart';

class Board extends StatefulWidget {
  final Game game;
  final Promo promo;
  final Function setPromo;
  final BoardHighlights boardHighlights;
  final NetworkOption networkOption;

  final double widetWidth = 411.2;

  const Board({
    super.key,
    required this.game,
    required this.promo,
    required this.setPromo,
    required this.boardHighlights,
    required this.networkOption,
  });

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final WebSocketService _webSocketService = WebSocketService();

  handleClick(y, x) {
    setState(() {
      // no piece selected already
      if (server.opponentUsername == null && widget.networkOption == NetworkOption.network) return;
      if (widget.boardHighlights.selected == null &&
          widget.game.board[y][x] == null) return;
      if (widget.boardHighlights.selected == null &&
          !widget.game.doesPieceAtSquareBelongToActivePlayer(y, x)) return;

      if (widget.boardHighlights.selected == null) {
        widget.boardHighlights.selected = (y, x);
        widget.boardHighlights.legalMoves = widget.game.getLegalMoves((y, x));

        // with piece selected
      } else {
        if (widget.boardHighlights.legalMoves.contains((y, x))) {
          ChessPiece? target = widget.game.board[y][x];

          final selectedPiece =
              widget.game.board[widget.boardHighlights.selected!.$1]
                  [widget.boardHighlights.selected!.$2];

          if (widget.networkOption == NetworkOption.oneComputer) {
            widget.game.movePiece(widget.boardHighlights.selected!, (y, x));
          }

          if (selectedPiece!.colour.name == server.myPieces ||
              widget.networkOption == NetworkOption.oneComputer) {
            widget.boardHighlights.previousMoveStart =
                widget.boardHighlights.selected;
            widget.boardHighlights.previousMoveEnd = (y, x);
            if (widget.networkOption == NetworkOption.network) {
              widget.game.movePiece(widget.boardHighlights.selected!, (y, x));
              _webSocketService.sendMessage(
                  'move:${widget.boardHighlights.selected!.$1},${widget.boardHighlights.selected!.$2},$y,$x');
            }
          } else {
            print("Not your piece");
          }

          if (widget.game.canPromote((y, x)) &&
              (selectedPiece.colour.name == server.myPieces ||
                  widget.networkOption == NetworkOption.oneComputer)) {
            widget.setPromo(Promo(row: y, column: x, isMenuOpen: true));
          } else {
            widget.setPromo(Promo(row: null, column: null, isMenuOpen: false));
          }

          widget.boardHighlights.checkers = widget.game.getChecks('attackers');
          widget.boardHighlights.checkees = widget.game.getChecks('kings');

          if (target != null) {
            showPopup(
                message: '${target.colour.name} ${target.type.name} captured!',
                backgroundColor: Colors.green);
          }

          widget.boardHighlights.legalMoves = {};
          widget.boardHighlights.selected = null;
        } else {
          // deselect piece if clicked again
          if (widget.boardHighlights.selected == (y, x)) {
            widget.boardHighlights.legalMoves = {};
            widget.boardHighlights.selected = null;
          }
          // select between pieces without illegal move message
          if (widget.boardHighlights.selected != (y, x) &&
              widget.game.doesPieceAtSquareBelongToActivePlayer(y, x)) {
            widget.boardHighlights.selected = (y, x);
            widget.boardHighlights.legalMoves =
                widget.game.getLegalMoves((y, x));
          } else {
            showPopup(message: 'Invalid move!', backgroundColor: Colors.red);
            widget.boardHighlights.legalMoves = {};
            widget.boardHighlights.selected = null;
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
  void initState() {
    super.initState();
    _checkForPieceAssignment();
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // double tileWidth = constraints.maxWidth / widget.game.board[0].length;
      double tileWidth = 51.4;
      // double tileWidth = widgetWidth / widget.game.board[0].length;
      if (widget.networkOption == NetworkOption.oneComputer) {
        return generateBoard("white", tileWidth);
      }
      // print(server.myPieces);
      switch (server.myPieces) {
        case "white":
          return generateBoard("white", tileWidth);
        case "black":
          return generateBoard("black", tileWidth);
        default:
          return const Center(child: CircularProgressIndicator());
      }
    });
  }

  Container generateBoard(String colour, double tileWidth) {
    return Container(
      width: widgetWidth,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 2,
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        // children: generateBlackBoard(tileWidth),
        children: [
          if (colour == "black") ...[
            ...generateBlackBoard(tileWidth)
          ] else if (colour == "white") ...[
            ...generateWhiteBoard(tileWidth)
          ]
        ],
      ),
    );
  }

  List<Widget> generateWhiteBoard(double tileWidth) {
    return [
      ...List.generate(
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: widget.game.getAssetPathAtSquare((y, x)) != ""
                        ? SvgPicture.asset(
                            widget.game.getAssetPathAtSquare((y, x)),
                            fit: BoxFit.contain,
                            key: ValueKey(
                              widget.game.getAssetPathAtSquare((y, x)),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> generateBlackBoard(double tileWidth) {
    return [
      ...List.generate(
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: widget.game.getAssetPathAtSquare((y, x)) != ""
                        ? SvgPicture.asset(
                            widget.game.getAssetPathAtSquare((y, x)),
                            height: tileWidth,
                            width: tileWidth,
                            key: ValueKey(
                                widget.game.getAssetPathAtSquare((y, x))),
                          )
                        : null,
                  ),
                ),
              ),
            ).reversed,
          ],
        ),
      ).reversed,
    ];
  }

  getSquareColor(y, x) {
    if ((y, x) == widget.boardHighlights.selected) {
      return const Color.fromARGB(218, 209, 91, 12);
    }
    if (widget.boardHighlights.legalMoves.contains((y, x))) {
      return const Color.fromARGB(180, 229, 155, 10);
    }
    return buildChessTileColour(x, y);
  }

  getSquareBorder(y, x) {
    if ((y, x) == widget.boardHighlights.previousMoveEnd ||
        (y, x) == widget.boardHighlights.previousMoveStart) {
      return Border.all(color: Colors.blue, width: 3);
    }
    if (widget.boardHighlights.checkers.contains((y, x)) ||
        widget.boardHighlights.checkees.contains((y, x))) {
      return Border.all(color: Colors.red, width: 3);
    }
    if (widget.boardHighlights.legalMoves.contains((y, x))) {
      return Border.all(color: Colors.black54);
    }
    return Border.all(color: Colors.black12);
  }
}
