/// Record pour représenter les coordonnées d'une case de la grille
typedef Coordonnees = ({int ligne, int colonne});

/// Etat d'une case de la grille pour le joueur
enum Etat { couverte, marquee, decouverte }

/// Une [Case] de la [Grille]
class Case {
  /// La [Case] comporte-t-elle une mine ?
  bool minee;

  /// Etat de la [Case]
  Etat etat = Etat.couverte;

  /// Nombre de mines autour de la [Case], inconnu au départ
  late int nbMinesAutour;

  /// Construit une case non découverte, non marquée et [minee] ou pas
  Case(this.minee);

  /// Découvrir la [Case]
  void decouvrir() => etat = Etat.decouverte;

  /// Inverser la marque de la [Case]
  void inverserMarque() {
    if (etat != Etat.decouverte) {
      etat = (etat == Etat.marquee) ? Etat.couverte : Etat.marquee;
    }
  }
}
