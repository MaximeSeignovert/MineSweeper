import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerNameNotifier extends StateNotifier<String> {
  PlayerNameNotifier() : super('');

  // Méthode pour mettre à jour le nom du joueur
  void updatePlayerName(String newName) {
    state = newName;
    _savePlayerName(newName);
  }

  // Méthode pour charger le nom du joueur depuis le stockage local
  Future<void> loadPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('playerName');
    if (savedName != null) {
      state = savedName;
    }
  }

  // Méthode pour enregistrer le nom du joueur dans le stockage local
  Future<void> _savePlayerName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerName', newName);
  }
}

// Fournisseur pour le notifier du nom du joueur
final playerNameNotifierProvider = StateNotifierProvider<PlayerNameNotifier, String>((ref) {
  final notifier = PlayerNameNotifier();
  notifier.loadPlayerName(); // Charge le nom du joueur depuis le stockage local au démarrage
  return notifier;
});


//------------------------------------------------------------------------------------------------------------------
// Création d'un notifier pour le leaderboard
class LeaderboardNotifier extends StateNotifier<Map<String, int>> {
  LeaderboardNotifier() : super({});

  // Méthode pour mettre à jour le leaderboard avec un nouveau score pour un joueur donné
  Future<void> updateLeaderboard(String playerName, int newScore) async {
    final leaderboardRef = FirebaseFirestore.instance.collection('leaderboard');

    // Récupérer le score actuel du joueur dans la base de données
    final docSnapshot = await leaderboardRef.doc(playerName).get();
    if (docSnapshot.exists) {
      final currentScore = docSnapshot.data()!['score'] ?? 0;
      if (newScore > currentScore) { // Vérifier si le nouveau score est plus élevé que l'ancien
        await leaderboardRef.doc(playerName).set({'score': newScore});
      }
    } else { // Si le joueur n'existe pas encore dans la base de données
      await leaderboardRef.doc(playerName).set({'score': newScore});
    }
    await _fetchLeaderboard(); // Mettre à jour le leaderboard après la modification
  }

  // Méthode pour retirer un joueur du leaderboard
  Future<void> removeFromLeaderboard(String playerName) async{
    final leaderboardRef = FirebaseFirestore.instance.collection('leaderboard');
    await leaderboardRef.doc(playerName).delete();
    await _fetchLeaderboard(); // Mettre à jour le leaderboard après la suppression
  }

  // Méthode pour récupérer le leaderboard depuis Firestore
  Future<void> _fetchLeaderboard() async {
    final leaderboardRef = FirebaseFirestore.instance.collection('leaderboard');
    final snapshot = await leaderboardRef.get();
    
    // Création d'une nouvelle map pour stocker le leaderboard
    Map<String, int> leaderboardData = {};

    // Parcourir les documents récupérés depuis Firestore
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final playerName = doc.id; // Le nom du joueur est l'ID du document
      final score = data['score']; // Récupérer le score depuis les données du document
      if (score != null) {
        leaderboardData[playerName] = score as int; // Ajouter le joueur et son score à la map
      } else {
        leaderboardData[playerName] = 0;
      }
    }

    // Assigner la nouvelle map à l'état
    state = leaderboardData;
  }

  // Méthode pour renvoyer le leaderboard trié
  Future<Map<String, int>> getSortedLeaderboard() async {
    await _fetchLeaderboard(); // Assurez-vous que le leaderboard est à jour avant de le trier
    final sortedEntries = state.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

}

// Fournisseur pour le notifier du leaderboard
final leaderboardNotifierProvider = StateNotifierProvider<LeaderboardNotifier, Map<String, int>>((ref)  {
  final notifier = LeaderboardNotifier();
  return notifier;
});


// ------------------------------------------------------------------------------------------

final darkModeProvider = StateProvider<bool>((ref) => false);
