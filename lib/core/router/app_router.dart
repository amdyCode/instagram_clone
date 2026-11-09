import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/profile.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/feed/feed_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/post/create_post_screen.dart';
import '../../features/post/post_detail_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/story/story_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = buildRouter();
  ref.onDispose(router.dispose);
  return router;
});

GoRouter buildRouter({String initialLocation = '/splash'}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/auth/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/auth/register', builder: (_, _) => const RegisterScreen()),
    GoRoute(
      path: '/u/:username',
      builder: (_, state) =>
          ProfileScreen(username: state.pathParameters['username']),
    ),
    GoRoute(
      path: '/user/:username',
      builder: (_, state) =>
          ProfileScreen(username: state.pathParameters['username']),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (_, state) =>
          EditProfileScreen(profile: state.extra as Profile?),
    ),
    GoRoute(path: '/create-post', builder: (_, _) => const CreatePostScreen()),
    GoRoute(
      path: '/post/:id',
      builder: (_, state) =>
          PostDetailScreen(postId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/p/:id',
      builder: (_, state) =>
          PostDetailScreen(postId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/story/:index',
      builder: (_, state) {
        final idx = int.tryParse(state.pathParameters['index'] ?? '0') ?? 0;
        return StoryScreen(initialIndex: idx);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => HomeShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (_, _) => const FeedScreen())],
        ),
        _placeholderBranch('/messages', 'Messages', Icons.send_outlined),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/me', builder: (_, _) => const ProfileScreen.me()),
          ],
        ),
      ],
    ),
  ],
);

StatefulShellBranch _placeholderBranch(
  String path,
  String title,
  IconData icon,
) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      builder: (_, _) => ComingSoonScreen(title: title, icon: icon),
    ),
  ],
);
