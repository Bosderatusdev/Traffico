import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../services/auth_service.dart';
import 'ticket_detail_screen.dart';
import 'package:transport_client/l10n/app_localizations.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final _service = ReservationService();
  bool _isLoading = true;
  String? _erreur;
  Map<String, List<Reservation>> _groupes = {};

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _isLoading = true;
      _erreur = null;
    });

    try {
      final reservations = await _service.mesReservations();

      // Regroupement par groupeId (un achat = un groupe de tickets)
      final groupes = <String, List<Reservation>>{};
      for (final r in reservations) {
        final key = r.groupeId ?? 'r-${r.id}';
        groupes.putIfAbsent(key, () => []).add(r);
      }

      // Trie les groupes du plus récent au plus ancien
      final entriesTriees = groupes.entries.toList()
        ..sort(
          (a, b) => b.value.first.createdAt.compareTo(a.value.first.createdAt),
        );

      if (!mounted) return;
      setState(
        () => _groupes = {for (final e in entriesTriees) e.key: e.value},
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReservations)),
      body: RefreshIndicator(
        onRefresh: _charger,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _erreur != null
            ? _EtatVide(
                icon: Icons.error_outline_rounded,
                title: l10n.noCharge,
                subtitle: _erreur!,
                color: theme.colorScheme.error,
              )
            : _groupes.isEmpty
            ? _EtatVide(
                icon: Icons.confirmation_number_outlined,
                title: l10n.noReservationYet,
                subtitle: l10n.ticketsWillAppear,
                color: semantic.textSecondary,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _groupes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final groupe = _groupes.values.elementAt(index);
                  return _GroupeCard(reservations: groupe, onChanged: _charger);
                },
              ),
      ),
    );
  }
}

class _GroupeCard extends StatelessWidget {
  final List<Reservation> reservations;
  final VoidCallback onChanged;
  const _GroupeCard({required this.reservations, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;
    final premier = reservations.first;
    final t = premier.trajet;
    final total = t.tarif * reservations.length;
    final confirmee = premier.statut.toLowerCase() == 'confirmee';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${t.villeDepart}  →  ${t.villeArrivee}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (confirmee ? semantic.success : semantic.warning)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    confirmee ? 'Confirmée' : 'En attente',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: confirmee ? semantic.success : semantic.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd/MM/yyyy · HH:mm').format(t.heureDepart),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${reservations.length} place${reservations.length > 1 ? 's' : ''} · ${total.toStringAsFixed(0)} FBu',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            ...reservations.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final supprime = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketDetailScreen(reservation: r),
                      ),
                    );

                    if (supprime == true) onChanged();
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 18,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.numeroSiege,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: semantic.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ajout de fonctionnalité de supprimer une réservation
}

class _EtatVide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _EtatVide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 64, color: color),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
