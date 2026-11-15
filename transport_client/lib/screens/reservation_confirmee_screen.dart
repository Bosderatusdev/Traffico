import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/trajet.dart';
import '../models/reservation.dart';
import 'main_navigation_screen.dart';

class ReservationConfirmeeScreen extends StatelessWidget {
  final Trajet trajet;
  final List<Reservation> reservations;

  const ReservationConfirmeeScreen({
    super.key,
    required this.trajet,
    required this.reservations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;
    final total = trajet.tarif * reservations.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Réservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Icon(Icons.event_available_rounded, size: 72, color: semantic.warning),
            ),
            const SizedBox(height: 16),
            Text(
              'Réservation en attente de paiement',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${reservations.length} place${reservations.length > 1 ? 's' : ''} réservée${reservations.length > 1 ? 's' : ''} — à confirmer par paiement',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trajet.villeDepart}  →  ${trajet.villeArrivee}',
                      style: theme.textTheme.titleLarge,
                    ),
                    if (trajet.agence != null) ...[
                      const SizedBox(height: 6),
                      Text(trajet.agence!.nom, style: theme.textTheme.bodyMedium),
                    ],
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total à payer', style: theme.textTheme.titleMedium),
                        Text(
                          '${total.toStringAsFixed(0)} FBu',
                          style: theme.textTheme.titleLarge?.copyWith(color: colors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // TODO: brancher le vrai paiement Lumicash (endpoint /api/paiements)
            // dès que le contrat de cet appel est confirmé côté backend.
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paiement à brancher prochainement')),
                );
              },
              child: const Text('Procéder au paiement'),
            ),
            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                  (route) => false,
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