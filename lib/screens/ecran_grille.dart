import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minesweeper/modele/case.dart';
import 'package:minesweeper/modele/coup.dart';
import 'package:minesweeper/modele/grille.dart';
import 'package:minesweeper/modele/utils.dart';
import 'package:minesweeper/riverpod/providers.dart';
import 'package:minesweeper/screens/ecran_accueil.dart';
import 'package:minesweeper/screens/ecran_score.dart';
import 'package:minesweeper/widget/case_demineur.dart';

class EcranGrille extends ConsumerStatefulWidget {
  final Difficulty difficulty;

  const EcranGrille({super.key, 
    required this.difficulty
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EcranGrilleState();
}

class _EcranGrilleState extends ConsumerState<EcranGrille> {
  late Grille grille;
  late String textMinuteur = "Temps écoulé:";
  late int tailleGrille;
  late int nbMine;
  late Timer timer;
  double tempsEcoule = 0.0;

  Timer? autoPlay;
  bool partieTerminee = false;

  @override
  void initState() {
    super.initState();
    timer = createTimer();

    tailleGrille = 5;
    nbMine = 3;
    if(widget.difficulty == Difficulty.facile){
      tailleGrille = 5;
      nbMine = 3;
    }else if(widget.difficulty == Difficulty.moyen){
      tailleGrille = 7;
      nbMine = 5;
    }else if(widget.difficulty == Difficulty.difficile){
      tailleGrille = 10;
      nbMine = 10;
    }
    
    grille = Grille(taille: tailleGrille, nbMines: nbMine);
    
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('Démineur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _retourAccueil(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              textMinuteur,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0, 
              ),
            ),
            Center(
              child: buildGrid(),
            ),
            ElevatedButton(onPressed: reloadGrille, child: const Text('Reload')),
            Visibility(
              visible: ref.read(playerNameNotifierProvider).toLowerCase() == "admin",
              child: ElevatedButton(onPressed: setAutoPlay, child: const Text('Auto play')),
            ),
            if (partieTerminee)
              ElevatedButton(onPressed: _showScore, child: const Text('Voir les scores')),
          ],
        ),
      ),
  );
}


Timer createTimer() {
  return Timer.periodic(const Duration(milliseconds: 10), (timer) {
    if (!partieTerminee) {
      setState(() {
        tempsEcoule = timer.tick*0.01;
        textMinuteur = "Temps écoulé : ${tempsEcoule.toStringAsFixed(3)} secondes";
      });
    }
  });
}


  void _retourAccueil(BuildContext context) {
    timer.cancel();
    if(autoPlay!=null)autoPlay!.cancel();
    Navigator.pop(context);
  }

void _showScore() async{
  int newScore = calculateScore(tempsEcoule);
  
  String playerName = ref.read(playerNameNotifierProvider);

  ref.read(leaderboardNotifierProvider.notifier).updateLeaderboard(playerName,newScore);

  Navigator.push(
    context,
    CupertinoPageRoute(
      builder: (context) => EcranScore(
        tempsPartie: Duration(seconds:tempsEcoule.toInt(),milliseconds: ((tempsEcoule-tempsEcoule.toInt())*100).toInt()), // Remplacez cela par la variable de votre temps de partie
        score: newScore,
        playerName: playerName,
      ),
    ),
  );
}




  Widget buildGrid() {
    List<Widget> rows = [];
    for (int i = 0; i < grille.taille; i++) {
      List<Widget> columns = [];

      for (int j = 0; j < grille.taille; j++) {
        columns.add(CaseDemineur(
          coord: (ligne: i, colonne: j),
          onLeftTap: handleLeftTap,
          onRightTap: handleRightTap,
          maCase: grille.getCase((ligne: i, colonne: j)),
        ));
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: columns,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rows,
    );
  }

  void reloadGrille() {
    setState(() {
      timer.cancel();
      tempsEcoule = 0;
      grille = Grille(taille: tailleGrille, nbMines: nbMine);
      partieTerminee = false;
      timer = createTimer();
    });
  }

  void handleLeftTap(Coordonnees coord) {
  if(partieTerminee==false){
    setState(() {
      Coup coup = Coup(coord.ligne, coord.colonne, actionCase.decouvrir);
      grille.mettreAJour(coup);
      if (grille.isFinie()) {
        partieTerminee = true;
        
      }
    });
  }
}

void handleRightTap(Coordonnees coord) {
  if(partieTerminee==false){
    setState(() {
      Coup coup = Coup(coord.ligne, coord.colonne, actionCase.marquer);
      grille.mettreAJour(coup);
      if (grille.isFinie()) {
        partieTerminee = true;
      }
    });
  }
  
}

/// Fonction de calcul du score.
int calculateScore(double time){

  if(grille.isPerdue()) return 0;

  var maxTime = 60;

  switch(widget.difficulty) {
  case Difficulty.facile:
    maxTime = 30;
    break;
  case Difficulty.moyen:
    maxTime = 50;
    break;
  case Difficulty.difficile:
    maxTime = 80;
    break;
  default:
    throw Error();
  }

  if(time>maxTime){
    return 0;
  }else{
    return mapRange(time,0,maxTime,1000,0).toInt();
  }
}

/// Joue automatiquement (Fonction seulement disponible pour le joueur admin).
void setAutoPlay(){
  autoPlay = Timer.periodic(const Duration(milliseconds: 100), (timer) {
    setState(() {
      var coupAuto = grille.getHelp();
      if(coupAuto==null){
        autoPlay!.cancel();
      }
      else{
        grille.mettreAJour(coupAuto);
      }
      if (grille.isFinie()) {
          partieTerminee = true;
          autoPlay!.cancel();
      }
    });
  });
}
}


