import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/core/models/story.dart';
import '../../theme/app_colors.dart';

class StoryHighlights extends StatelessWidget {
  const StoryHighlights({
    super.key,
    required this.highlights,
    this.isMe = false,
    this.onAddTap,
    this.onHighlightTap,
  });

  final List<Highlight> highlights;
  final bool isMe;
  final VoidCallback? onAddTap;
  final ValueChanged<Highlight>? onHighlightTap;

  static const _circleSize = 64.0;

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty && !isMe) return const SizedBox.shrink();

    final count = highlights.length + (isMe ? 1 : 0);

    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (isMe && index == 0) {
            return _NewHighlightButton(onTap: onAddTap ?? () {});
          }
          final h = highlights[isMe ? index - 1 : index];
          return _HighlightItem(
            highlight: h,
            onTap: () => onHighlightTap?.call(h),
          );
        },
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  const _HighlightItem({required this.highlight, required this.onTap});

  final Highlight highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: StoryHighlights._circleSize,
        child: Column(
          children: [
            Container(
              width: StoryHighlights._circleSize,
              height: StoryHighlights._circleSize,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider,
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: highlight.coverUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => ColoredBox(
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                  ),
                  errorWidget: (_, _, _) => ColoredBox(
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              highlight.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewHighlightButton extends StatelessWidget {
  const _NewHighlightButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: StoryHighlights._circleSize,
        child: Column(
          children: [
            Container(
              width: StoryHighlights._circleSize,
              height: StoryHighlights._circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 28,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Nouveau',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
