import 'package:nc_abcs_boardgame_frontend/game/chess_piece.dart';
import 'package:nc_abcs_boardgame_frontend/utils/utils.dart';

class Game {
  // Use list for maybe adding more players in future
  // TODO maybe make a palyer class
  List<String> players = ["player1", "player2"];

  List<List<ChessPiece?>> board =
      decodeFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");

  List<ChessPiece> capturedPieces = [];
}
