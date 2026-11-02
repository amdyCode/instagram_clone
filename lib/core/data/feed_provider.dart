import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import 'mock_data.dart';

class FeedPostsNotifier extends Notifier<List<Post>> {
  @override
  List<Post> build() => List.of(mockPosts);

  void addPost(Post post) {
    mockPosts.insert(0, post);
    state = [post, ...state];
  }
}

final feedPostsProvider = NotifierProvider<FeedPostsNotifier, List<Post>>(
  FeedPostsNotifier.new,
);
