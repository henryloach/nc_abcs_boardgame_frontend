import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';

const Map<String, ChessPiece> fenMap = {
  "k": ChessPiece(PieceType.king, PieceColour.black),
  "q": ChessPiece(PieceType.queen, PieceColour.black),
  "b": ChessPiece(PieceType.bishop, PieceColour.black),
  "n": ChessPiece(PieceType.knight, PieceColour.black),
  "r": ChessPiece(PieceType.rook, PieceColour.black),
  "p": ChessPiece(PieceType.pawn, PieceColour.black),
  "K": ChessPiece(PieceType.king, PieceColour.white),
  "Q": ChessPiece(PieceType.queen, PieceColour.white),
  "B": ChessPiece(PieceType.bishop, PieceColour.white),
  "N": ChessPiece(PieceType.knight, PieceColour.white),
  "R": ChessPiece(PieceType.rook, PieceColour.white),
  "P": ChessPiece(PieceType.pawn, PieceColour.white),
};

List<List<ChessPiece?>> decodeFEN(String fenString) {
  final positionString = fenString.split(" ")[0];
  
  return positionString.split("/").map((rowString) {
    List<ChessPiece?> rowList = [];
    
    for (var char in rowString.split('')) {
      if (int.tryParse(char) != null) {
        rowList.addAll(List.filled(int.parse(char), null));
      } else {
        rowList.add(fenMap[char]);
      }
    }

    return rowList;
  }).toList();
}