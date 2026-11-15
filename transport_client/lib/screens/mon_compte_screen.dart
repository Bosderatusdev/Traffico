import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'infos_personnelles_screen.dart';
import 'securite_screen.dart';
import 'mes_avis_screen.dart';
import 'favoris_screen.dart';

class MonCompteScreen extends StatelessWidget {
  const MonCompteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon compte')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _CompteTile(
            icon: Icons.badge_outlined,
            title: 'Informations personnelles',
            subtitle: 'Nom, prénom, téléphone, email',
            color: colors.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InfosPersonnellesScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _CompteTile(
            icon: Icons.shield_outlined,
            title: 'Sécurité',
            subtitle: 'Mot de passe, vérification du compte',
            color: semantic.success,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SecuriteScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _CompteTile(
            icon: Icons.payments_outlined,
            title: 'Moyens de paiement',
            subtitle: 'Historique et méthode préférée',
            color: colors.secondary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bientôt disponible')),
              );
            },
          ),
          const SizedBox(height: 12),
          _CompteTile(
            icon: Icons.star_outline_rounded,
            title: 'Mes avis',
            subtitle: 'Avis laissés sur les agences',
            color: semantic.warning,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MesAvisScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _CompteTile(
            icon: Icons.favorite_outline_rounded,
            title: 'Favoris',
            subtitle: 'Trajets et agences favoris',
            color: colors.error,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavorisScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompteTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CompteTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}