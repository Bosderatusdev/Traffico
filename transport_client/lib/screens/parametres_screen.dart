import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'langue_screen.dart';
import 'notifications_prefs_screen.dart';
import 'aide_support_screen.dart';
import 'conditions_screen.dart';
import 'confidentialite_screen.dart';
import 'a_propos_screen.dart';
import 'supprimer_compte_screen.dart';

class ParametresScreen extends StatelessWidget {
  const ParametresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ParamTile(
            icon: Icons.language_outlined,
            title: 'Langue',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LangueScreen())),
          ),
          _ParamTile(
            icon: Icons.notifications_outlined,
            title: 'Préférences de notifications',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPrefsScreen())),
          ),
          _ParamTile(
            icon: Icons.help_outline_rounded,
            title: 'Aide & support',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AideSupportScreen())),
          ),
          const Divider(height: 32),
          _ParamTile(
            icon: Icons.description_outlined,
            title: 'Conditions d\'utilisation',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConditionsScreen())),
          ),
          _ParamTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialité',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfidentialiteScreen())),
          ),
          _ParamTile(
            icon: Icons.info_outline_rounded,
            title: 'À propos',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AProposScreen())),
          ),
          const Divider(height: 32),
          _ParamTile(
            icon: Icons.delete_forever_outlined,
            title: 'Supprimer mon compte',
            danger: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupprimerCompteScreen())),
          ),
        ],
      ),
    );
  }
}

class _ParamTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool danger;
  final VoidCallback onTap;

  const _ParamTile({
    required this.icon,
    required this.title,
    this.danger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = danger ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(color: danger ? color : null)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}