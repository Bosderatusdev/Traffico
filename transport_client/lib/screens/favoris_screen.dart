import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/favori.dart';
import '../services/favori_service.dart';
import '../services/auth_service.dart';

class FavorisScreen extends StatefulWidget {
  const FavorisScreen({super.key});

  @override
  State<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends State<FavorisScreen> {
  final _service = FavoriService();
  bool _isLoading = true;
  List<Favori> _favoris = [];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() => _isLoading = true);
    try {
      final favoris = await _service.mesFavoris();
      if (!mounted) return;
      setState(() => _favoris = favoris);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _supprimer(Favori favori) async {
    try {
      await _service.supprimer(favori.id);
      setState(() => _favoris.removeWhere((f) => f.id == favori.id));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Favoris')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoris.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_outline_rounded, size: 64, color: semantic.textSecondary),
                        const SizedBox(height: 16),
                        Text('Aucun favori pour le moment', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Marque tes trajets et agences préférés pour réserver plus vite',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _charger,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _favoris.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final f = _favoris[index];
                      final estAgence = f.type == 'agence';

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            estAgence ? Icons.business_outlined : Icons.route_outlined,
                            color: colors.primary,
                          ),
                          title: Text(
                            estAgence ? (f.agence?.nom ?? '—') : '${f.villeDepart} → ${f.villeArrivee}',
                            style: theme.textTheme.bodyLarge,
                          ),
                          subtitle: Text(estAgence ? 'Agence' : 'Trajet'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                            onPressed: () => _supprimer(f),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}