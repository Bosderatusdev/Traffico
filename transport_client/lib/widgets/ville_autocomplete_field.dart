import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/debouncer.dart';
import '../data/villes.dart';

class VilleAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const VilleAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  State<VilleAutocompleteField> createState() => _VilleAutocompleteFieldState();
}

class _VilleAutocompleteFieldState extends State<VilleAutocompleteField> {
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 250));
  final _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Petit délai pour laisser le temps au tap sur une suggestion
        // de s'exécuter avant de fermer la liste.
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debouncer.run(() {
      final query = value.trim().toLowerCase();
      if (query.isEmpty) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
        return;
      }
      final matches = villesSuggerees
          .where((ville) => ville.toLowerCase().contains(query))
          .toList();
      setState(() {
        _suggestions = matches;
        _showSuggestions = matches.isNotEmpty;
      });
    });
  }

  void _selectSuggestion(String ville) {
    widget.controller.text = ville;
    setState(() => _showSuggestions = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          textCapitalization: TextCapitalization.words,
          onChanged: _onChanged,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: Icon(widget.icon, size: 20),
          ),
        ),
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints : BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: semantic.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: theme.cardColor,
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final ville = _suggestions[index];
                  return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_city_outlined, size: 18),
                  title: Text(ville, style: theme.textTheme.bodyLarge),
                  onTap: () => _selectSuggestion(ville),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}