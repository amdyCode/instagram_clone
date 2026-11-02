class User {
  const User({
    required this.username,
    this.avatarUrl,
    this.fullName,
    this.isVerified = false,
  });

  final String username;
  final String? avatarUrl;
  final String? fullName;
  final bool isVerified;
}
