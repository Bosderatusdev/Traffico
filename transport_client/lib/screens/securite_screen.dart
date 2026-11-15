import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';

class SecuriteScreen extends StatefulWidget {
  const SecuriteScreen({super.key});

  @override
  State<SecuriteScreen> createState() => _SecuriteScreenState();
}

class _SecuriteScreenState extends State<SecuriteScreen> {
  final _service = UserService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final userId = await SecureStorageService.getUserId();
      if (userId == null) return;
      final profile = await _service.fetchProfile(userId);
      if (!mounted) return;
      setState(() => _profile = profile);
    } on ApiException {
      // si il n'est pas fait , pas de choses vrt visibles
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _ouvrirChangementMotDePasse() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _ChangePasswordSheet(identifiant: _profile?.telephone ?? '',),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Sécurité du Compte')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Changer le mot de passe'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _ouvrirChangementMotDePasse,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Statut de vérification', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _StatutTile(
                        icon: Icons.phone_outlined,
                        label: 'Téléphone',
                        verifie: _profile?.telephoneVerifie ?? false,
                      ),
                      const Divider(height: 1),
                      _StatutTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        verifie: _profile?.emailVerifie ?? false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool verifie;

  const _StatutTile({required this.icon, required this.label, required this.verifie});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;

    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: (verifie ? semantic.success : semantic.warning).withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          verifie ? 'Vérifié' : 'Non vérifié',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: verifie ? semantic.success : semantic.warning,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}



  class _ChangePasswordSheet extends StatefulWidget {
  final String identifiant; // téléphone ou email du compte connecté

  const _ChangePasswordSheet({required this.identifiant});

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _authService = AuthService();
  final _codeController = TextEditingController();
  final _nouveauController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _codeEnvoye = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nouveauController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _envoyerCode() async {
    setState(() => _isLoading = true);
    try {
      final message = await _authService.forgotPassword(identifiant: widget.identifiant);
      if (!mounted) return;
      setState(() => _codeEnvoye = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmer() async {
    if (_nouveauController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }
    if (_nouveauController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Au moins 6 caractères requis')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final message = await _authService.resetPassword(
        identifiant: widget.identifiant,
        code: _codeController.text.trim(),
        nouveauMotDePasse: _nouveauController.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Changer le mot de passe', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            _codeEnvoye
                ? 'Entre le code reçu et ton nouveau mot de passe'
                : 'Un code de vérification sera envoyé à ${widget.identifiant}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          if (!_codeEnvoye)
            ElevatedButton(
              onPressed: _isLoading ? null : _envoyerCode,
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Envoyer le code'),
            )
          else ...[
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Code reçu', counterText: ''),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nouveauController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _confirmer,
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirmer le nouveau mot de passe'),
            ),
          ],
        ],
      ),
    );
  }
}