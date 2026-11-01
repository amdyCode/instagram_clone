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
  }) {
    return Profile(
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      link: link ?? this.link,
      postCount: postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount,
      isMe: isMe,
      isFollowing: isFollowing ?? this.isFollowing,
      mutualFollowers: mutualFollowers,
      highlights: highlights,
      posts: posts,
    );
  }
}
