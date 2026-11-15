import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/trajet.dart';
import '../services/reservation_service.dart';
import '../services/auth_service.dart';
import 'reservation_confirmee_screen.dart';

class TrajetDetailScreen extends StatefulWidget {
  final Trajet trajet;
  const TrajetDetailScreen({super.key, required this.trajet});

  @override
  State<TrajetDetailScreen> createState() => _TrajetDetailScreenState();
}

class _TrajetDetailScreenState extends State<TrajetDetailScreen> {
  final _reservationService = ReservationService();
  int _nombrePlaces = 1;
  bool _isLoading = false;

  int get _maxPlaces => widget.trajet.placesDisponibles ?? 1;

  void _incrementer() {
    if (_nombrePlaces < _maxPlaces) {
      setState(() => _nombrePlaces++);
    }
  }

  void _decrementer() {
    if (_nombrePlaces > 1) {
      setState(() => _nombrePlaces--);
    }
  }

  Future<void> _handleReserver() async {
    setState(() => _isLoading = true);
    try {
      final reservations = await _reservationService.creer(
        trajetId: widget.trajet.id,
        nombrePlaces: _nombrePlaces,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReservationConfirmeeScreen(
            trajet: widget.trajet,
            reservations: reservations,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;
    final t = widget.trajet;
    final total = t.tarif * _nombrePlaces;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du trajet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.villeDepart}  →  ${t.villeArrivee}',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(t.heureDepart),
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Départ à ${DateFormat('HH:mm').format(t.heureDepart)}'
                          '${t.heureArrivee != null ? ' · Arrivée à ${DateFormat('HH:mm').format(t.heureArrivee!)}' : ''}',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.event_seat_outlined,
                      label: '${t.placesDisponibles ?? '—'} places disponibles',
                    ),
                    if (t.agence != null) ...[
                      const SizedBox(height: 10),
                      _InfoRow(icon: Icons.business_outlined, label: t.agence!.nom),
                    ] else ...[
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.warning_amber_rounded,
                        label: 'Agence non précisée pour ce trajet',
                        color: semantic.warning,
                      ),
                    ],
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tarif par place', style: theme.textTheme.titleMedium),
                        Text(
                          '${t.tarif.toStringAsFixed(0)} FBu',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Nombre de places', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Veuillez indiquer le nombre de personnes correspondant au nombre de places à réserver dans le bus.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _nombrePlaces > 1 ? _decrementer : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$_nombrePlaces', style: theme.textTheme.headlineMedium),
                    IconButton.filledTonal(
                      onPressed: _nombrePlaces < _maxPlaces ? _incrementer : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total à payer', style: theme.textTheme.titleLarge),
                Text(
                  '${total.toStringAsFixed(0)} FBu',
                  style: theme.textTheme.headlineMedium?.copyWith(color: colors.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleReserver,
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Réserver $_nombrePlaces place${_nombrePlaces > 1 ? 's' : ''}'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoRow({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;

    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? semantic.textSecondary),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
      ],
    );
  }
}