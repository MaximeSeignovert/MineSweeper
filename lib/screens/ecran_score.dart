import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minesweeper/riverpod/providers.dart';
import 'package:minesweeper/screens/ecran_accueil.dart';
import 'package:minesweeper/widget/leaderboard_widget.dart';

class EcranScore extends ConsumerStatefulWidget {
  final Duration tempsPartie;
  final int score;
  final String playerName;

  const EcranScore({super.key, 
    required this.tempsPartie,
    required this.score,
    required this.playerName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EcranScoreState();
  
}

class _EcranScoreState extends ConsumerState<EcranScore> {

  @override
  void initState() {
    super.initState();
    ref.read(leaderboardNotifierProvider.notifier).updateLeaderboard(widget.playerName, widget.score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Joueur: ${ref.read(playerNameNotifierProvider)}'),
            Text('Temps de la partie: ${widget.tempsPartie.inSeconds}.${widget.tempsPartie.inMilliseconds.remainder(1000)} secondes'),
            Text('Score: ${widget.score}'),
            const SizedBox(height: 16.0),
            const Text('Leaderboard', style: TextStyle(fontSize: 18.0)),
            const LeaderboardWidget(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(builder: (context) => const EcranAccueil()),
                );
              },
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
