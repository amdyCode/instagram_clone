import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../theme/app_colors.dart';
import '../common/avatar.dart';

class UserSearchTile extends StatelessWidget {
  const UserSearchTile({
    super.key,
    required this.user,
    required this.onTap,
    this.onRemove,
    this.isRecent = false,
  });

  final User user;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool isRecent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Avatar(url: user.avatarUrl, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 15,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  if (user.fullName != null && user.fullName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.fullName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: secondaryColor),
                    ),
                  ],
                ],
              ),
            ),
            if (isRecent && onRemove != null)
              IconButton(
                icon: Icon(Icons.close, size: 18, color: secondaryColor),
                onPressed: onRemove,
                splashRadius: 20,
              ),
          ],
        ),
      ),
    );
  }
}
