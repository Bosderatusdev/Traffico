import 'package:transport_client/models/trajet.dart';

class Reservation {
  final int id;
  final String numeroSiege;
  final String statut;
  final String qrCode;
  final String? groupeId;
  final Trajet trajet;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.numeroSiege,
    required this.statut,
    required this.qrCode,
    this.groupeId,
    required this.trajet,
    required this.createdAt
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      numeroSiege: json['numeroSiege'] as String? ?? '',
      statut: json['statut'] as String? ?? 'en_attente',
      qrCode: json['qrCode'] as String? ?? '',
      groupeId: json['groupeId'] as String?,
      trajet: Trajet.fromJson(json['trajet'] as Map<String, dynamic> ),
      createdAt: DateTime.parse(json['createdAt'] as String)
    );
  }
}
