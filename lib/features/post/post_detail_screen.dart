import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/mock_data.dart';
import '../../core/widgets/feed/post_card.dart';
import '../feed/feed_controller.dart';
import 'post_controller.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Publications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: postAsync.when(
        data: (apiPost) {
          final post = apiPost ?? getPostById(postId);
          return SingleChildScrollView(
            child: PostCard(
              key: ValueKey(post.id),
              post: post,
              onLikeToggle: () => ref
                  .read(feedControllerProvider.notifier)
                  .toggleLike(post.id),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        error: (_, _) {
          final post = getPostById(postId);
          return SingleChildScrollView(
            child: PostCard(
              key: ValueKey(post.id),
              post: post,
              onLikeToggle: () => ref
                  .read(feedControllerProvider.notifier)
                  .toggleLike(post.id),
            ),
          );
        },
      ),
    );
  }
}
