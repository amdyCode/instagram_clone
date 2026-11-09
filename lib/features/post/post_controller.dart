import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/comment.dart';
import '../../core/models/post.dart';
import 'post_repository.dart';

class PostActionState {
  const PostActionState({this.isLoading = false, this.error, this.createdPost});

  final bool isLoading;
  final String? error;
  final Post? createdPost;

  PostActionState copyWith({
    bool? isLoading,
    String? error,
    Post? createdPost,
    bool clearError = false,
  }) {
    return PostActionState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      createdPost: createdPost ?? this.createdPost,
    );
  }
}

class PostController extends Notifier<PostActionState> {
  @override
  PostActionState build() => const PostActionState();

  PostRepository get _repository => ref.read(postRepositoryProvider);

  Future<Post?> createPost({
    required String caption,
    required List<String> mediaUrls,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final post = await _repository.createPost(
        caption: caption,
        mediaUrls: mediaUrls,
      );
      state = state.copyWith(isLoading: false, createdPost: post);
      return post;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur inattendue lors de la publication',
      );
      return null;
    }
  }

  Future<bool> deletePost(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ok = await _repository.deletePost(id);
      state = state.copyWith(isLoading: false);
      return ok;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de supprimer la publication',
      );
      return false;
    }
  }
}

final postControllerProvider =
    NotifierProvider<PostController, PostActionState>(PostController.new);

final postDetailProvider = FutureProvider.family<Post?, String>((
  ref,
  postId,
) async {
  final repo = ref.watch(postRepositoryProvider);
  return repo.getPost(postId);
});

class CommentsState {
  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  final List<Comment> comments;
  final bool isLoading;
  final String? error;

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CommentsNotifier extends Notifier<CommentsState> {
  CommentsNotifier(this.postId);

  final String postId;

  @override
  CommentsState build() {
    Future.microtask(() => loadComments());
    return const CommentsState(isLoading: true);
  }

  PostRepository get _repository => ref.read(postRepositoryProvider);

  Future<void> loadComments() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getComments(postId: postId);
      state = state.copyWith(comments: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de charger les commentaires',
      );
    }
  }

  Future<Comment?> addComment(String body) async {
    try {
      final comment = await _repository.addComment(postId: postId, body: body);
      state = state.copyWith(comments: [...state.comments, comment]);
      return comment;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      final ok = await _repository.deleteComment(commentId);
      if (ok) {
        state = state.copyWith(
          comments: state.comments.where((c) => c.id != commentId).toList(),
        );
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

final commentsControllerProvider =
    NotifierProvider.family<CommentsNotifier, CommentsState, String>(
      CommentsNotifier.new,
    );
