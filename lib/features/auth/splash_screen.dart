import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/common/instagram_logo.dart';
import '../../core/widgets/common/meta_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const delay = Duration(milliseconds: 1200);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(SplashScreen.delay, () {
      if (mounted) context.go('/auth/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Center(child: InstagramGlyph(size: 100)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'from',
                      style: TextStyle(color: secondary, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    const MetaLogo(size: 19, gradient: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
