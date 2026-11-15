import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class LanguageSwitcherButton extends StatelessWidget {
  const LanguageSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return TextButton.icon(
      onPressed: () => showLanguagePicker(context),
      icon: const Icon(Icons.language_rounded, size: 18),
      label: Text(locale.toUpperCase()),
    );
  }
}

Future<void> showLanguagePicker(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final current = Localizations.localeOf(context).languageCode;

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.language, style: Theme.of(ctx).textTheme.titleLarge),
            ),
            _LangueOption(code: 'fr', label: 'Français', current: current),
            _LangueOption(code: 'en', label: 'English', current: current),
           _LangueOption(code: 'rn', label: 'Kirundi', current: current, disponible: false),
           // _LangueOption(code: 'sw', label: 'Swahili', current: current, disponible: false),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

class _LangueOption extends StatelessWidget {
  final String code;
  final String label;
  final String current;
  final bool disponible;

  const _LangueOption({
    required this.code,
    required this.label,
    required this.current,
     this.disponible = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: current == code ? const Icon(Icons.check_rounded) : null,
      enabled: disponible,
      subtitle: disponible ? null : Text(AppLocalizations.of(context)!.comingSoon),
      onTap: disponible
          ? () {
              TrafficoApp.of(context)?.changerLangue(code);
              Navigator.pop(context);
            }
          : null,
    );
  }
}