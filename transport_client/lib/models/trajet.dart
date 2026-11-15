import 'agence.dart';

class Trajet {
  final int id;
  final Agence? agence;
  final String villeDepart;
  final String villeArrivee;
  final DateTime heureDepart;
  final DateTime? heureArrivee;
  final double tarif;
  final int? placesDisponibles;
  final String statut;

  Trajet({
    required this.id,
    this.agence,
    required this.villeDepart,
    required this.villeArrivee,
    required this.heureDepart,
    this.heureArrivee,
    required this.tarif,
    this.placesDisponibles,
    required this.statut,
  });

  factory Trajet.fromJson(Map<String, dynamic> json) {
    return Trajet(
      id: json['id'] as int,
      agence: json['agence'] != null
          ? Agence.fromJson(json['agence'] as Map<String, dynamic>)
          : null,
      villeDepart: json['villeDepart'] as String,
      villeArrivee: json['villeArrivee'] as String,
      heureDepart: DateTime.parse(json['heureDepart'] as String),
      heureArrivee: json['heureArrivee'] != null
          ? DateTime.parse(json['heureArrivee'] as String)
          : null,
      tarif: (json['tarif'] as num).toDouble(),
      placesDisponibles: json['placesDisponibles'] as int?,
      statut: json['statut'] as String? ?? 'actif',
    );
  }
}