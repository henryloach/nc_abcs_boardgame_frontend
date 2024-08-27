class BoardHighlights {
      (int, int)? previousMoveStart;
      (int, int)? previousMoveEnd;

      Set checkers = {};
      Set checkees = {};

      Set legalMoves = {};

      BoardHighlights();
}