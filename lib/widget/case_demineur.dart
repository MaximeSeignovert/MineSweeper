import 'package:flutter/material.dart';
import 'package:minesweeper/modele/case.dart';
import 'package:material_symbols_icons/symbols.dart';

class CaseDemineur extends StatelessWidget {
  final Coordonnees coord;
  final void Function(Coordonnees) onLeftTap;
  final void Function(Coordonnees) onRightTap;
  final Case maCase;

  const CaseDemineur({
    required this.maCase,
    required this.coord,
    required this.onLeftTap,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    Color numberColor = getNumberColor(maCase.nbMinesAutour);
    return GestureDetector(
      onTap: () {
        onLeftTap(coord);
      },
      onLongPress: () {
        onRightTap(coord);
      },
      child: Container(
        width: 40,
        height: 40,
        color: getBackgroundColor(coord,maCase.etat),
        child: Center(
          child: getContent(maCase,numberColor),
        ),
      ),
    );
  }
}

Color getBackgroundColor(coord, etatCase){
  if(etatCase == Etat.couverte || etatCase == Etat.marquee){
    if((coord.colonne+coord.ligne)%2 == 0){
      return const Color.fromRGBO(141, 234, 84, 1);
    }else{
      return const Color.fromRGBO(131, 228, 76, 1);
    }
  }else if(etatCase == Etat.decouverte){
    if((coord.colonne+coord.ligne)%2 == 0){
      return const Color.fromRGBO(236, 195, 159, 1);
    }else{
      return const Color.fromRGBO(221, 185, 153, 1);
    }
  }
  return Colors.grey;
}

Color getNumberColor(dynamic number) {
  switch (number) {
    case 1:
      return Colors.blue.shade500; // Vert
    case 2:
      return Colors.green.shade500; // Rouge
    case 3:
      return Colors.red.shade500; // Bleu
    case 4:
      return Colors.purple.shade500; // Violet 
    default:
      return Colors.grey.shade700; // Couleur par défaut si le nombre est supérieur
  }
  
}

Widget getContent(laCase,numberColor){
  if(laCase.etat == Etat.marquee){
    return const Icon(
                  Icons.flag, 
                  color: Colors.red,
                  size: 30.0, 
                );
  }if(laCase.etat == Etat.decouverte){
    if(laCase.minee == true){
      return const Icon(
                  Symbols.bomb_rounded, 
                  fill: 1,
                  color: Colors.red,
                  size: 30.0,
      );
    }else{
      return Text(
        laCase.nbMinesAutour>0 && laCase.etat == Etat.decouverte ? laCase.nbMinesAutour.toString() : "",
        style: TextStyle(fontSize: 20.0,
        color: numberColor,
        fontWeight: FontWeight.bold),
      );
    }
  }



  return laCase.etat == Etat.marquee ? const Icon(
                  Icons.flag,
                  color: Colors.red,
                  size: 30.0,
                )
              : Text(
                  laCase.nbMinesAutour>0 && laCase.etat == Etat.decouverte ? laCase.nbMinesAutour.toString() : "",
                  style: TextStyle(fontSize: 20.0,
                  color: numberColor,
                  fontWeight: FontWeight.bold),
                );
}