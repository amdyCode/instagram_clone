import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/models/post.dart';
import '../../core/widgets/feed/post_card.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    final Post post = getPostById(postId);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Publications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: PostCard(key: ValueKey(post.id), post: post),
      ),
    );
  }
}
