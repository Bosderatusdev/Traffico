import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class ChangerEmailScreen extends StatefulWidget {
  final int userId;
  const ChangerEmailScreen({super.key, required this.userId});

  @override
  State<ChangerEmailScreen> createState() => _ChangerEmailScreenState();
}

class _ChangerEmailScreenState extends State<ChangerEmailScreen> {
  final _service = UserService();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeEnvoye = false;
  bool _isLoading = false;

  Future<void> _envoyerCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final message = await _service.demanderChangementEmail(widget.userId, email);
      if (!mounted) return;
      setState(() => _codeEnvoye = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmer() async {
    setState(() => _isLoading = true);
    try {
      final message = await _service.confirmerChangementEmail(
        widget.userId,
        _codeController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
      appBar: AppBar(title: const Text('Changer l\'email')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_codeEnvoye) ...[
              Text('Entre ton nouvel email', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Nouvel email'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _envoyerCode,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Envoyer le code'),
              ),
            ] else ...[
              Text('Entre le code reçu à ${_emailController.text}', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Code', counterText: ''),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _confirmer,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Confirmer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}