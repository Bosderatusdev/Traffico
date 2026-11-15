import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'register_password_screen.dart';

class RegisterPhoneScreen extends StatefulWidget {
  final String nom;
  final String prenom;

  const RegisterPhoneScreen({
    super.key,
    required this.nom,
    required this.prenom,
  });

  @override
  State<RegisterPhoneScreen> createState() => _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState extends State<RegisterPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  // Numéro complet international, rempli par IntlPhoneField (ex: +25779123456)
  String? _telephoneComplet;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Vos coordonnées')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicateur de progression (étape 2 sur 4)
                Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= 1
                              ? colors.primary
                              : colors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),

                Text('Comment peut-on vous joindre ?', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Le téléphone est obligatoire, l\'email est optionnel',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),

                // Téléphone international avec sélecteur de pays (drapeau + indicatif)
                IntlPhoneField(
                  initialCountryCode: 'BI', // Burundi par défaut, modifiable par le user
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                  ),
                  dropdownTextStyle: theme.textTheme.bodyLarge,
                  style: theme.textTheme.bodyLarge,
                  onChanged: (phone) {
                    setState(() {
                      _telephoneComplet = phone.completeNumber; // ex: +25779123456
                    });
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      return 'Le téléphone est obligatoire';
                    }
                    return null;
                  },
                  invalidNumberMessage: 'Remplis complètement le numéro',
                ),
                const SizedBox(height: 16),

                // Email optionnel
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optionnel)',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return null; // optionnel
                    if (!_emailRegex.hasMatch(v)) return 'Email invalide';
                    return null;
                  },
                ),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Retour'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              _telephoneComplet != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterPasswordScreen(
                                  nom: widget.nom,
                                  prenom: widget.prenom,
                                  telephone: _telephoneComplet!,
                                  email: _emailController.text.trim().isEmpty
                                      ? null
                                      : _emailController.text.trim(),
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Continuer'),
                      ),
                    ),
                  ],
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