import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../theme/app_colors.dart';

class ExploreGrid extends StatelessWidget {
  const ExploreGrid({super.key, required this.posts, required this.onPostTap});

  final List<ProfilePost> posts;
  final ValueChanged<ProfilePost> onPostTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cacheSize =
        ((MediaQuery.sizeOf(context).width / 3) *
                MediaQuery.devicePixelRatioOf(context))
            .round();

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () => onPostTap(post),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: post.thumbnailUrl,
                fit: BoxFit.cover,
                memCacheWidth: cacheSize,
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
              if (post.isMultiple)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    Icons.collections,
                    size: 18,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                  ),
                ),
              if (post.isVideo)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    Icons.play_arrow,
                    size: 20,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                  ),
                ),
            ],
          ),
        );
      }, childCount: posts.length),
    );
  }
}
