import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/mock_data.dart';
import '../../core/models/post.dart';
import 'feed_repository.dart';

class FeedState {
  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FeedController extends Notifier<FeedState> {
  static const int pageSize = 10;

  @override
  FeedState build() {
    Future.microtask(() => loadFeed());
    return const FeedState(isLoading: true);
  }

  FeedRepository get _repository => ref.read(feedRepositoryProvider);

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final posts = await _repository.getFeed(limit: pageSize, offset: 0);
      state = state.copyWith(
        posts: posts.isNotEmpty ? posts : mockPosts,
        isLoading: false,
        hasMore: posts.length >= pageSize,
      );
    } catch (_) {
      state = state.copyWith(
        posts: state.posts.isNotEmpty ? state.posts : mockPosts,
        isLoading: false,
        error: 'Impossible de recuperer le feed depuis le serveur',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final posts = await _repository.getFeed(limit: pageSize, offset: 0);
      state = state.copyWith(
        posts: posts.isNotEmpty ? posts : mockPosts,
        hasMore: posts.length >= pageSize,
        clearError: true,
      );
    } catch (_) {
      // Conserve les posts existants en cas d'erreur de refresh
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final newPosts = await _repository.getFeed(
        limit: pageSize,
        offset: state.posts.length,
      );
      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        isLoadingMore: false,
        hasMore: newPosts.length >= pageSize,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> toggleLike(String postId) async {
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final currentPost = state.posts[index];
    final willBeLiked = !currentPost.likedByMe;
    final updatedCount = currentPost.likeCount + (willBeLiked ? 1 : -1);

    final optimisticPost = currentPost.copyWith(
      likedByMe: willBeLiked,
      likeCount: updatedCount < 0 ? 0 : updatedCount,
    );

    final updatedPosts = List<Post>.from(state.posts);
    updatedPosts[index] = optimisticPost;
    state = state.copyWith(posts: updatedPosts);

    try {
      final serverPost = willBeLiked
          ? await _repository.likePost(postId)
          : await _repository.unlikePost(postId);

      final confirmedPosts = List<Post>.from(state.posts);
      final confirmedIndex = confirmedPosts.indexWhere((p) => p.id == postId);
      if (confirmedIndex != -1) {
        confirmedPosts[confirmedIndex] = serverPost;
        state = state.copyWith(posts: confirmedPosts);
      }
    } catch (_) {
      final rollbackPosts = List<Post>.from(state.posts);
      final rollbackIndex = rollbackPosts.indexWhere((p) => p.id == postId);
      if (rollbackIndex != -1) {
        rollbackPosts[rollbackIndex] = currentPost;
        state = state.copyWith(posts: rollbackPosts);
      }
    }
  }

  void addPost(Post post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }
}

final feedControllerProvider = NotifierProvider<FeedController, FeedState>(
  FeedController.new,
);