import 'package:flutter/material.dart';
import 'package:instagram_clone/core/models/profile.dart';
import 'package:instagram_clone/core/models/user.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../common/avatar.dart';
import 'profile_action_button.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onFollowToggle,
    this.onMessageTap,
    this.onEditProfileTap,
    this.onShareProfileTap,
  });

  final Profile profile;
  final VoidCallback onFollowToggle;
  final VoidCallback? onMessageTap;
  final VoidCallback? onEditProfileTap;
  final VoidCallback? onShareProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final secondary = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne supérieure : Avatar + 3 Compteurs
          Row(
            children: [
              _ProfileAvatar(avatarUrl: profile.avatarUrl, isMe: profile.isMe),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatColumn(
                      count: profile.postCount,
                      label: 'Publications',
                    ),
                    _StatColumn(count: profile.followerCount, label: 'Abonnés'),
                    _StatColumn(
                      count: profile.followingCount,
                      label: 'Abonnements',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (profile.fullName.isNotEmpty)
            Text(
              profile.fullName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              profile.bio,
              style: TextStyle(fontSize: 14, height: 1.3, color: onSurface),
            ),
          ],

          if (profile.link != null && profile.link!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.link, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  profile.link!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],

          if (!profile.isMe && profile.mutualFollowers.isNotEmpty) ...[
            const SizedBox(height: 10),
            _MutualFollowers(
              mutuals: profile.mutualFollowers,
              textColor: secondary,
            ),
          ],
          const SizedBox(height: 14),

          if (profile.isMe)
            Row(
              children: [
                Expanded(
                  child: ProfileActionButton(
                    label: 'Modifier le profil',
                    onPressed: onEditProfileTap ?? () {},
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ProfileActionButton(
                    label: 'Partager le profil',
                    onPressed: onShareProfileTap ?? () {},
                  ),
                ),
                const SizedBox(width: 6),
                ProfileIconButton(
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  tooltip: 'Découvrir des personnes',
                  onPressed: () {},
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: ProfileActionButton(
                    label: profile.isFollowing ? 'Abonné(e)' : 'Suivre',
                    variant: profile.isFollowing
                        ? ProfileButtonVariant.secondary
                        : ProfileButtonVariant.primary,
                    onPressed: onFollowToggle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ProfileActionButton(
                    label: 'Message',
                    onPressed: onMessageTap ?? () {},
                  ),
                ),
                const SizedBox(width: 6),
                ProfileIconButton(
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  tooltip: 'Suggestions',
                  onPressed: () {},
                ),
              ],
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl, required this.isMe});

  final String? avatarUrl;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox.square(
      dimension: 84,
      child: Stack(
        children: [
          Avatar(url: avatarUrl, size: 84),
          if (isMe)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatCount(count),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _MutualFollowers extends StatelessWidget {
  const _MutualFollowers({required this.mutuals, required this.textColor});

  final List<User> mutuals;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final shown = mutuals.take(3).toList();
    const avatarSize = 18.0;
    const overlap = 6.0;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Row(
      children: [
        SizedBox(
          width: avatarSize + (shown.length - 1) * (avatarSize - overlap),
          height: avatarSize,
          child: Stack(
            children: [
              for (var i = shown.length - 1; i >= 0; i--)
                Positioned(
                  left: i * (avatarSize - overlap),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: bg, width: 1.5),
                    ),
                    child: Avatar(
                      url: shown[i].avatarUrl,
                      size: avatarSize - 3,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: textColor),
              children: [
                const TextSpan(text: 'Suivi(e) par '),
                TextSpan(
                  text: shown.first.username,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (shown.length > 1) ...[
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: shown[1].username,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
                const TextSpan(text: ' et d’autres'),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
