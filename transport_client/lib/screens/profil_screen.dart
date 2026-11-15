import 'package:flutter/material.dart';
import 'package:transport_client/screens/parametres_screen.dart';
import '../theme/app_theme.dart';
import '../services/secure_storage_service.dart';
import 'welcome_screen.dart';
import 'mon_compte_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String? _nom;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final nom = await SecureStorageService.getNom();
    final role = await SecureStorageService.getRole();
    if (mounted)
      setState(() {
        _nom = nom;
        _role = role;
      });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text(
          'Tu devras te reconnecter pour accéder à ton compte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SecureStorageService.clearSession();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // En-tête utilisateur
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colors.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person_rounded,
                  size: 36,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_nom ?? '...', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      _role == 'client' ? 'Compte client' : (_role ?? ''),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Carte "Mon compte"
          _ProfilSection(
            title: 'Mon compte',
            subtitle: 'Infos, sécurité, paiement, avis, favoris',
            icon: Icons.account_circle_outlined,
            color: colors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonCompteScreen()),
              );
            },
          ),
          const SizedBox(height: 16),

          // Carte "Paramètres"
          _ProfilSection(
            title: 'Paramètres',
            subtitle: 'Langue, notifications, aide, légal',
            icon: Icons.settings_outlined,
            color: semantic.success,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_)=>ParametresScreen()));
            },
          ),
          const SizedBox(height: 32),

          OutlinedButton.icon(
            onPressed: _handleLogout,
            icon: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
            label: Text(
              'Se déconnecter',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ProfilSection({
    required this.title,
    required this.subtitle,
    required this.icon,
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
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
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
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
