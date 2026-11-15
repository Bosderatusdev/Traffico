import 'package:intl/intl.dart';
import '../models/reservation.dart';

String buildQrPayload(Reservation reservation, String nomPassager) {
  final t = reservation.trajet;
  final confirmee = reservation.statut.toLowerCase() == 'confirmee';

  return '''
TRAFFICO - Billet de voyage
Passager: $nomPassager
Trajet: ${t.villeDepart} -> ${t.villeArrivee}
Depart: ${DateFormat('dd/MM/yyyy HH:mm').format(t.heureDepart)}
Agence: ${t.agence?.nom ?? '-'}
Place: ${reservation.numeroSiege}
Prix: ${t.tarif.toStringAsFixed(0)} FBu
Statut: ${confirmee ? 'Confirmee' : 'En attente'}
Code: ${reservation.qrCode}
''';
}