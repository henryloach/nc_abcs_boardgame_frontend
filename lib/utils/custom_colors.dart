import 'package:flutter/material.dart';

// colours from https://www.rapidtables.com/web/color/blue-color.html
const Color deepskyblue = Color.fromRGBO(0, 191, 255, 100);
const Color aliceblue = Color.fromRGBO(240, 248, 255, 100);
const Color lightblue = Color.fromRGBO(173, 216, 230, 100);
// const Color firebrick = Color.fromRGBO(178, 34, 34, 100);
const Color firebrick = Color.fromRGBO(177, 81, 81, 1);
const Color indianred = Color.fromRGBO(205, 92, 92, 100);
// const Color lightsalmon = Color.fromRGBO(255, 160, 122, 100);
const Color lightsalmon = Color.fromRGBO(233, 137, 99, 0.612);

Color buildChessTileColour(int x, int y) {
  int val = x;
  if (y.isEven) {
    val++;
  }
  return val.isEven ? firebrick : lightsalmon;
}
