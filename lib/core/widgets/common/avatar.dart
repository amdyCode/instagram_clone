import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.url, this.size = 32});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholder = ColoredBox(
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      child: Icon(
        Icons.person,
        size: size * 0.7,
        color: isDark ? AppColors.darkSecondary : Colors.white,
      ),
    );

    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: url == null
            ? placeholder
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                memCacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                    .round(),
                placeholder: (_, _) => placeholder,
                errorWidget: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

enum StoryRingState { unseen, closeFriends, seen, none }

class StoryRing extends StatelessWidget {
  const StoryRing({
    super.key,
    required this.child,
    required this.size,
    this.state = StoryRingState.unseen,
  });

  final double size;
  final StoryRingState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringWidth = state == StoryRingState.seen ? size * 0.025 : size * 0.04;
    final gap = size * 0.04;

    final decoration = switch (state) {
      StoryRingState.unseen => const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.storyGradient,
      ),
      StoryRingState.closeFriends => const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.closeFriends,
      ),
      StoryRingState.seen => BoxDecoration(
        shape: BoxShape.circle,
        color: theme.dividerColor,
      ),
      StoryRingState.none => const BoxDecoration(),
    };

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: decoration,
        child: Padding(
          padding: EdgeInsets.all(ringWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.scaffoldBackgroundColor,
            ),
            child: Padding(
              padding: EdgeInsets.all(gap),
              child: FittedBox(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
