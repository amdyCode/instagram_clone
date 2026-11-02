import 'media.dart';
import 'user.dart';

class Post {
  const Post({
    required this.id,
    required this.author,
    required this.media,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.repostCount,
    required this.shareCount,
    this.likedBy = const [],
    required this.createdAt,
    this.likedByMe = false,
    this.savedByMe = false,
  });

  final String id;
  final User author;
  final List<Media> media;
  final String caption;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int shareCount;
  final List<User> likedBy;
  final DateTime createdAt;
  final bool likedByMe;
  final bool savedByMe;
}

class ProfilePost {
  const ProfilePost({
    required this.id,
    required this.thumbnailUrl,
    this.isMultiple = false,
    this.isVideo = false,
  });

  final String id;
  final String thumbnailUrl;
  final bool isMultiple;
  final bool isVideo;
}
