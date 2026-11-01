import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../utils/formatters.dart';
import '../common/avatar.dart';

class StoryHeader extends StatelessWidget {
  const StoryHeader({
    super.key,
    required this.user,
    required this.createdAt,
    this.closeFriends = false,
    required this.onClose,
    this.onUserTap,
  });

  final User user;
  final DateTime createdAt;
  final bool closeFriends;
  final VoidCallback onClose;
  final VoidCallback? onUserTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: onUserTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StoryRing(
                  size: 34,
                  state: closeFriends
                      ? StoryRingState.closeFriends
                      : StoryRingState.none,
                  child: Avatar(url: user.avatarUrl, size: 30),
                ),
                const SizedBox(width: 10),
                Text(
                  user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeAgo(createdAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Fermer la story',
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}
