import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/graphql_client.dart';
import '../../core/models/comment.dart';
import '../../core/models/post.dart';

abstract class PostRepository {
  Future<Post?> getPost(String id);
  Future<Post> createPost({
    required String caption,
    required List<String> mediaUrls,
  });
  Future<bool> deletePost(String id);
  Future<List<Comment>> getComments({
    required String postId,
    int limit = 30,
    int offset = 0,
  });
  Future<Comment> addComment({required String postId, required String body});
  Future<bool> deleteComment(String id);
}

class GraphQLPostRepository implements PostRepository {
  GraphQLPostRepository({required this.client});

  final GraphQLClient client;

  static const String _postFragment = '''
    id
    caption
    likeCount
    commentCount
    likedByMe
    createdAt
    author {
      id
      email
      username
      fullName
      avatarUrl
      isMe
      isFollowing
    }
    media {
      id
      url
      position
      width
      height
    }
  ''';

  static const String _commentFragment = '''
    id
    postId
    body
    text
    createdAt
    author {
      id
      email
      username
      fullName
      avatarUrl
      isMe
    }
  ''';

  static const String _getPostQuery =
      '''
    query GetPost(\$id: ID!) {
      post(id: \$id) {
        $_postFragment
      }
    }
  ''';

  static const String _createPostMutation =
      '''
    mutation CreatePost(\$input: CreatePostInput!) {
      createPost(input: \$input) {
        $_postFragment
      }
    }
  ''';

  static const String _deletePostMutation = '''
    mutation DeletePost(\$id: ID!) {
      deletePost(id: \$id)
    }
  ''';

  static const String _getCommentsQuery =
      '''
    query GetComments(\$postId: ID!, \$limit: Int, \$offset: Int) {
      comments(postId: \$postId, limit: \$limit, offset: \$offset) {
        $_commentFragment
      }
    }
  ''';

  static const String _addCommentMutation =
      '''
    mutation AddComment(\$postId: ID!, \$body: String!) {
      addComment(postId: \$postId, body: \$body) {
        $_commentFragment
      }
    }
  ''';

  static const String _deleteCommentMutation = '''
    mutation DeleteComment(\$id: ID!) {
      deleteComment(id: \$id)
    }
  ''';

  @override
  Future<Post?> getPost(String id) async {
    final data = await client.query(_getPostQuery, variables: {'id': id});

    final postData = data['post'];
    if (postData == null) return null;
    return Post.fromJson(postData as Map<String, dynamic>);
  }

  @override
  Future<Post> createPost({
    required String caption,
    required List<String> mediaUrls,
  }) async {
    final data = await client.mutate(
      _createPostMutation,
      variables: {
        'input': {'caption': caption, 'mediaUrls': mediaUrls},
      },
    );

    final postData = data['createPost'] as Map<String, dynamic>;
    return Post.fromJson(postData);
  }

  @override
  Future<bool> deletePost(String id) async {
    final data = await client.mutate(
      _deletePostMutation,
      variables: {'id': id},
    );

    return data['deletePost'] == true;
  }

  @override
  Future<List<Comment>> getComments({
    required String postId,
    int limit = 30,
    int offset = 0,
  }) async {
    final data = await client.query(
      _getCommentsQuery,
      variables: {'postId': postId, 'limit': limit, 'offset': offset},
    );

    final list = data['comments'] as List<dynamic>? ?? [];
    return list
        .map((item) => Comment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Comment> addComment({
    required String postId,
    required String body,
  }) async {
    final data = await client.mutate(
      _addCommentMutation,
      variables: {'postId': postId, 'body': body},
    );

    final commentData = data['addComment'] as Map<String, dynamic>;
    return Comment.fromJson(commentData);
  }

  @override
  Future<bool> deleteComment(String id) async {
    final data = await client.mutate(
      _deleteCommentMutation,
      variables: {'id': id},
    );

    return data['deleteComment'] == true;
  }
}

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final client = ref.watch(graphQLClientProvider);
  return GraphQLPostRepository(client: client);
});
