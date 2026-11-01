import 'user.dart';

class StoryItem {
  const StoryItem({
    required this.id,
    required this.mediaUrl,
    required this.createdAt,
    this.caption,
    this.isLiked = false,
  });

  final String id;
  final String mediaUrl;
  final DateTime createdAt;
  final String? caption;
  final bool isLiked;

  StoryItem copyWith({bool? isLiked}) => StoryItem(
    id: id,
    mediaUrl: mediaUrl,
    createdAt: createdAt,
    caption: caption,
    isLiked: isLiked ?? this.isLiked,
  );
}

class Story {
  const Story({
    required this.user,
    this.items = const [],
    this.closeFriends = false,
    this.seen = false,
  });

  final User user;
  final List<StoryItem> items;
  final bool closeFriends;
  final bool seen;

  Story copyWith({List<StoryItem>? items, bool? seen}) => Story(
    user: user,
    items: items ?? this.items,
    closeFriends: closeFriends,
    seen: seen ?? this.seen,
  );
}

class Highlight {
  const Highlight({
    required this.id,
    required this.title,
    required this.coverUrl,
  });

  final String id;
  final String title;
  final String coverUrl;
}
