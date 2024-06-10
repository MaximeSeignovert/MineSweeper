import 'dart:math';

import 'package:minesweeper/modele/case.dart';
import 'package:minesweeper/modele/coup.dart';


/// [Grille] de démineur
class Grille {
  /// Dimension de la grille carrée : [taille]x[taille]
  final int taille;

  /// Nombre de mines présentes dans la grille
  final int nbMines;

  /// Attribut privé (_), liste composée [taille] listes de chacune [taille] cases
  final List<List<Case>> _grille = [];

  /// Construit une [Grille] comportant [taille] lignes, [taille] colonnes et [nbMines] mines
  Grille({required this.taille, required this.nbMines}) {
    int nbCasesACreer = nbCases; // Le nombre de cases qu'il reste à créer
    int nbMinesAPoser = nbMines; // Le nombre de mines qu'il reste à poser
    Random generateur = Random(); // Générateur de nombres aléatoires
    // Pour chaque ligne de la grille
    for (int lig = 0; lig < taille; lig++) {
      // On va ajouter à la grille une nouvelle Ligne (liste de 'cases')
      List<Case> uneLigne = []; //
      for (int col = 0; col < taille; col++) {
        // S'il reste nBMinesAPoser dans nbCasesACreer, la probabilité de miner est nbMinesAPoser/nbCasesACreer
        // Donc on tire un nombre aléatoire a dans [1..nbCasesACreer] et on pose une mine si a <= nbMinesAposer
        bool isMinee = generateur.nextInt(nbCasesACreer) < nbMinesAPoser;
        if (isMinee) nbMinesAPoser--; // une mine de moins à poser
        uneLigne.add(Case(isMinee)); // On ajoute une nouvelle case à la ligne
        nbCasesACreer--; // Une case de moins à créer
      }
      // On ajoute la nouvelle ligne à la grille
      _grille.add(uneLigne);
    }
    // Les cases étant créées et les mines posées, on calcule pour chaque case le 'nombre de mines autour'
    calculeNbMinesAutour();
  }

  /// Getter qui retourne le nombre de cases
  int get nbCases => taille * taille;

  /// Retourne la [Case] de la [Grille] située à [coord]
  Case getCase(Coordonnees coord) {
    return _grille[coord.ligne][coord.colonne];
  }

  /// Retourne la liste des [Coordonnees] des voisines de la case située à [coord]
  List<Coordonnees> getVoisines(Coordonnees coord) {
    List<Coordonnees> listeVoisines = [];
    
    int maLigne = coord.ligne;
    int maColonne = coord.colonne;
    
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        // Évite d'ajouter la coordonnée actuelle
        if (i == 0 && j == 0) continue;

        int nouvelleLigne = maLigne + i;
        int nouvelleColonne = maColonne + j;

        // Vérifie les limites du plateau
        if (nouvelleLigne >= 0 && nouvelleLigne < taille &&
            nouvelleColonne >= 0 && nouvelleColonne < taille) {
          listeVoisines.add((ligne : nouvelleLigne,colonne : nouvelleColonne));
        }
      }
    }

    return listeVoisines;
  }

  /// Assigne à chaque [Case] le nombre de mines présentes dans ses voisines
  void calculeNbMinesAutour() {
    for (int lig = 0; lig < taille; lig++) {
      for (int col = 0; col < taille; col++) {
        List<Coordonnees> listeVoisines = getVoisines((ligne : lig, colonne:col));

        _grille[lig][col].nbMinesAutour = 0;
        for( Coordonnees coordCaseVoisine in listeVoisines){
          Case caseVoisine = getCase(coordCaseVoisine);
          if(caseVoisine.minee){
            _grille[lig][col].nbMinesAutour++;
          }
        }
      }
    }
  }

  /// - Découvre récursivement toutes les cases voisines d'une case située à [coord]
  /// - La case située à [coord] doit être découverte
  void decouvrirVoisines(Coordonnees coord) {
    Case maCase = getCase(coord);
    maCase.decouvrir();
    
    if(maCase.nbMinesAutour==0){
      List<Coordonnees> coordsCasesVoisines = getVoisines(coord);
      for (Coordonnees coordsCaseVoisine in coordsCasesVoisines) {
        Case caseVoisine = getCase(coordsCaseVoisine);
        if (caseVoisine.etat == Etat.couverte) {
          decouvrirVoisines(coordsCaseVoisine);
        }
      }
    }
  }

  /// Met à jour la Grille en fonction du [coup] joué
  void mettreAJour(Coup coup) {
    
    Case casePlayed = getCase(coup.coordonnees);

    if(coup.action == actionCase.marquer){
        casePlayed.inverserMarque();
    }else if(coup.action == actionCase.decouvrir && casePlayed.etat == Etat.couverte){
        decouvrirVoisines(coup.coordonnees);
    }
  }

  /// Renvoie vrai si [Grille] ne comporte que des cases soit minées soit découvertes (mais pas les 2)
  bool isGagnee() {
    for (int lig = 0; lig < taille; lig++) {
      for (int col = 0; col < taille; col++) {

        Case caseToCheck = getCase((ligne : lig,colonne : col));
        if(caseToCheck.etat == Etat.couverte){
          return false;
        }
      }
    }
    return true;
  }

  /// Renvoie vrai si [Grille] comporte au moins une case minée et découverte
  bool isPerdue() {
    for (int lig = 0; lig < taille; lig++) {
      for (int col = 0; col < taille; col++) {

        Case caseToCheck = getCase((ligne : lig,colonne : col));

        if(caseToCheck.minee == true && caseToCheck.etat == Etat.decouverte){
          return true;
        }
      }
    }
    return false;
  }

  /// Renvoie vrai si la partie est finie, gagnée ou perdue
  bool isFinie() {
    
    if (isGagnee() || isPerdue()){
      return true;
    }
    return false;
  }

  /// Renvoie un coup d'aide
  Coup? getHelp(){
    for (int lig = 0; lig < taille; lig++) {
      for (int col = 0; col < taille; col++) {

        Case caseToCheck = getCase((ligne : lig,colonne : col));

        if(caseToCheck.minee == false && caseToCheck.etat == Etat.couverte){
          return Coup(lig,col,actionCase.decouvrir);
        }else if(caseToCheck.minee == true && caseToCheck.etat == Etat.couverte){
          return Coup(lig,col,actionCase.marquer);
        }
      }
    }
    return null;
  }
}
