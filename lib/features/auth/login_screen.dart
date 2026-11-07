import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_controller.dart';
import '../../core/widgets/auth/ig_text_field.dart';
import '../../core/widgets/auth/pill_button.dart';
import '../../core/widgets/common/instagram_logo.dart';
import '../../core/widgets/common/meta_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  late final _canSubmit = Listenable.merge([_identifier, _password]);
  bool get _isValid =>
      _identifier.text.trim().isNotEmpty && _password.text.isNotEmpty;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
          emailOrUsername: _identifier.text.trim(),
          password: _password.text,
        );

    if (!mounted) return;

    if (success) {
      context.go('/');
    } else {
      final error =
          ref.read(authControllerProvider).error ?? 'Erreur de connexion';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? const BackButton() : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: TextButton.icon(
                          onPressed: () {},
                          iconAlignment: IconAlignment.end,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: secondary,
                          ),
                          label: Text(
                            'Francais (France)',
                            style: TextStyle(
                              color: secondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 64),
                      const Center(child: InstagramGlyph(size: 70)),
                      const SizedBox(height: 96),
                      IgTextField(
                        label: "Nom d'utilisateur, e-mail ou mobile",
                        controller: _identifier,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                      ),
                      const SizedBox(height: 12),
                      IgTextField(
                        label: 'Mot de passe',
                        controller: _password,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 14),
                      ListenableBuilder(
                        listenable: _canSubmit,
                        builder: (_, _) => PillButton(
                          label: 'Se connecter',
                          loading: authState.isLoading,
                          onPressed: _isValid ? _submit : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Mot de passe oublie ?'),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 32),
                      PillButton.outlined(
                        label: 'Creer un compte',
                        onPressed: () => context.push('/auth/register'),
                      ),
                      const SizedBox(height: 16),
                      const Center(child: MetaLogo(size: 17)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
