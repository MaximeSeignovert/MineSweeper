import 'package:minesweeper/modele/case.dart';

/// [Action] qu'on peut jouer sur une [Case]
enum ActionCase { decouvrir, marquer }

/// [Coup] joué
class Coup {
  Coordonnees coordonnees;
  ActionCase action;

  Coup(int lig, int col, this.action)
      : coordonnees = (ligne: lig, colonne: col);
}
