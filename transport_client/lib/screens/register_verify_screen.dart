import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_success_screen.dart';

class RegisterVerifyScreen extends StatefulWidget {
  final int userId;
  final String telephone;
  final String? email;
  final String type; // 'phone' ou 'email' — quelle vérification est en cours

  const RegisterVerifyScreen({
    super.key,
    required this.userId,
    required this.telephone,
    this.email,
    this.type = 'phone',
  });

  @override
  State<RegisterVerifyScreen> createState() => _RegisterVerifyScreenState();
}

class _RegisterVerifyScreenState extends State<RegisterVerifyScreen> {
  final _authService = AuthService();
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _cooldown = 0;
  Timer? _timer;

  bool get _isPhone => widget.type == 'phone';

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_code.length == 6) {
      FocusScope.of(context).unfocus();
      _handleVerify();
    }
  }

  Future<void> _handleVerify() async {
    if (_code.length != 6) return;
    setState(() => _isLoading = true);

    try {
      await _authService.verifyCode(
        userId: widget.userId,
        code: _code,
        type: widget.type,
      );

      if (!mounted) return;

      if (_isPhone && widget.email != null) {
        // Enchaîner sur la vérification de l'email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterVerifyScreen(
              userId: widget.userId,
              telephone: widget.telephone,
              email: widget.email,
              type: 'email',
            ),
          ),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const RegisterSuccessScreen()),
          (route) => false,
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);
    try {
      final message = await _authService.resendCode(
        userId: widget.userId,
        type: widget.type,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _startCooldown();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _startCooldown() {
    setState(() => _cooldown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final destination = _isPhone ? widget.telephone : (widget.email ?? '');
    final canalLabel = _isPhone ? 'par SMS' : 'par email';

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indicateur de progression (étape 4 sur 4)
              Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              Text('Entrez le code reçu', style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Un code à 6 chiffres a été envoyé $canalLabel à\n$destination',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 44,
                    height: 52,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: theme.textTheme.titleLarge,
                      decoration: const InputDecoration(counterText: ''),
                      onChanged: (value) => _onDigitChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              Center(
                child: _cooldown > 0
                    ? Text(
                        'Renvoyer le code dans ${_cooldown}s',
                        style: theme.textTheme.bodyMedium,
                      )
                    : TextButton(
                        onPressed: _isResending ? null : _handleResend,
                        child: _isResending
                            ? const SizedBox(
                                height: 16, width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Renvoyer le code'),
                      ),
              ),

              const Spacer(),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _code.length == 6 ? _handleVerify : null,
                  child: const Text('Vérifier'),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}