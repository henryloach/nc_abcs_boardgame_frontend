class ServerState {
  String? myUsername;
  String? myPieces;
  String? opponentUsername;
  String? opponentPieces;
  String? action;
  ServerState(this.myUsername, this.myPieces, this.opponentUsername,
      this.opponentPieces, this.action);
}

final server = ServerState(null, null, null, null, null);
