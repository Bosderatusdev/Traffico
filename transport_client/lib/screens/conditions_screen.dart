import 'package:flutter/material.dart';

class ConditionsScreen extends StatelessWidget {
  const ConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions d\'utilisation')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text('Un jour ,je rédigerai le texte de conditions d\'utilisation.'),
        ),
      ),
    );
  }
}