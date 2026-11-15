import 'package:flutter/material.dart';
import 'package:transport_client/screens/change_email_screen.dart';
import '../theme/app_theme.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';

import 'changer_telephone_screen.dart';

class InfosPersonnellesScreen extends StatefulWidget {
  const InfosPersonnellesScreen({super.key});

  @override
  State<InfosPersonnellesScreen> createState() =>
      _InfosPersonnellesScreenState();
}

class _InfosPersonnellesScreenState extends State<InfosPersonnellesScreen> {
  final _service = UserService();
  UserProfile? _profile;
  bool _isLoading = true;
  String? _erreur;

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
      final userId = await SecureStorageService.getUserId();
      if (userId == null) throw ApiException('Utilisateur non connecté');
      final profile = await _service.fetchProfile(userId);
      if (!mounted) return;
      setState(() => _profile = profile);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ouvrirModification() async {
    if (_profile == null) return;
    final modifie = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) =>
          _ModifierInfosSheet(profile: _profile!, service: _service),
    );
    if (modifie == true) _charger();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Informations personnelles')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _erreur != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  _erreur!,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _InfoLigne(label: 'Nom', valeur: _profile!.nom),
                        const Divider(height: 24),
                        _InfoLigne(
                          label: 'Prénom',
                          valeur: _profile!.prenom ?? '—',
                        ),
                        const Divider(height: 24),
                        _InfoLigne(
                          label: 'Email',
                          valeur: _profile!.email ?? '—',
                          verifie: _profile!.email != null
                              ? _profile!.emailVerifie
                              : null,
                        ),
                        const Divider(height: 24),
                        _InfoLigne(
                          label: 'Téléphone',
                          valeur: _profile!.telephone,
                          verifie: _profile!.telephoneVerifie,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _ouvrirModification,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier les infos personnelles'),
                ),
              ],
            ),
    );
  }
}

class _InfoLigne extends StatelessWidget {
  final String label;
  final String valeur;
  final bool? verifie;

  const _InfoLigne({required this.label, required this.valeur, this.verifie});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          child: Text(
            valeur,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (verifie != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (verifie! ? semantic.success : semantic.warning)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              verifie! ? 'Vérifié' : 'Non vérifié',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: verifie! ? semantic.success : semantic.warning,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _ModifierInfosSheet extends StatefulWidget {
  final UserProfile profile;
  final UserService service;

  const _ModifierInfosSheet({required this.profile, required this.service});

  @override
  State<_ModifierInfosSheet> createState() => _ModifierInfosSheetState();
}

class _ModifierInfosSheetState extends State<_ModifierInfosSheet> {
  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.profile.nom);
    _prenomController = TextEditingController(
      text: widget.profile.prenom ?? '',
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }

  Future<void> _enregistrerNomPrenom() async {
    setState(() => _isSaving = true);
    try {
      await widget.service.updateProfile(
        userId: widget.profile.id,
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informations mises à jour')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _changerEmail() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChangerEmailScreen(userId: widget.profile.id)),
    );
  }

  void _changerTelephone() {
    Navigator.pop(context);

    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => ChangerTelephoneScreen(userId: widget.profile.id))
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Modifier mes informations', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),

          TextField(
            controller: _nomController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _prenomController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Prénom'),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isSaving ? null : _enregistrerNomPrenom,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Enregistrer nom et prénom'),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          Text(
            'Modifier email ou téléphone nécessite une vérification par code',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _changerEmail,
            icon: const Icon(Icons.email_outlined, size: 18),
            label: const Text('Changer l\'email'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _changerTelephone,
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: const Text('Changer le téléphone'),
          ),
        ],
      ),
    );
  }
}
