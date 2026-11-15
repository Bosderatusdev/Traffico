import 'package:flutter/material.dart';
import 'package:transport_client/screens/register_phone_screen.dart';
import 'package:transport_client/widgets/language_switcher.dart';
import '../theme/app_theme.dart';

class RegisterInfoScreen extends StatefulWidget {
  const RegisterInfoScreen({super.key});

  @override
  State<RegisterInfoScreen> createState() => _RegisterInfoScreenState();
}

class _RegisterInfoScreenState extends State<RegisterInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    theme.extension<AppSemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vos informations'),
        actions: const [LanguageSwitcherButton()],
        ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? colors.primary
                              : colors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),

                Text(
                  'Comment vous appelez-vous ?',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Ces informations apparaîtront sur vos billets',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),

                TextFormField(
                  controller: _nomController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Le nom est obligatoire'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prenomController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Le prénom est obligatoire'
                      : null,
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return RegisterPhoneScreen(
                              nom: _nomController.text.trim(),
                              prenom: _prenomController.text.trim(),
                            );
                          },
                        ),
                      );
                    }
                  },
                  child: const Text('Continuer'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
