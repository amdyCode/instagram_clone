library;

class FakeUser {
  const FakeUser(this.username, this.avatarUrl);
  final String username;
  final String? avatarUrl;
}

class FakeStory {
  const FakeStory(this.user, {this.closeFriends = false, this.seen = false});
  final FakeUser user;
  final bool closeFriends;
  final bool seen;
}

class FakeMedia {
  const FakeMedia(this.url, {this.width = 1080, this.height = 1350});
  final String url;
  final int width;
  final int height;
}

class FakePost {
  const FakePost({
    required this.id,
    required this.author,
    required this.media,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.repostCount,
    required this.shareCount,
    required this.likedBy,
    required this.createdAt,
    this.likedByMe = false,
    this.savedByMe = false,
  });

  final String id;
  final FakeUser author;
  final List<FakeMedia> media;
  final String caption;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int shareCount;
  final List<FakeUser> likedBy;
  final DateTime createdAt;
  final bool likedByMe;
  final bool savedByMe;
}

FakeMedia _photo(String seed, {int h = 1350}) =>
    FakeMedia('https://picsum.photos/seed/$seed/1080/$h', height: h);

const me = FakeUser('moi', 'https://i.pravatar.cc/150?img=68');

const _users = [
  FakeUser('jaded.elephant17', 'https://i.pravatar.cc/150?img=3'),
  FakeUser('paisley.print48', 'https://i.pravatar.cc/150?img=5'),
  FakeUser('cake_baker', 'https://i.pravatar.cc/150?img=9'),
  FakeUser('lil_wyatt838', 'https://i.pravatar.cc/150?img=12'),
  FakeUser('alex.anyways18', 'https://i.pravatar.cc/150?img=15'),
  FakeUser('jiho100x', 'https://i.pravatar.cc/150?img=20'),
  FakeUser('kenzoere', 'https://i.pravatar.cc/150?img=33'),
];

final fakeStories = [
  FakeStory(_users[0], closeFriends: true),
  FakeStory(_users[1]),
  FakeStory(_users[2]),
  FakeStory(_users[6]),
  FakeStory(_users[5], seen: true),
];

final fakePosts = [
  FakePost(
    id: 'p1',
    author: _users[3],
    media: List.generate(8, (i) => _photo('skate$i')),
    caption: 'Good times. Great vibes. 🛹',
    likeCount: 36200,
    commentCount: 749,
    repostCount: 370,
    shareCount: 41600,
    likedBy: [_users[5], _users[1], _users[2]],
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  FakePost(
    id: 'p2',
    author: _users[1],
    media: [_photo('cow', h: 1080)],
    caption:
        'Petite balade à la ferme ce week-end, on a rencontré la star '
        'du coin. Elle a posé pendant dix bonnes minutes sans bouger, '
        'une vraie professionnelle 🐮 #ferme #weekend',
    likeCount: 1284,
    commentCount: 56,
    repostCount: 4,
    shareCount: 23,
    likedBy: [_users[0], _users[4]],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    likedByMe: true,
  ),
  FakePost(
    id: 'p3',
    author: _users[2],
    media: [_photo('cake1'), _photo('cake2')],
    caption: 'Nouveau gâteau du jour 🍰',
    likeCount: 532,
    commentCount: 18,
    repostCount: 0,
    shareCount: 7,
    likedBy: [_users[6]],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];
