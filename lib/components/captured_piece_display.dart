import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';

class CapturedPieceDisplay extends StatelessWidget {
  final List<ChessPiece> capturedPieces;
  final PieceColour colour;

  const CapturedPieceDisplay(
      {super.key, required this.capturedPieces, required this.colour});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 30,
      color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...capturedPieces.where((piece) => piece.colour == colour).map(
                (piece) => SvgPicture.asset(
                  "assets/svg/${piece.colour.name}-${piece.type.name}.svg",
                  height: 25,
                  width: 25,
                ),
              ),
        ],
      ),
    );
  }
}
