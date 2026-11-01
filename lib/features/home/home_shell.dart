import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/mock_data.dart';
import '../../core/widgets/common/avatar.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _onTap(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    final i = shell.currentIndex;

    final items = <(String, Widget)>[
      (
        'Accueil',
        Icon(i == 0 ? Icons.home_filled : Icons.home_outlined, size: 30),
      ),
      (
        'Messages',
        FaIcon(
          i == 1
              ? FontAwesomeIcons.solidPaperPlane
              : FontAwesomeIcons.paperPlane,
          size: 23,
          color: color,
        ),
      ),
      ('Recherche', Icon(Icons.search, size: 30, weight: i == 2 ? 700 : 400)),
      (
        'Profil',
        Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: i == 3 ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Avatar(url: me.avatarUrl, size: 26),
        ),
      ),
    ];

    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                for (final (index, (label, icon)) in items.indexed)
                  Expanded(
                    child: Semantics(
                      label: label,
                      selected: index == i,
                      button: true,
                      child: InkResponse(
                        onTap: () => _onTap(index),
                        radius: 28,
                        child: Center(
                          child: IconTheme.merge(
                            data: IconThemeData(color: color),
                            child: icon,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: secondary),
            const SizedBox(height: 12),
            Text('Bientôt disponible', style: TextStyle(color: secondary)),
          ],
        ),
      ),
    );
  }
}
