import 'user.dart';

class Story {
  const Story({
    required this.user,
    this.closeFriends = false,
    this.seen = false,
  });

  final User user;
  final bool closeFriends;
  final bool seen;
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
