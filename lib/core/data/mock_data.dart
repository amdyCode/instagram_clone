import 'package:instagram_clone/core/models/media.dart';
import 'package:instagram_clone/core/models/post.dart';
import 'package:instagram_clone/core/models/profile.dart';
import 'package:instagram_clone/core/models/story.dart';
import 'package:instagram_clone/core/models/user.dart';

Media _photo(String seed, {int h = 1350}) =>
    Media(url: 'https://picsum.photos/seed/$seed/1080/$h', height: h);

const me = User(username: 'moi', avatarUrl: 'https://i.pravatar.cc/150?img=68');

const mockUsers = [
  User(
    username: 'jaded.elephant17',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
  ),
  User(
    username: 'paisley.print48',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
  ),
  User(username: 'cake_baker', avatarUrl: 'https://i.pravatar.cc/150?img=9'),
  User(username: 'lil_wyatt838', avatarUrl: 'https://i.pravatar.cc/150?img=12'),
  User(
    username: 'alex.anyways18',
    avatarUrl: 'https://i.pravatar.cc/150?img=15',
  ),
  User(username: 'jiho100x', avatarUrl: 'https://i.pravatar.cc/150?img=20'),
  User(username: 'kenzoere', avatarUrl: 'https://i.pravatar.cc/150?img=33'),
];

final mockStories = [
  Story(
    user: mockUsers[0],
    closeFriends: true,
    items: [
      StoryItem(
        id: 's0_1',
        mediaUrl: 'https://picsum.photos/seed/elephant_story1/1080/1920',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        caption: 'Session de skate au coucher du soleil 🛹',
      ),
      StoryItem(
        id: 's0_2',
        mediaUrl: 'https://picsum.photos/seed/elephant_story2/1080/1920',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  ),
  Story(
    user: mockUsers[1],
    items: [
      StoryItem(
        id: 's1_1',
        mediaUrl: 'https://picsum.photos/seed/paisley_story1/1080/1920',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        caption: 'En balade à la campagne 🌾',
      ),
      StoryItem(
        id: 's1_2',
        mediaUrl: 'https://picsum.photos/seed/paisley_story2/1080/1920',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      StoryItem(
        id: 's1_3',
        mediaUrl: 'https://picsum.photos/seed/paisley_story3/1080/1920',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
  ),
  Story(
    user: mockUsers[2],
    items: [
      StoryItem(
        id: 's2_1',
        mediaUrl: 'https://picsum.photos/seed/cake_story1/1080/1920',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        caption: 'Nouveau gâteau en préparation 🍰',
      ),
    ],
  ),
  Story(
    user: mockUsers[6],
    items: [
      StoryItem(
        id: 's6_1',
        mediaUrl: 'https://picsum.photos/seed/kenzo_story1/1080/1920',
        createdAt: DateTime.now().subtract(const Duration(hours: 11)),
      ),
      StoryItem(
        id: 's6_2',
        mediaUrl: 'https://picsum.photos/seed/kenzo_story2/1080/1920',
        createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      ),
    ],
  ),
  Story(
    user: mockUsers[5],
    seen: true,
    items: [
      StoryItem(
        id: 's5_1',
        mediaUrl: 'https://picsum.photos/seed/jiho_story1/1080/1920',
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      ),
    ],
  ),
];

final mockPosts = [
  Post(
    id: 'p1',
    author: mockUsers[3],
    media: List.generate(8, (i) => _photo('skate$i')),
    caption: 'Good times. Great vibes. 🛹',
    likeCount: 36200,
    commentCount: 749,
    repostCount: 370,
    shareCount: 41600,
    likedBy: [mockUsers[5], mockUsers[1], mockUsers[2]],
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  Post(
    id: 'p2',
    author: mockUsers[1],
    media: [_photo('cow', h: 1080)],
    caption:
        'Petite balade à la ferme ce week-end, on a rencontré la star '
        'du coin. Elle a posé pendant dix bonnes minutes sans bouger, '
        'une vraie professionnelle 🐮 #ferme #weekend',
    likeCount: 1284,
    commentCount: 56,
    repostCount: 4,
    shareCount: 23,
    likedBy: [mockUsers[0], mockUsers[4]],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    likedByMe: true,
  ),
  Post(
    id: 'p3',
    author: mockUsers[2],
    media: [_photo('cake1'), _photo('cake2')],
    caption: 'Nouveau gâteau du jour 🍰',
    likeCount: 532,
    commentCount: 18,
    repostCount: 0,
    shareCount: 7,
    likedBy: [mockUsers[6]],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

final sampleOtherProfile = Profile(
  username: 'alex.anyways18',
  fullName: 'Alexandre Martin',
  avatarUrl: 'https://i.pravatar.cc/150?img=15',
  bio: 'Photographe urbain & skateur amateur 🛹\nCapturer les instants bruts.',
  link: 'linktr.ee/alexanyways',
  postCount: 54,
  followerCount: 14200,
  followingCount: 382,
  isMe: false,
  isFollowing: false,
  mutualFollowers: [mockUsers[0], mockUsers[1], mockUsers[2]],
  highlights: const [
    Highlight(
      id: 'h1',
      title: 'Skate 🛹',
      coverUrl: 'https://picsum.photos/seed/skate1/300/300',
    ),
    Highlight(
      id: 'h2',
      title: 'Voyages ✈️',
      coverUrl: 'https://picsum.photos/seed/travel/300/300',
    ),
    Highlight(
      id: 'h3',
      title: 'Paris 🇫🇷',
      coverUrl: 'https://picsum.photos/seed/paris/300/300',
    ),
    Highlight(
      id: 'h4',
      title: 'Pellicules',
      coverUrl: 'https://picsum.photos/seed/film/300/300',
    ),
    Highlight(
      id: 'h5',
      title: 'Spots',
      coverUrl: 'https://picsum.photos/seed/spots/300/300',
    ),
  ],
  posts: List.generate(
    18,
    (i) => ProfilePost(
      id: 'post_$i',
      thumbnailUrl: 'https://picsum.photos/seed/grid_$i/400/400',
      isMultiple: i % 4 == 0,
      isVideo: i % 6 == 2,
    ),
  ),
);

final sampleMyProfile = Profile(
  username: me.username,
  fullName: 'Mon Profil',
  avatarUrl: me.avatarUrl,
  bio:
      'Développeur Flutter & explorateur de code 🚀\nEn train de cloner Instagram.',
  link: 'github.com/mon-profil',
  postCount: 12,
  followerCount: 840,
  followingCount: 420,
  isMe: true,
  isFollowing: false,
  highlights: const [
    Highlight(
      id: 'mh1',
      title: 'Projets 💻',
      coverUrl: 'https://picsum.photos/seed/project/300/300',
    ),
    Highlight(
      id: 'mh2',
      title: 'Setup 🎧',
      coverUrl: 'https://picsum.photos/seed/setup/300/300',
    ),
  ],
  posts: List.generate(
    12,
    (i) => ProfilePost(
      id: 'my_post_$i',
      thumbnailUrl: 'https://picsum.photos/seed/mygrid_$i/400/400',
      isMultiple: i % 3 == 0,
    ),
  ),
);
