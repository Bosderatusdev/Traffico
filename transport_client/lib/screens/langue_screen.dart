import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/locale_service.dart';

class LangueScreen extends StatefulWidget {
  const LangueScreen({super.key});

  @override
  State<LangueScreen> createState() => _LangueScreenState();
}

class _LangueScreenState extends State<LangueScreen> {
  String _selection = 'fr';

  @override
  void initState() {
    super.initState();
    LocaleService.getSavedLocale().then((code) {
      if (code != null && mounted) setState(() => _selection = code);
    });
  }

  void _choisir(String code, {bool disponible = true}) {
    if (!disponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.comingSoon)),
      );
      return;
    }
    setState(() => _selection = code);
    TrafficoApp.of(context)?.changerLangue(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.language)),
      body: ListView(
        children: [
          RadioListTile(
            title: const Text('Français'),
            value: 'fr',
            groupValue: _selection,
            onChanged: (v) => _choisir(v!),
          ),
          RadioListTile(
            title: const Text('English'),
            value: 'en',
            groupValue: _selection,
            onChanged: (v) => _choisir(v!),
          ),
          RadioListTile(
            title: const Text('Kirundi'),
            value: 'rn',
            groupValue: _selection,
            onChanged: (v) => _choisir(v!, disponible: false),
          ),
          RadioListTile(
            title: const Text('Swahili'),
            value: 'sw',
            groupValue: _selection,
            onChanged: (v) => _choisir(v!, disponible: false),
          ),
        ],
      ),
    );
  }
}