class ServerState {
  String? myUsername;
  String? myPieces;
  String? opponentUsername;
  String? opponentPieces;
  String? action;
  bool? opponentResigned;
  ServerState(
    this.myUsername,
    this.myPieces,
    this.opponentUsername,
    this.opponentPieces,
    this.action,
    this.opponentResigned,
  );
}

var server = ServerState(null, null, null, null, null, false);
