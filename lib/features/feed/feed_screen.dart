import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/feed_provider.dart';
import '../../core/data/mock_data.dart';
import '../../core/widgets/common/instagram_logo.dart';
import '../../core/widgets/feed/post_card.dart';
import '../../core/widgets/feed/story_tray.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(feedPostsProvider);

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
                  tooltip: 'Creer',
                  onPressed: () => context.push('/create-post'),
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
              SliverToBoxAdapter(child: StoryTray(stories: mockStories)),
              const SliverToBoxAdapter(child: SizedBox(height: 4)),
              SliverList.builder(
                itemCount: posts.length,
                itemBuilder: (_, i) =>
                    PostCard(key: ValueKey(posts[i].id), post: posts[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
