import 'agence.dart';

class Favori {
  final int id;
  final String type; // 'agence' ou 'trajet'
  final Agence? agence;
  final String? villeDepart;
  final String? villeArrivee;

  Favori({
    required this.id,
    required this.type,
    this.agence,
    this.villeDepart,
    this.villeArrivee,
  });

  factory Favori.fromJson(Map<String, dynamic> json) {
    return Favori(
      id: json['id'] as int,
      type: json['type'] as String,
      agence: json['agence'] != null ? Agence.fromJson(json['agence']) : null,
      villeDepart: json['villeDepart'] as String?,
      villeArrivee: json['villeArrivee'] as String?,
    );
  }
}