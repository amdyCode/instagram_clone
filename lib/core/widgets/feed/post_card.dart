import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_clone/core/models/media.dart';
import 'package:instagram_clone/core/models/post.dart';
import 'package:instagram_clone/core/models/user.dart';

import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../common/avatar.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _liked = widget.post.likedByMe;
  late bool _saved = widget.post.savedByMe;
  int _page = 0;

  int get _likeCount =>
      widget.post.likeCount +
      (_liked == widget.post.likedByMe ? 0 : (_liked ? 1 : -1));

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(author: post.author),
        _Media(
          media: post.media,
          page: _page,
          onPageChanged: (i) => setState(() => _page = i),
        ),
        _Actions(
          liked: _liked,
          saved: _saved,
          likeCount: _likeCount,
          commentCount: post.commentCount,
          repostCount: post.repostCount,
          shareCount: post.shareCount,
          pageCount: post.media.length,
          page: _page,
          onLike: () => setState(() => _liked = !_liked),
          onSave: () => setState(() => _saved = !_saved),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.likedBy.isNotEmpty)
                _LikedBy(users: post.likedBy, total: _likeCount),
              const SizedBox(height: 4),
              _Caption(username: post.author.username, caption: post.caption),
              const SizedBox(height: 6),
              if (post.commentCount > 0)
                _Muted(
                  'Voir les ${formatCount(post.commentCount)} commentaires',
                ),
              const SizedBox(height: 4),
              _Muted(timeAgo(post.createdAt), fontSize: 12),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.author});

  final User author;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/u/${author.username}'),
            child: StoryRing(
              size: 38,
              child: Avatar(url: author.avatarUrl, size: 64),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/u/${author.username}'),
              child: Text(
                author.username,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: "Plus d'options",
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }
}

class _Media extends StatelessWidget {
  const _Media({
    required this.media,
    required this.page,
    required this.onPageChanged,
  });

  final List<Media> media;
  final int page;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final first = media.first;
    final placeholder = ColoredBox(color: Theme.of(context).dividerColor);
    final cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .round();

    return AspectRatio(
      aspectRatio: first.width / first.height,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: media.length,
            onPageChanged: onPageChanged,
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: media[i].url,
              fit: BoxFit.cover,
              memCacheWidth: cacheWidth,
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => placeholder,
            ),
          ),
          if (media.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  child: Text(
                    '${page + 1}/${media.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.liked,
    required this.saved,
    required this.likeCount,
    required this.commentCount,
    required this.repostCount,
    required this.shareCount,
    required this.pageCount,
    required this.page,
    required this.onLike,
    required this.onSave,
  });

  final bool liked;
  final bool saved;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int shareCount;
  final int pageCount;
  final int page;
  final VoidCallback onLike;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              const SizedBox(width: 4),
              _ActionButton(
                tooltip: liked ? 'Je n’aime plus' : 'J’aime',
                count: likeCount,
                onTap: onLike,
                icon: AnimatedScale(
                  scale: liked ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    size: 27,
                    color: liked ? AppColors.like : onSurface,
                  ),
                ),
              ),
              _ActionButton(
                tooltip: 'Commenter',
                count: commentCount,
                onTap: () {},
                icon: FaIcon(
                  FontAwesomeIcons.comment,
                  size: 22,
                  color: onSurface,
                ),
              ),
              _ActionButton(
                tooltip: 'Republier',
                count: repostCount,
                onTap: () {},
                icon: Icon(Icons.repeat_rounded, size: 26, color: onSurface),
              ),
              _ActionButton(
                tooltip: 'Partager',
                count: shareCount,
                onTap: () {},
                icon: FaIcon(
                  FontAwesomeIcons.paperPlane,
                  size: 21,
                  color: onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: saved ? 'Retirer des enregistrements' : 'Enregistrer',
                onPressed: onSave,
                icon: Icon(
                  saved ? Icons.bookmark : Icons.bookmark_border,
                  size: 28,
                ),
              ),
              const SizedBox(width: 2),
            ],
          ),
          if (pageCount > 1)
            Positioned(
              bottom: 4,
              child: _Dots(count: pageCount, index: page),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.count,
    required this.onTap,
    required this.tooltip,
  });

  final Widget icon;
  final int count;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              SizedBox.square(dimension: 28, child: Center(child: icon)),
              if (count > 0) ...[
                const SizedBox(width: 5),
                Text(
                  formatCount(count),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final visible = count.clamp(0, 5);
    final start = (index - 2).clamp(0, count - visible);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = start; i < start + visible; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == index
                  ? AppColors.primary
                  : Theme.of(context).dividerColor,
            ),
          ),
      ],
    );
  }
}

class _LikedBy extends StatelessWidget {
  const _LikedBy({required this.users, required this.total});

  final List<User> users;
  final int total;

  @override
  Widget build(BuildContext context) {
    final shown = users.take(3).toList();
    final others = total - 1;
    const avatar = 20.0;
    const overlap = 7.0;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Row(
      children: [
        SizedBox(
          width: avatar + (shown.length - 1) * (avatar - overlap),
          height: avatar,
          child: Stack(
            children: [
              for (var i = shown.length - 1; i >= 0; i--)
                Positioned(
                  left: i * (avatar - overlap),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: bg, width: 1.5),
                    ),
                    child: Avatar(url: shown[i].avatarUrl, size: avatar - 3),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 14),
              children: [
                const TextSpan(text: 'Aimé par '),
                TextSpan(
                  text: shown.first.username,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (others > 0) ...[
                  const TextSpan(text: ' et '),
                  TextSpan(
                    text:
                        '${formatCount(others)} autre${others > 1 ? 's' : ''} '
                        'personne${others > 1 ? 's' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
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

class _Caption extends StatefulWidget {
  const _Caption({required this.username, required this.caption});

  final String username;
  final String caption;

  @override
  State<_Caption> createState() => _CaptionState();
}

class _CaptionState extends State<_Caption> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final span = TextSpan(
      style: TextStyle(fontSize: 14, height: 1.3, color: scheme.onSurface),
      children: [
        TextSpan(
          text: '${widget.username} ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        TextSpan(text: widget.caption),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: span,
          maxLines: 2,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return GestureDetector(
          onTap: overflows ? () => setState(() => _expanded = true) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                span,
                maxLines: _expanded ? null : 2,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
              if (overflows && !_expanded)
                Text(
                  'plus',
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Muted extends StatelessWidget {
  const _Muted(this.text, {this.fontSize = 14});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
