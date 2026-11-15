import 'package:flutter/material.dart';

class ConfidentialiteScreen extends StatelessWidget {
  const ConfidentialiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confidentialité')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text('Je rédigerai un texte de confidentialt plus tard.'),
        ),
      ),
    );
  }
}