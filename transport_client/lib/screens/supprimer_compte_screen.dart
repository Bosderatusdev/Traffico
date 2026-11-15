import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import 'welcome_screen.dart';

class SupprimerCompteScreen extends StatefulWidget {
  const SupprimerCompteScreen({super.key});

  @override
  State<SupprimerCompteScreen> createState() => _SupprimerCompteScreenState();
}

class _SupprimerCompteScreenState extends State<SupprimerCompteScreen> {
  final _service = UserService();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirmer() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre ton mot de passe pour confirmer')),
      );
      return;
    }

    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation finale'),
        content: const Text(
          'Cette action supprimera définitivement ton compte et toutes tes données. Continuer ?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirme != true) return;

    setState(() => _isLoading = true);
    try {
      final userId = await SecureStorageService.getUserId();
      if (userId == null) throw ApiException('Utilisateur non connecté');

      await _service.supprimerCompte(userId, _passwordController.text);

      await SecureStorageService.clearSession();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
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
    final semantic = theme.extension<AppSemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Supprimer mon compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'La suppression de ton compte est définitive et entraîne la perte de toutes tes données (réservations, favoris, avis).',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'Entre ton mot de passe pour confirmer que c\'est bien ton compte',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _confirmer,
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Supprimer définitivement mon compte'),
            ),
          ],
        ),
      ),
    );
  }
}