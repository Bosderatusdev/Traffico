import 'package:flutter/material.dart';
import 'package:transport_client/theme/app_theme.dart';
import 'login_screen.dart';

class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Icon(
                Icons.check_circle_rounded,
                size: 88,
                color: semantic.success,
              ),
              const SizedBox(height: 24),
              Text(
                'Compte créé avec succès !',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Ton Compte a été bien vérifié.\nTu peux maintenant te connecter aux services.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(flex: 4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false

                      );
                  },
                  child: const Text('Se Connecter'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
