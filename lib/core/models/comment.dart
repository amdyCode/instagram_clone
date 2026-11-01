import 'user.dart';

class Comment {
  const Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.likedByMe = false,
  });

  final String id;
  final User author;
  final String text;
  final DateTime createdAt;
  final int likeCount;
  final bool likedByMe;

  Comment copyWith({int? likeCount, bool? likedByMe}) => Comment(
    id: id,
    author: author,
    text: text,
    createdAt: createdAt,
    likeCount: likeCount ?? this.likeCount,
    likedByMe: likedByMe ?? this.likedByMe,
  );
}
