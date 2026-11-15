import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class ChangerTelephoneScreen extends StatefulWidget {
  final int userId;
  const ChangerTelephoneScreen({super.key, required this.userId});

  @override
  State<ChangerTelephoneScreen> createState() => _ChangerTelephoneScreenState();
}

class _ChangerTelephoneScreenState extends State<ChangerTelephoneScreen> {
  final _service = UserService();
  final _codeController = TextEditingController();
  String? _telephoneComplet;
  bool _codeEnvoye = false;
  bool _isLoading = false;

  Future<void> _envoyerCode() async {
    if (_telephoneComplet == null) return;

    setState(() => _isLoading = true);
    try {
      final message = await _service.demanderChangementTelephone(widget.userId, _telephoneComplet!);
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
      final message = await _service.confirmerChangementTelephone(
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
      appBar: AppBar(title: const Text('Changer le téléphone')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_codeEnvoye) ...[
              Text('Entre ton nouveau téléphone', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              IntlPhoneField(
                initialCountryCode: 'BI',
                decoration: const InputDecoration(labelText: 'Nouveau téléphone'),
                onChanged: (phone) => _telephoneComplet = phone.completeNumber,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _envoyerCode,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Envoyer le code'),
              ),
            ] else ...[
              Text('Entre le code reçu par SMS', style: theme.textTheme.titleLarge),
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







