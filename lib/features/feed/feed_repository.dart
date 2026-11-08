import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/graphql_client.dart';
import '../../core/models/post.dart';

abstract class FeedRepository {
  Future<List<Post>> getFeed({int limit = 10, int offset = 0});
  Future<Post> likePost(String postId);
  Future<Post> unlikePost(String postId);
}

class GraphQLFeedRepository implements FeedRepository {
  GraphQLFeedRepository({required this.client});

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

  static const String _feedQuery = '''
    query Feed(\$limit: Int, \$offset: Int) {
      feed(limit: \$limit, offset: \$offset) {
        $_postFragment
      }
    }
  ''';

  static const String _likeMutation = '''
    mutation LikePost(\$postId: ID!) {
      likePost(postId: \$postId) {
        $_postFragment
      }
    }
  ''';

  static const String _unlikeMutation = '''
    mutation UnlikePost(\$postId: ID!) {
      unlikePost(postId: \$postId) {
        $_postFragment
      }
    }
  ''';

  @override
  Future<List<Post>> getFeed({int limit = 10, int offset = 0}) async {
    final data = await client.query(
      _feedQuery,
      variables: {
        'limit': limit,
        'offset': offset,
      },
    );

    final rawList = data['feed'] as List<dynamic>? ?? [];
    return rawList
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Post> likePost(String postId) async {
    final data = await client.mutate(
      _likeMutation,
      variables: {'postId': postId},
    );

    final postData = data['likePost'] as Map<String, dynamic>;
    return Post.fromJson(postData);
  }

  @override
  Future<Post> unlikePost(String postId) async {
    final data = await client.mutate(
      _unlikeMutation,
      variables: {'postId': postId},
    );

    final postData = data['unlikePost'] as Map<String, dynamic>;
    return Post.fromJson(postData);
  }
}

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final client = ref.watch(graphQLClientProvider);
  return GraphQLFeedRepository(client: client);
});