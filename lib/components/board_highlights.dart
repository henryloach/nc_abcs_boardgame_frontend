class BoardHighlights {
      (int, int)? previousMoveStart;
      (int, int)? previousMoveEnd;
      (int, int)? selected;

      Set checkers = {};
      Set checkees = {};

      Set legalMoves = {};

      BoardHighlights();
}