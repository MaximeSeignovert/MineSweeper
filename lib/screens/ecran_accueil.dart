import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minesweeper/riverpod/providers.dart';
import 'package:minesweeper/screens/ecran_grille.dart';
import 'package:minesweeper/widget/leaderboard_widget.dart';

enum Difficulty {
  facile,
  moyen,
  difficile,
}

class EcranAccueil extends ConsumerStatefulWidget {

  const EcranAccueil({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EcranAccueilState();

  
}
class _EcranAccueilState extends ConsumerState<EcranAccueil> {

  final _formKey = GlobalKey<FormState>();
  Difficulty _difficulty = Difficulty.facile;
  bool isDarkModeEnabled = false;
  

  final _playerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _getPlayerNameFromAuthentificated();
    listenForUserProfileChanges();
  }

@override
Widget build(BuildContext context) {
  final isDarkModeEnabled = ref.watch(darkModeProvider);

  return Scaffold(
    appBar: AppBar(
        title: const Text('Accueil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(isDarkModeEnabled ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(darkModeProvider.notifier).state = !isDarkModeEnabled;
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      leading: IconButton(
                        icon: const Icon(Icons.home),
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(builder: (context) => const EcranAccueil()),
                        ),
                      ), 
                      title: const Text("Profil"),
                      centerTitle: true,
                    ),
                    actions: [
                      SignedOutAction((context) {
                        setState(() {
                          Navigator.of(context).pop();
                        });
                      }),
                      
                    ],
                  ), 
                ),
              );
            },
          )
        ],
      ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300.0), // Définissez la largeur maximale souhaitée
                    child: Text(_playerNameController.text,style: const TextStyle(
                      fontSize: 24, // Taille de police plus grande
                      color: Colors.blue, // Utilisation de la couleur principale de l'application
                      // Autres styles de texte (gras, italique, etc.) peuvent être ajoutés ici si nécessaire
                    ),),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300.0), // Définissez la largeur maximale souhaitée
                    child: DropdownButtonFormField<Difficulty>(
                      value: _difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulté',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: Difficulty.facile,
                          child: Text('Facile : 5x5 - 3 mines'),
                        ),
                        DropdownMenuItem(
                          value: Difficulty.moyen,
                          child: Text('Moyen : 7x7 - 5 mines'),
                        ),
                        DropdownMenuItem(
                          value: Difficulty.difficile,
                          child: Text('Difficile : 10x10 - 10 mines'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _difficulty = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                
                _startGame(context, _difficulty);
              }
            },
            child: const Text('Jouer'),
          ),
          const Text('Leaderboard', style: TextStyle(fontSize: 18.0)),
          const LeaderboardWidget(),
        ],
      ),
    ),
  );
}

  void _startGame(BuildContext context, Difficulty difficulty) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => EcranGrille(difficulty: difficulty)),
    );
  }

  /// Récupère les données du joueur courant
  Future<void> _getPlayerNameFromAuthentificated() async {
    setState(() {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String playerName = user.displayName ?? 'Anonymous';
        _playerNameController.text = playerName;
      } else {
        // Gérer le cas où l'utilisateur n'est pas connecté
      }
    });
  }

  /// Surveille les changement appliqué dans le profil du joueur.
  void listenForUserProfileChanges() {
  FirebaseAuth.instance.userChanges().listen((User? user) async {
    if (user != null) {
      String newDisplayName = user.displayName ?? '';
      
      setState(() {
        _playerNameController.text = newDisplayName;
        ref.read(playerNameNotifierProvider.notifier).updatePlayerName(newDisplayName);
      });
      
    }
      
  });
}
  
}
