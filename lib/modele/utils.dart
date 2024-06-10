import 'package:flutter/material.dart';

  /// Obtient une couleur de trophé en fonction de la position
  Color getColorTrophee(index){
    switch (index) {
      case 1:
        return Colors.yellow.shade600;
      case 2:
        return Colors.grey.shade600;
      case 3:
        return Colors.brown.shade600;
      default:
       return Colors.black;
    }
  }


double mapRange (value, a, b, c, d) {
    value = (value - a) / (b - a);
    return c + value * (d - c);
}

