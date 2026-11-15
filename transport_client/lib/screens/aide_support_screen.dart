import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class AideSupportScreen extends StatelessWidget {
  const AideSupportScreen({super.key});

  Future<void> _appeler(String numero) async {
    final uri = Uri(scheme: 'tel', path: numero);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _envoyerEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Aide & support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Appeler le support'),
              subtitle: const Text('+257 XX XXX XXX'),
              onTap: () => _appeler('+257XXXXXXXX'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Envoyer un email'),
              subtitle: const Text('bosderatusdev.app@gmail.com'),
              onTap: () => _envoyerEmail('bosderatusdev.app@gmail.com'),
            ),
          ),
        ],
      ),
    );
  }
}