import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/mock_data.dart';
import '../../core/widgets/common/instagram_logo.dart';
import '../../core/widgets/feed/post_card.dart';
import '../../core/widgets/feed/story_tray.dart';
import 'feed_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedControllerProvider);
    final posts = feedState.posts;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 400) {
              ref.read(feedControllerProvider.notifier).loadMore();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(feedControllerProvider.notifier).refresh(),
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
                if (feedState.isLoading && posts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: posts.length,
                    itemBuilder: (_, i) {
                      final post = posts[i];
                      return PostCard(
                        key: ValueKey(post.id),
                        post: post,
                        onLikeToggle: () => ref
                            .read(feedControllerProvider.notifier)
                            .toggleLike(post.id),
                      );
                    },
                  ),
                if (feedState.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
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
