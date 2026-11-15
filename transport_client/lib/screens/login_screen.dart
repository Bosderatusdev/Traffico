import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:transport_client/l10n/app_localizations.dart';
import 'package:transport_client/widgets/language_switcher.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import 'register_info_screen.dart';
import 'register_verify_screen.dart';
import 'forgot_password_screen.dart';
import 'main_navigation_screen.dart';

enum _LoginMode { undetermined, phone, email }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiantController = TextEditingController(); // mode email ou neutre
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final _digitRegex = RegExp(r'^[0-9]');

  _LoginMode _mode = _LoginMode.undetermined;
  String? _telephoneComplet; // rempli par IntlPhoneField

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifiantController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onIdentifiantChanged(String value) {
    if (value.isEmpty) {
      setState(() => _mode = _LoginMode.undetermined);
      return;
    }
    if (_mode == _LoginMode.undetermined) {
      if (_digitRegex.hasMatch(value)) {
        // Premiere caractère = chiffre → bascule en mode téléphone.
        setState(() {
          _mode = _LoginMode.phone;
          _identifiantController.clear();
        });
      } else {
        setState(() => _mode = _LoginMode.email);
      }
    }
  }

  void _resetMode() {
    setState(() {
      _mode = _LoginMode.undetermined;
      _identifiantController.clear();
      _telephoneComplet = null;
    });
  }

  String? get _identifiant {
    if (_mode == _LoginMode.phone) return _telephoneComplet;
    return _identifiantController.text.trim();
  }

  Future<void> _handleLogin() async {
    if (_mode == _LoginMode.undetermined) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre ton téléphone ou ton email')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_mode == _LoginMode.phone && _telephoneComplet == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        identifiant: _identifiant!,
        motDePasse: _passwordController.text,
      );

      await SecureStorageService.saveSession(
        token: response.token,
        userId: response.userId,
        role: response.role,
        nom: response.nom,
      );

      if (!mounted) return;

      // On vérifie le canal correspondant au mode de connexion réellement utilisé.
      final estVerifie = _mode == _LoginMode.phone
          ? response.telephoneVerifie
          : response.emailVerifie;

      if (!estVerifie) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterVerifyScreen(
              userId: response.userId,
              telephone: _mode == _LoginMode.phone ? _identifiant! : '',
              email: _mode == _LoginMode.email ? _identifiant : null,
              type: _mode == _LoginMode.phone ? 'phone' : 'email',
            ),
          ),
          (route) => false,
        );
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainNavigationScreen()),
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
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
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
                const SizedBox(height: 8),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    shape: BoxShape.circle
                  ),
                  child: Icon(
                    Icons.directions_bus_rounded,
                    size: 44,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 20),

                Text(l10n.loginTitle, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  l10n.loginSubtitle,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),

                // Champ identifiant — bascule automatique selon la 1er caractère
               
                if (_mode == _LoginMode.phone)
                  IntlPhoneField(
                    initialCountryCode: 'BI',
                    decoration: InputDecoration(
                      labelText: l10n.phone,
                      suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Changer de mode',
                      onPressed: _resetMode,
                    ),
                  ),
                    dropdownTextStyle: theme.textTheme.bodyLarge,
                    style: theme.textTheme.bodyLarge,
                    onChanged: (phone) {
                      _telephoneComplet = phone.completeNumber;
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return 'Le téléphone est obligatoire';
                      }
                      return null;
                    },
                    invalidNumberMessage: 'Remplis complètement le numéro.',
                  )
                else
                  TextFormField(
                    controller: _identifiantController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: _onIdentifiantChanged,
                    decoration: InputDecoration(
                      labelText: l10n.phoneOrEmail,
                      prefixIcon: Icon(
                        _mode == _LoginMode.email
                            ? Icons.email_outlined
                            : Icons.person_outline,
                        size: 20,
                        color: semantic.textSecondary,
                      ),
                      suffixIcon: _mode == _LoginMode.email
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: 'Changer de mode',
                              onPressed: _resetMode,
                            )
                          : null,
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'Ce champ est obligatoire';
                      if (_mode == _LoginMode.email && !_emailRegex.hasMatch(v)) {
                        return l10n.invalidEmail;
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.forgotPassword;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child:  Text(l10n.forgotPassword),
                  ),
                ),
                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.loginButton),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.noAccountYet, style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterInfoScreen()),
                        );
                      },
                      child: Text(l10n.createAccount),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}