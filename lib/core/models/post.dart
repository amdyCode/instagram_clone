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
    this.repostCount = 0,
    this.shareCount = 0,
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

  Post copyWith({
    String? id,
    User? author,
    List<Media>? media,
    String? caption,
    int? likeCount,
    int? commentCount,
    int? repostCount,
    int? shareCount,
    List<User>? likedBy,
    DateTime? createdAt,
    bool? likedByMe,
    bool? savedByMe,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      media: media ?? this.media,
      caption: caption ?? this.caption,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      repostCount: repostCount ?? this.repostCount,
      shareCount: shareCount ?? this.shareCount,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      likedByMe: likedByMe ?? this.likedByMe,
      savedByMe: savedByMe ?? this.savedByMe,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    final mediaRaw = json['media'] as List<dynamic>? ?? [];
    final mediaList = mediaRaw
        .map((m) => Media.fromJson(m as Map<String, dynamic>))
        .toList();

    DateTime parsedDate;
    final dateRaw = json['createdAt'];
    if (dateRaw is String) {
      parsedDate = DateTime.tryParse(dateRaw) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Post(
      id: (json['id'] ?? '').toString(),
      author: json['author'] != null
          ? User.fromJson(json['author'] as Map<String, dynamic>)
          : const User(username: 'anonymous'),
      media: mediaList,
      caption: (json['caption'] ?? '') as String,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      repostCount: (json['repostCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      likedByMe: json['likedByMe'] == true,
      savedByMe: json['savedByMe'] == true,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'media': media.map((m) => m.toJson()).toList(),
    'caption': caption,
    'likeCount': likeCount,
    'commentCount': commentCount,
    'repostCount': repostCount,
    'shareCount': shareCount,
    'likedByMe': likedByMe,
    'savedByMe': savedByMe,
    'createdAt': createdAt.toIso8601String(),
  };

  ProfilePost toProfilePost() => ProfilePost(
    id: id,
    thumbnailUrl: media.isNotEmpty ? media.first.url : '',
    isMultiple: media.length > 1,
  );
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
