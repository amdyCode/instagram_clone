import 'package:flutter/material.dart';

import '../../core/widgets/common/instagram_logo.dart';
import '../../core/widgets/feed/post_card.dart';
import '../../core/widgets/feed/story_tray.dart';
import 'data/fake_feed.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => Future<void>.delayed(const Duration(seconds: 1)),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                centerTitle: true,
                toolbarHeight: 52,
                leading: IconButton(
                  tooltip: 'Créer',
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 32),
                ),
                title: const InstagramWordmark(),
                actions: [
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border, size: 28),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              SliverToBoxAdapter(child: StoryTray(stories: fakeStories)),
              const SliverToBoxAdapter(child: SizedBox(height: 4)),
              SliverList.builder(
                itemCount: fakePosts.length,
                itemBuilder: (_, i) => PostCard(
                  key: ValueKey(fakePosts[i].id),
                  post: fakePosts[i],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
