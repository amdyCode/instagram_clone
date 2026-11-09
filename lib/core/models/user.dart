class User {
  const User({
    this.id,
    this.email,
    required this.username,
    this.avatarUrl,
    this.fullName,
    this.bio,
    this.link,
    this.postCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.isMe = false,
    this.isFollowing = false,
    this.isVerified = false,
  });

  final String? id;
  final String? email;
  final String username;
  final String? avatarUrl;
  final String? fullName;
  final String? bio;
  final String? link;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final bool isMe;
  final bool isFollowing;
  final bool isVerified;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      fullName: json['fullName']?.toString(),
      bio: json['bio']?.toString(),
      link: json['link']?.toString(),
      postCount: (json['postCount'] as num?)?.toInt() ?? 0,
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      isMe: json['isMe'] == true,
      isFollowing: json['isFollowing'] == true,
      isVerified: json['isVerified'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (email != null) 'email': email,
    'username': username,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    if (fullName != null) 'fullName': fullName,
    if (bio != null) 'bio': bio,
    if (link != null) 'link': link,
    'postCount': postCount,
    'followerCount': followerCount,
    'followingCount': followingCount,
    'isMe': isMe,
    'isFollowing': isFollowing,
    'isVerified': isVerified,
  };
}

class AuthPayload {
  const AuthPayload({required this.token, required this.user});

  final String token;
  final User user;

  factory AuthPayload.fromJson(Map<String, dynamic> json) {
    return AuthPayload(
      token: json['token']?.toString() ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
