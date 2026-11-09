import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_clone/core/models/story.dart';

import '../../../features/auth/auth_controller.dart';
import '../common/avatar.dart';

class StoryTray extends StatelessWidget {
  const StoryTray({super.key, this.stories = const []});

  final List<Story> stories;

  static const _ringSize = 84.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: stories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) => i == 0
            ? const _YourStory()
            : _StoryItem(
                story: stories[i - 1],
                onTap: () => context.push('/story/${i - 1}'),
              ),
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  const _StoryItem({required this.story, required this.onTap});

  final Story story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = story.seen
        ? StoryRingState.seen
        : story.closeFriends
        ? StoryRingState.closeFriends
        : StoryRingState.unseen;

    return GestureDetector(
      onTap: onTap,
      child: _Labeled(
        label: story.user.username,
        dimmed: story.seen,
        child: StoryRing(
          size: StoryTray._ringSize,
          state: state,
          child: Avatar(url: story.user.avatarUrl, size: 100),
        ),
      ),
    );
  }
}

class _YourStory extends ConsumerWidget {
  const _YourStory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).user;
    return _Labeled(
      label: 'Votre story',
      dimmed: true,
      child: SizedBox.square(
        dimension: StoryTray._ringSize,
        child: Stack(
          children: [
            StoryRing(
              size: StoryTray._ringSize,
              state: StoryRingState.none,
              child: Avatar(url: user?.avatarUrl, size: 100),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 2.5,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: theme.scaffoldBackgroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({
    required this.label,
    required this.child,
    this.dimmed = false,
  });

  final String label;
  final Widget child;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: StoryTray._ringSize,
      child: Column(
        children: [
          child,
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: dimmed ? scheme.onSurfaceVariant : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
