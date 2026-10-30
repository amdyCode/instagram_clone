import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/auth/ig_text_field.dart';
import '../../core/widgets/auth/pill_button.dart';

enum _Channel { email, mobile }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _value = TextEditingController();
  late final _linkTap = TapGestureRecognizer()..onTap = () {};
  _Channel _channel = _Channel.email;

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _phoneRegex = RegExp(r'^\+?[0-9 ]{8,16}$');

  bool get _isValid => switch (_channel) {
    _Channel.email => _emailRegex.hasMatch(_value.text.trim()),
    _Channel.mobile => _phoneRegex.hasMatch(_value.text.trim()),
  };

  @override
  void dispose() {
    _value.dispose();
    _linkTap.dispose();
    super.dispose();
  }

  void _toggleChannel() {
    setState(() {
      _channel = _channel == _Channel.email ? _Channel.mobile : _Channel.email;
      _value.clear();
    });
  }

  void _next() {
    if (!_isValid) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Étape suivante : bientôt disponible')),
    );
  }

  void _toLogin() =>
      context.canPop() ? context.pop() : context.go('/auth/login');

  @override
  Widget build(BuildContext context) {
    final isEmail = _channel == _Channel.email;
    final textTheme = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: _toLogin)),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      isEmail
                          ? 'Entrez votre adresse e-mail'
                          : 'Entrez votre numéro de mobile',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          color: onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: isEmail
                                ? 'Vous utiliserez cette adresse pour vous '
                                      'connecter et sécuriser votre compte. '
                                      'Personne ne la verra sur votre profil. '
                                : 'Vous utiliserez ce numéro pour vous '
                                      'connecter et sécuriser votre compte. '
                                      'Personne ne le verra sur votre profil. ',
                          ),
                          TextSpan(
                            text: 'En savoir plus',
                            recognizer: _linkTap,
                            style: const TextStyle(
                              color: AppColors.metaBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    IgTextField(
                      key: ValueKey(_channel),
                      label: isEmail ? 'E-mail' : 'Numéro de mobile',
                      controller: _value,
                      keyboardType: isEmail
                          ? TextInputType.emailAddress
                          : TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofillHints: [
                        if (isEmail)
                          AutofillHints.email
                        else
                          AutofillHints.telephoneNumber,
                      ],
                      onSubmitted: (_) => _next(),
                    ),
                    const SizedBox(height: 14),
                    ListenableBuilder(
                      listenable: _value,
                      builder: (_, _) => PillButton(
                        label: 'Suivant',
                        onPressed: _isValid ? _next : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    PillButton.secondary(
                      label: isEmail
                          ? "S'inscrire avec un numéro de mobile"
                          : "S'inscrire avec une adresse e-mail",
                      onPressed: _toggleChannel,
                    ),
                  ],
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _toLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.metaBlue,
                  ),
                  child: const Text("J'ai déjà un compte"),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
