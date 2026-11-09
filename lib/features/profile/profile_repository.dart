import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/graphql_client.dart';
import '../../core/models/post.dart';
import '../../core/models/profile.dart';
import '../../core/models/user.dart';

abstract class ProfileRepository {
  Future<Profile?> getUserProfile(String username);
  Future<Profile?> getMyProfile();
  Future<Profile> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? link,
  });
  Future<User> follow(String userId);
  Future<User> unfollow(String userId);
}

class GraphQLProfileRepository implements ProfileRepository {
  GraphQLProfileRepository({required this.client});

  final GraphQLClient client;

  static const String _userFragment = '''
    id
    email
    username
    fullName
    bio
    link
    avatarUrl
    postCount
    followerCount
    followingCount
    isMe
    isFollowing
  ''';

  static const String _postsSubquery = '''
    posts {
      id
      caption
      likeCount
      commentCount
      likedByMe
      createdAt
      media {
        id
        url
        position
      }
    }
  ''';

  static const String _getUserProfileQuery = '''
    query GetUserProfile(\$username: String!) {
      user(username: \$username) {
        $_userFragment
        $_postsSubquery
      }
    }
  ''';

  static const String _getMyProfileQuery = '''
    query GetMyProfile {
      me {
        $_userFragment
        $_postsSubquery
      }
    }
  ''';

  static const String _updateProfileMutation = '''
    mutation UpdateProfile(\$input: UpdateProfileInput!) {
      updateProfile(input: \$input) {
        $_userFragment
      }
    }
  ''';

  static const String _followMutation = '''
    mutation Follow(\$userId: ID!) {
      follow(userId: \$userId) {
        $_userFragment
      }
    }
  ''';

  static const String _unfollowMutation = '''
    mutation Unfollow(\$userId: ID!) {
      unfollow(userId: \$userId) {
        $_userFragment
      }
    }
  ''';

  List<ProfilePost> _parseProfilePosts(dynamic rawUser) {
    if (rawUser == null || rawUser is! Map<String, dynamic>) return [];
    final rawPosts = rawUser['posts'] as List<dynamic>? ?? [];
    return rawPosts.map((p) {
      final map = p as Map<String, dynamic>;
      final media = map['media'] as List<dynamic>? ?? [];
      final firstUrl =
          media.isNotEmpty ? (media.first['url'] ?? '').toString() : '';
      return ProfilePost(
        id: (map['id'] ?? '').toString(),
        thumbnailUrl: firstUrl,
        isMultiple: media.length > 1,
      );
    }).toList();
  }

  @override
  Future<Profile?> getUserProfile(String username) async {
    final data = await client.query(
      _getUserProfileQuery,
      variables: {'username': username},
    );

    final userData = data['user'];
    if (userData == null) return null;

    final user = User.fromJson(userData as Map<String, dynamic>);
    final posts = _parseProfilePosts(userData);
    return Profile.fromUser(user, posts: posts);
  }

  @override
  Future<Profile?> getMyProfile() async {
    final data = await client.query(_getMyProfileQuery);
    final meData = data['me'];
    if (meData == null) return null;

    final user = User.fromJson(meData as Map<String, dynamic>);
    final posts = _parseProfilePosts(meData);
    return Profile.fromUser(user, posts: posts);
  }

  @override
  Future<Profile> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? link,
  }) async {
    final data = await client.mutate(
      _updateProfileMutation,
      variables: {
        'input': {
          'fullName': ?fullName,
          'bio': ?bio,
          'avatarUrl': ?avatarUrl,
          'link': ?link,
        },
      },
    );

    final userData = data['updateProfile'] as Map<String, dynamic>;
    final user = User.fromJson(userData);
    return Profile.fromUser(user);
  }

  @override
  Future<User> follow(String userId) async {
    final data = await client.mutate(
      _followMutation,
      variables: {'userId': userId},
    );

    final userData = data['follow'] as Map<String, dynamic>;
    return User.fromJson(userData);
  }

  @override
  Future<User> unfollow(String userId) async {
    final data = await client.mutate(
      _unfollowMutation,
      variables: {'userId': userId},
    );

    final userData = data['unfollow'] as Map<String, dynamic>;
    return User.fromJson(userData);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(graphQLClientProvider);
  return GraphQLProfileRepository(client: client);
});
