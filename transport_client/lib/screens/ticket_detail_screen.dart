import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:transport_client/services/auth_service.dart';
import 'package:transport_client/services/ticket_pdf_service.dart';
import '../theme/app_theme.dart';
import '../models/reservation.dart';
import '../services/secure_storage_service.dart';
import '../utils/qr_payload.dart';
import '../services/reservation_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final Reservation reservation;
  const TicketDetailScreen({super.key, required this.reservation});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  String? _nom;

bool get _estExpire {
  final finValidite = widget.reservation.trajet.heureDepart.add(const Duration(hours: 24));
  return DateTime.now().isAfter(finValidite);
}

bool get _peutSupprimer => _estExpire;

Future<void> _confirmerSuppression() async {
  if (!_peutSupprimer) {
    final finValidite = widget.reservation.trajet.heureDepart.add(const Duration(hours: 24));
    final restant = finValidite.difference(DateTime.now());
    final heuresRestantes = restant.inHours;
    final minutesRestantes = restant.inMinutes.remainder(60);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Suppression impossible avant l\'expiration du billet '
          '(encore ${heuresRestantes}h${minutesRestantes.toString().padLeft(2, '0')})',
        ),
      ),
    );
    return;
  }

  final confirme = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer ce billet ?'),
      content: const Text('Cette action est irréversible.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
      ],
    ),
  );

  if (confirme != true) return;

  try {
    await ReservationService().supprimer(widget.reservation.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  } on ApiException catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
  }
}

  @override
  void initState() {
    super.initState();
    SecureStorageService.getNom().then((nom) {
      if (mounted) setState(() => _nom = nom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;
    final r = widget.reservation;
    final t = r.trajet;
    final confirmee = r.statut.toLowerCase() == 'confirmee';

    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon billet'),
        actions: [
        IconButton(
          icon: const Icon(Icons.print_outlined),
          tooltip: 'Imprimer',
          onPressed: () async {
            await TicketPdfService.imprimerBillet(
            reservation: widget.reservation,
            nomPassager: _nom ?? '',
          );
        },
        ),
      IconButton(
        icon: Icon(
          Icons.delete_outline,
          color: _peutSupprimer ? theme.colorScheme.error : semantic.textSecondary,
        ),
        tooltip: 'Supprimer',
        onPressed: _confirmerSuppression 
      ),
      ],
    ),

    body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
  clipBehavior: Clip.antiAlias,
  decoration: BoxDecoration(
    color: theme.cardColor,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: semantic.border),
  ),
  child: Column(
    children: [
      // Bandeau supérieur
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: colors.primary,
        child: Column(
          children: [
            Text(
              'TRAFFICO',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Billet de voyage',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),

      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${t.villeDepart}  →  ${t.villeArrivee}',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            _TicketRow(label: 'Passager', value: _nom ?? '...'),
            _TicketRow(
              label: 'Date de départ',
              value: DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(t.heureDepart),
            ),
            _TicketRow(label: 'Agence', value: t.agence?.nom ?? '—'),
            _TicketRow(label: 'Place', value: r.numeroSiege),
            _TicketRow(
              label: 'Prix payé',
              value: '${t.tarif.toStringAsFixed(0)} FBu',
            ),
            _TicketRow(
              label: 'Statut',
              value: confirmee ? 'Confirmée' : 'En attente de paiement',
              valueColor: confirmee ? semantic.success : semantic.warning,
            ),

            const SizedBox(height: 24),
            const _LignePointillee(),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
              color: _estExpire ? semantic.surfaceVariant : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: semantic.border),
              ),
            child: _estExpire
                  ? SizedBox(
                    width: 180,
                    height: 180,
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2_rounded, size: 64, color: semantic.textSecondary),
                      const SizedBox(height: 8),
                      Text('QR expiré', style: theme.textTheme.bodyMedium),
                      ],
                      ),
                      )
                  : QrImageView(
                    data: buildQrPayload(r, _nom ?? ''),
                    version: QrVersions.auto,
                    size: 180,
                  ),
                ),


    const SizedBox(height: 12),
    Text(
     _estExpire
      ? 'Ce billet n\'est plus valide (plus de 24h après le départ)'
      : 'Présente ce code au contrôleur',
  style: theme.textTheme.bodyMedium,
  textAlign: TextAlign.center,
  ),
          ],
        ),
      ),

      // Bandeau inférieur — nouveau, cohérent avec le PDF
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: colors.primary,
        child: Column(
          children: [
            Text(
              'PRÉSENTE CE BILLET AU CONTRÔLEUR',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              r.qrCode.substring(0, 8).toUpperCase(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    ],
    ),
  ),
        
       ),
      );
    }
  }

class _TicketRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _TicketRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    theme.extension<AppSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LignePointillee extends StatelessWidget {
  const _LignePointillee();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 8).floor();
        return Row(
          children: List.generate(count, (_) {
            return Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: Theme.of(context).dividerColor,
              ),
            );
          }),
        );
      },
    );
  }
}
