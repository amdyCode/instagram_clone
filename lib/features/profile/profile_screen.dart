import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_clone/core/models/profile.dart';
import 'package:instagram_clone/core/widgets/common/theme_bottom_sheet.dart';

import '../../core/data/mock_data.dart';
import '../../core/widgets/profile/profile_grid.dart';
import '../../core/widgets/profile/profile_header.dart';
import '../../core/widgets/profile/profile_tab_bar.dart';
import '../../core/widgets/profile/story_highlights.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.username, this.isMe = false});

  const ProfileScreen.me({super.key}) : username = null, isMe = true;

  final String? username;
  final bool isMe;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Profile _profile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _profile = widget.isMe
        ? sampleMyProfile
        : (widget.username == sampleOtherProfile.username ||
                  widget.username == null
              ? sampleOtherProfile
              : sampleOtherProfile.copyWith());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFollow() {
    setState(() {
      final nowFollowing = !_profile.isFollowing;
      _profile = _profile.copyWith(
        isFollowing: nowFollowing,
        followerCount: _profile.followerCount + (nowFollowing ? 1 : -1),
      );
    });
  }

  Future<void> _editProfile() async {
    final updated = await Navigator.of(context).push<Profile>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EditProfileScreen(profile: _profile),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _profile = updated;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil mis à jour !')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.isMe || _profile.isMe;

    return Scaffold(
      body: SafeArea(
        bottom: false,
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
                      onPressed: () =>
                          context.canPop() ? context.pop() : context.go('/'),
                    ),
              titleSpacing: isMe ? 16 : 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _profile.username,
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
                    tooltip: 'Changer le thème',
                    onPressed: () => showThemeBottomSheet(context),
                    icon: const Icon(Icons.palette_outlined, size: 24),
                  ),
                  IconButton(
                    tooltip: 'Créer',
                    onPressed: () {},
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
                    tooltip: 'Plus d’options',
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz, size: 26),
                  ),
                ],
                const SizedBox(width: 4),
              ],
            ),
            SliverToBoxAdapter(
              child: ProfileHeader(
                profile: _profile,
                onFollowToggle: _toggleFollow,
                onMessageTap: () {},
                onEditProfileTap: _editProfile,
                onShareProfileTap: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: StoryHighlights(
                highlights: _profile.highlights,
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
              posts: _profile.posts,
              onPostTap: (post) => context.push('/post/${post.id}'),
            ),
          ],
        ),
      ),
    );
  }
}
