import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_clone/core/models/profile.dart';
import 'package:instagram_clone/core/widgets/common/theme_bottom_sheet.dart';

import '../../core/widgets/profile/profile_grid.dart';
import '../../core/widgets/profile/profile_header.dart';
import '../../core/widgets/profile/profile_tab_bar.dart';
import '../../core/widgets/profile/story_highlights.dart';
import 'edit_profile_screen.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.username, this.isMe = false});

  const ProfileScreen.me({super.key}) : username = null, isMe = true;

  final String? username;
  final bool isMe;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      if (widget.isMe || widget.username == null) {
        ref.read(myProfileControllerProvider.notifier).loadMyProfile();
      } else {
        ref
            .read(userProfileControllerProvider(widget.username!).notifier)
            .loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFollow(Profile profile) {
    final targetUsername = widget.username ?? profile.username;
    ref
        .read(userProfileControllerProvider(targetUsername).notifier)
        .toggleFollow(profile.username);
  }

  Future<void> _editProfile(Profile profile) async {
    final updated = await Navigator.of(context).push<Profile>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );
    if (updated != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis a jour !')),
      );
    }
  }

  Future<void> _onRefresh(bool isMe, String? username) async {
    if (isMe) {
      await ref.read(myProfileControllerProvider.notifier).loadMyProfile();
    } else if (username != null) {
      await ref
          .read(userProfileControllerProvider(username).notifier)
          .loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.isMe || widget.username == null;
    final username = widget.username;

    final ProfileState state = isMe
        ? ref.watch(myProfileControllerProvider)
        : ref.watch(userProfileControllerProvider(username!));

    final profile = state.profile;

    if (state.isLoading && profile == null) {
      return Scaffold(
        appBar: AppBar(
          leading: isMe
              ? null
              : BackButton(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                ),
          title: Text(username ?? ''),
        ),
        body: const Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(
          leading: isMe
              ? null
              : BackButton(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                ),
          title: Text(username ?? ''),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.error ?? 'Profil introuvable'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _onRefresh(isMe, username),
                child: const Text('Reessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _onRefresh(isMe, username),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: false,
                snap: true,
                automaticallyImplyLeading: false,
                leading: isMe
                    ? null
                    : BackButton(
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go('/'),
                      ),
                titleSpacing: isMe ? 16 : 0,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 20),
                    ],
                  ],
                ),
                actions: [
                  if (isMe) ...[
                    IconButton(
                      tooltip: 'Changer le theme',
                      onPressed: () => showThemeBottomSheet(context),
                      icon: const Icon(Icons.palette_outlined, size: 24),
                    ),
                    IconButton(
                      tooltip: 'Creer',
                      onPressed: () => context.push('/create-post'),
                      icon: const Icon(Icons.add_box_outlined, size: 26),
                    ),
                    IconButton(
                      tooltip: 'Menu',
                      onPressed: () {},
                      icon: const Icon(Icons.menu, size: 28),
                    ),
                  ] else ...[
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        size: 26,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Plus d\'options',
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz, size: 26),
                    ),
                  ],
                  const SizedBox(width: 4),
                ],
              ),
              SliverToBoxAdapter(
                child: ProfileHeader(
                  profile: profile,
                  onFollowToggle: () => _toggleFollow(profile),
                  onMessageTap: () {},
                  onEditProfileTap: () => _editProfile(profile),
                  onShareProfileTap: () {},
                ),
              ),
              SliverToBoxAdapter(
                child: StoryHighlights(
                  highlights: profile.highlights,
                  isMe: isMe,
                  onAddTap: () {},
                  onHighlightTap: (h) {},
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverPersistentHeader(
                pinned: true,
                delegate: ProfileTabBarDelegate(tabController: _tabController),
              ),
              ProfilePostGrid(
                posts: profile.posts,
                onPostTap: (post) => context.push('/post/${post.id}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
