import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transport_client/services/favori_service.dart';
import '../theme/app_theme.dart';
import '../services/secure_storage_service.dart';
import '../services/trajet_service.dart';
import '../services/auth_service.dart';
import '../models/trajet.dart';
import 'package:dio/dio.dart';
import '../widgets/ville_autocomplete_field.dart';
import 'trajet_detail_screen.dart';

import 'package:transport_client/l10n/app_localizations.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  final _departController = TextEditingController();
  final _arriveeController = TextEditingController();
  final _trajetService = TrajetService();
  CancelToken? _cancelToken;

  String? _nom;
  DateTime? _dateChoisie;
  bool _isLoading = false;
  bool _hasSearched = false;
  List<Trajet> _resultats = [];

  @override
  void initState() {
    super.initState();
    _loadNom();
  }

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _loadNom() async {
    final nom = await SecureStorageService.getNom();
    if (mounted) setState(() => _nom = nom);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateChoisie ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _dateChoisie = picked);
  }

  Future<void> _handleSearch() async {
    final depart = _departController.text.trim();
    final arrivee = _arriveeController.text.trim();

    if (depart.isEmpty || arrivee.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Indique une ville de départ et d\'arrivée'),
        ),
      );
      return;
    }

    // j'annnule une recherche précédente encore en vol (évite un résultat obsolète
    // qui arriverait après une recherche plus récente).
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      var resultats = await _trajetService.search(
        depart: depart,
        arrivee: arrivee,
        cancelToken: _cancelToken,
      );

      final maintenant = DateTime.now();

      if (_dateChoisie != null) {
        // j'exclue les trajets passés
        resultats = resultats.where((t) {
          final memeJour =
              t.heureDepart.year == _dateChoisie!.year &&
              t.heureDepart.month == _dateChoisie!.month &&
              t.heureDepart.day == _dateChoisie!.day;
          return memeJour && t.heureDepart.isAfter(maintenant);
        }).toList();
      } else {
        //s'il ne choisis pas de date , je liste ts les trajet à venir pendant 7jrs
        final dansUneSemaine = maintenant.add(const Duration(days: 7));
        resultats = resultats.where((t) {
          return t.heureDepart.isAfter(maintenant) &&
              t.heureDepart.isBefore(dansUneSemaine);
        }).toList();
      }

      // je trie les trajets par dates , les plus proches en haut en suivant les autes

      resultats.sort((a, b) => a.heureDepart.compareTo(b.heureDepart));

      if (!mounted) return;
      setState(() => _resultats = resultats);
    } on DioException {
      // Requête annulée volontairement — il ne donne aucune chose.
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_nom != null ? '${l10n.greeting}, $_nom' : 'Accueil'),
      ),
      body: Column(
        children: [
          // Formulaire de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    VilleAutocompleteField(
                      controller: _departController,
                      label: l10n.searchDeparture,
                      icon: Icons.trip_origin,
                    ),
                    const SizedBox(height: 12),

                    VilleAutocompleteField(
                      controller: _arriveeController,
                      label: l10n.searchArrival,
                      icon: Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Dates',
                          prefixIcon: Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                          ),
                        ),
                        child: Text(
                          _dateChoisie != null
                              ? DateFormat('dd/MM/yyyy').format(_dateChoisie!)
                              : l10n.searchAllDates,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleSearch,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.search_rounded, size: 20),
                        label:  Text(l10n.searchButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ajout des futures fonctionnalitées

          // Résultats
          Expanded(
            child: !_hasSearched
                ? _EmptyState(
                    icon: Icons.map_outlined,
                    title: l10n.findYourTrip,
                    subtitle:
                        l10n.enterDestination,
                    color: semantic.textSecondary,
                  )
                : (_resultats.isEmpty && !_isLoading)
                ? _EmptyState(
                    icon: Icons.search_off_rounded,
                    title: l10n.noTripFound,
                    subtitle: l10n.tryOtherCity,
                    color: semantic.textSecondary,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: _resultats.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _TrajetCard(trajet: _resultats[index]);
                    },
                  ),
          ),

          // ajout des fonctionnalites
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              l10n.comingSoon,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _ServiceAVenirCard(
                  icon: Icons.local_taxi_rounded,
                  label: 'Taxi à la demande',
                  color: semantic.warning,
                ),
                const SizedBox(width: 12),
                _ServiceAVenirCard(
                  icon: Icons.local_shipping_outlined,
                  label: 'Envoi de colis',
                  color: colors.secondary,
                ),
                const SizedBox(width: 12),
                _ServiceAVenirCard(
                  icon: Icons.support_agent_rounded,
                  label: 'Assistance',
                  color: colors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
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
    );
  }
}

class _ServiceAVenirCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ServiceAVenirCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    theme.extension<AppSemanticColors>()!;

    return Opacity(
      opacity: 0.6,
      child: SizedBox(
        width: 96,
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bientot disponible !')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 26, color: color),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Concernant le trajet avec le favoris

class _TrajetCard extends StatefulWidget {
  final Trajet trajet;
  const _TrajetCard({required this.trajet});

  @override
  State<_TrajetCard> createState() => _TrajetCardState();
}

class _TrajetCardState extends State<_TrajetCard> {
  final _favoriService = FavoriService();
  bool _isFavori = false;
  bool _isLoading = false;

  Future<void> _toggleFavori() async {
    setState(() => _isLoading = true);
    try {
      if (_isFavori) {
        // TODO: nécessite de connaître l'id du favori pour le supprimer —
        // pour l'instant on gère l'ajout uniquement depuis les cartes de recherche ;
        // la suppression se fait depuis l'écran Favoris dédié.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Retire ce favori depuis l\'écran Favoris'),
          ),
        );
      } else {
        await _favoriService.ajouterTrajet(
          widget.trajet.villeDepart,
          widget.trajet.villeArrivee,
        );
        setState(() => _isFavori = true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trajet ajouté aux favoris')),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;
    final trajet = widget.trajet;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TrajetDetailScreen(trajet: trajet),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${trajet.villeDepart}  →  ${trajet.villeArrivee}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavori
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: _isFavori
                          ? semantic.warning
                          : semantic.textSecondary,
                    ),
                    onPressed: _isLoading ? null : _toggleFavori,
                  ),
                  Text(
                    '${trajet.tarif.toStringAsFixed(0)} FBu',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              // ... le reste (heure, places, agence) inchangé
            ],
          ),
        ),
      ),
    );
  }
}
