
import 'package:flutter/material.dart';
import 'package:transport_client/l10n/app_localizations.dart';
import 'package:transport_client/widgets/language_switcher.dart';
import 'register_info_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue,),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding:const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
              children: [
              const Spacer(flex: 3),

              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  size: 56,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 32),

              Text(l10n.appName, style: theme.textTheme.headlineLarge),
              const SizedBox(height: 10),

              Text(
                l10n.welcomeTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 4),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text(l10n.alreadyHaveAccount),
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterInfoScreen(),),
                    );
                  },
                  child: Text(l10n.createAccount),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: const LanguageSwitcherButton(),
          ),
        ],
      ),
      ),

    );
  }
}

