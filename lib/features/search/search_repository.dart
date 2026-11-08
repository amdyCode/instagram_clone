import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/graphql_client.dart';
import '../../core/models/post.dart';
import '../../core/models/user.dart';

abstract class SearchRepository {
  Future<List<Post>> getExplorePosts({int limit = 30, int offset = 0});
  Future<List<User>> searchUsers(String query, {int limit = 20});
}

class GraphQLSearchRepository implements SearchRepository {
  GraphQLSearchRepository({required this.client});

  final GraphQLClient client;

  static const String _explorePostsQuery = '''
    query ExplorePosts(\$limit: Int, \$offset: Int) {
      explorePosts(limit: \$limit, offset: \$offset) {
        id
        caption
        likeCount
        commentCount
        likedByMe
        createdAt
        author {
          id
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
      }
    }
  ''';

  static const String _searchUsersQuery = '''
    query SearchUsers(\$query: String!, \$limit: Int) {
      searchUsers(query: \$query, limit: \$limit) {
        id
        username
        fullName
        avatarUrl
        bio
        followerCount
        followingCount
        isMe
        isFollowing
      }
    }
  ''';

  @override
  Future<List<Post>> getExplorePosts({int limit = 30, int offset = 0}) async {
    final data = await client.query(
      _explorePostsQuery,
      variables: {'limit': limit, 'offset': offset},
    );

    final list = data['explorePosts'] as List<dynamic>? ?? [];
    return list
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<User>> searchUsers(String query, {int limit = 20}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final data = await client.query(
      _searchUsersQuery,
      variables: {'query': cleanQuery, 'limit': limit},
    );

    final list = data['searchUsers'] as List<dynamic>? ?? [];
    return list
        .map((item) => User.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final client = ref.watch(graphQLClientProvider);
  return GraphQLSearchRepository(client: client);
});
