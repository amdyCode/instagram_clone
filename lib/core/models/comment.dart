import 'user.dart';

class Comment {
  const Comment({
    required this.id,
    this.postId = '',
    required this.author,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.likedByMe = false,
  });

  final String id;
  final String postId;
  final User author;
  final String text;
  final DateTime createdAt;
  final int likeCount;
  final bool likedByMe;

  Comment copyWith({
    String? id,
    String? postId,
    User? author,
    String? text,
    DateTime? createdAt,
    int? likeCount,
    bool? likedByMe,
  }) => Comment(
    id: id ?? this.id,
    postId: postId ?? this.postId,
    author: author ?? this.author,
    text: text ?? this.text,
    createdAt: createdAt ?? this.createdAt,
    likeCount: likeCount ?? this.likeCount,
    likedByMe: likedByMe ?? this.likedByMe,
  );

  factory Comment.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final dateRaw = json['createdAt'];
    if (dateRaw is String) {
      parsedDate = DateTime.tryParse(dateRaw) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Comment(
      id: (json['id'] ?? '').toString(),
      postId: (json['postId'] ?? '').toString(),
      author: json['author'] != null
          ? User.fromJson(json['author'] as Map<String, dynamic>)
          : const User(username: 'anonymous'),
      text: (json['text'] ?? json['body'] ?? '') as String,
      createdAt: parsedDate,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      likedByMe: json['likedByMe'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'author': author.toJson(),
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'likeCount': likeCount,
    'likedByMe': likedByMe,
  };
}
