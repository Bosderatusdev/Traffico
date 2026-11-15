import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/auth_service.dart';
import 'reset_password_screen.dart';

enum _Mode { telephone, email }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  _Mode _mode = _Mode.telephone;
  String? _telephoneComplet;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? get _identifiant =>
      _mode == _Mode.telephone ? _telephoneComplet : _emailController.text.trim();

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mode == _Mode.telephone && _telephoneComplet == null) return;

    setState(() => _isLoading = true);
    try {
      final message = await _authService.forgotPassword(identifiant: _identifiant!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(identifiant: _identifiant!),
        ),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Récupère ton compte', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'On t\'enverra un code de vérification',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                SegmentedButton<_Mode>(
                  segments: const [
                    ButtonSegment(
                      value: _Mode.telephone,
                      label: Text('Téléphone'),
                      icon: Icon(Icons.phone_outlined, size: 18),
                    ),
                    ButtonSegment(
                      value: _Mode.email,
                      label: Text('Email'),
                      icon: Icon(Icons.email_outlined, size: 18),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _mode = selection.first;
                      _formKey.currentState?.reset();
                    });
                  },
                ),
                const SizedBox(height: 20),

                if (_mode == _Mode.telephone)
                  IntlPhoneField(
                    initialCountryCode: 'BI',
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    dropdownTextStyle: theme.textTheme.bodyLarge,
                    style: theme.textTheme.bodyLarge,
                    onChanged: (phone) {
                      setState(() => _telephoneComplet = phone.completeNumber);
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return 'Le téléphone est obligatoire';
                      }
                      return null;
                    },
                    invalidNumberMessage: 'Numéro invalide pour ce pays',
                  )
                else
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'L\'email est obligatoire';
                      if (!_emailRegex.hasMatch(v)) return 'Email invalide';
                      return null;
                    },
                  ),

                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Envoyer le code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}