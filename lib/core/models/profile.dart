import 'post.dart';
import 'story.dart';
import 'user.dart';

class Profile {
  const Profile({
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    required this.bio,
    this.link,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    this.isMe = false,
    this.isFollowing = false,
    this.mutualFollowers = const [],
    this.highlights = const [],
    this.posts = const [],
  });

  final String username;
  final String fullName;
  final String? avatarUrl;
  final String bio;
  final String? link;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final bool isMe;
  final bool isFollowing;
  final List<User> mutualFollowers;
  final List<Highlight> highlights;
  final List<ProfilePost> posts;

  Profile copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? link,
    bool? isFollowing,
    int? followerCount,
    int? postCount,
    List<ProfilePost>? posts,
  }) {
    return Profile(
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      link: link ?? this.link,
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount,
      isMe: isMe,
      isFollowing: isFollowing ?? this.isFollowing,
      mutualFollowers: mutualFollowers,
      highlights: highlights,
      posts: posts ?? this.posts,
    );
  }

  factory Profile.fromUser(
    User user, {
    List<ProfilePost>? posts,
    List<Highlight>? highlights,
  }) {
    return Profile(
      username: user.username,
      fullName: user.fullName ?? user.username,
      avatarUrl: user.avatarUrl,
      bio: user.bio ?? '',
      link: user.link,
      postCount: user.postCount,
      followerCount: user.followerCount,
      followingCount: user.followingCount,
      isMe: user.isMe,
      isFollowing: user.isFollowing,
      highlights: highlights ?? const [],
      posts: posts ?? const [],
    );
  }
}
