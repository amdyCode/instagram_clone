import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/auth/ig_text_field.dart';
import '../../core/widgets/auth/pill_button.dart';

enum _Channel { email, mobile }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  late final _linkTap = TapGestureRecognizer()..onTap = () {};
  _Channel _channel = _Channel.email;
  int _step = 0;

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _phoneRegex = RegExp(r'^\+?[0-9 ]{8,16}$');

  bool get _isStep1Valid => switch (_channel) {
    _Channel.email => _emailRegex.hasMatch(_emailController.text.trim()),
    _Channel.mobile => _phoneRegex.hasMatch(_emailController.text.trim()),
  };

  bool get _isStep2Valid =>
      _usernameController.text.trim().length >= 3 &&
      _passwordController.text.length >= 6;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _linkTap.dispose();
    super.dispose();
  }

  void _toggleChannel() {
    setState(() {
      _channel = _channel == _Channel.email ? _Channel.mobile : _Channel.email;
      _emailController.clear();
    });
  }

  void _nextStep() {
    if (!_isStep1Valid) return;
    setState(() {
      _step = 1;
    });
  }

  Future<void> _submitRegister() async {
    if (!_isStep2Valid) return;
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim().contains('@')
        ? _emailController.text.trim()
        : '${_usernameController.text.trim()}@exemple.com';

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          email: email,
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      context.go('/');
    } else {
      final error =
          ref.read(authControllerProvider).error ?? 'Erreur d\'inscription';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _toLogin() =>
      context.canPop() ? context.pop() : context.go('/auth/login');

  @override
  Widget build(BuildContext context) {
    final isEmail = _channel == _Channel.email;
    final textTheme = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (_step > 0) {
              setState(() => _step = 0);
            } else {
              _toLogin();
            }
          },
        ),
      ),
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
                      _step == 0
                          ? (isEmail
                                ? 'Entrez votre adresse e-mail'
                                : 'Entrez votre numero de mobile')
                          : 'Creez votre nom d\'utilisateur et mot de passe',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_step == 0) ...[
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
                                        'connecter et securiser votre compte. '
                                        'Personne ne la verra sur votre profil. '
                                  : 'Vous utiliserez ce numero pour vous '
                                        'connecter et securiser votre compte. '
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
                        label: isEmail ? 'E-mail' : 'Numero de mobile',
                        controller: _emailController,
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
                        onSubmitted: (_) => _nextStep(),
                      ),
                      const SizedBox(height: 14),
                      ListenableBuilder(
                        listenable: _emailController,
                        builder: (_, _) => PillButton(
                          label: 'Suivant',
                          onPressed: _isStep1Valid ? _nextStep : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      PillButton.secondary(
                        label: isEmail
                            ? "S'inscrire avec un numero de mobile"
                            : "S'inscrire avec une adresse e-mail",
                        onPressed: _toggleChannel,
                      ),
                    ] else ...[
                      Text(
                        'Choisissez un nom d\'utilisateur et un mot de passe securise pour votre compte.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      IgTextField(
                        label: 'Nom d\'utilisateur',
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      IgTextField(
                        label: 'Nom complet (facultatif)',
                        controller: _fullNameController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      IgTextField(
                        label: 'Mot de passe (6 caracteres min)',
                        controller: _passwordController,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submitRegister(),
                      ),
                      const SizedBox(height: 18),
                      ListenableBuilder(
                        listenable: Listenable.merge([
                          _usernameController,
                          _passwordController,
                        ]),
                        builder: (_, _) => PillButton(
                          label: 'S\'inscrire',
                          loading: authState.isLoading,
                          onPressed: _isStep2Valid ? _submitRegister : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _toLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.metaBlue,
                  ),
                  child: const Text("J'ai deja un compte"),
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
