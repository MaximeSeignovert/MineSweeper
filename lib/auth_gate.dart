import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:minesweeper/screens/ecran_accueil.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: precacheImage(const AssetImage('images/MineSweeper.png'), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Afficher un indicateur de chargement tant que l'image est en cours de préchargement
          return Stack(
            alignment: Alignment.center,
            children: [
              Image.network('images/MineSweeper.png'),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Couleur de l'indicateur de progression
                strokeWidth: 4, // Largeur de la ligne de progression
              ),
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          // Une fois l'image préchargée, afficher le widget SignInScreen
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SignInScreen(
                  providers: [
                    EmailAuthProvider(),
                    GoogleProvider(clientId: "694186317814-ori2f3n1b9arnr3mfrjsi79ianf0s5ta.apps.googleusercontent.com"),
                  ],
                  headerBuilder: (context, constraints, shrinkOffset) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network('images/MineSweeper.png'),
                      ),
                    );
                  },
                  subtitleBuilder: (context, action) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: action == AuthAction.signIn
                          ? const Text('Bienvenue sur MineSweeper, veuillez vous connecter !')
                          : const Text('Bienvenue sur MineSweeper, inscrivez-vous !'),
                    );
                  },
                  footerBuilder: (context, action) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'En vous connectant, vous acceptez nos termes et conditions.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  },
                  sideBuilder: (context, shrinkOffset) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network('images/MineSweeper.png'),
                      ),
                    );
                  },
                );
              }
              return const EcranAccueil();
            },
          );
        } else {
           return const Text("Erreur chargement page d'authentification");
        }
      },
    );
  }
}
