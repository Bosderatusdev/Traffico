import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MesAvisScreen extends StatelessWidget {
  const MesAvisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes avis')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_outline_rounded, size: 64, color: semantic.textSecondary),
              const SizedBox(height: 16),
              Text('Aucun avis pour le moment', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Tes avis sur les agences apparaîtront ici',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}