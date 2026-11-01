import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/comment.dart';
import '../../models/user.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../common/avatar.dart';

void showCommentsBottomSheet(
  BuildContext context, {
  required String postId,
  required User postAuthor,
  String? caption,
  DateTime? postCreatedAt,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CommentsBottomSheet(
      postId: postId,
      postAuthor: postAuthor,
      caption: caption,
      postCreatedAt: postCreatedAt,
    ),
  );
}

class CommentsBottomSheet extends StatefulWidget {
  const CommentsBottomSheet({
    super.key,
    required this.postId,
    required this.postAuthor,
    this.caption,
    this.postCreatedAt,
  });

  final String postId;
  final User postAuthor;
  final String? caption;
  final DateTime? postCreatedAt;

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  late List<Comment> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List<Comment>.from(
      mockComments[widget.postId] ??
          [
            Comment(
              id: 'c_default_1',
              author: mockUsers[0],
              text: 'Superbe photo ! J’adore les couleurs',
              createdAt: DateTime.now().subtract(const Duration(hours: 3)),
              likeCount: 4,
            ),
            Comment(
              id: 'c_default_2',
              author: mockUsers[1],
              text: 'Magnifique cadrage',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              likeCount: 1,
            ),
          ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add(
        Comment(
          id: 'c_${DateTime.now().millisecondsSinceEpoch}',
          author: me,
          text: text,
          createdAt: DateTime.now(),
        ),
      );
      _commentController.clear();
    });

    FocusScope.of(context).unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleLike(int index) {
    setState(() {
      final c = _comments[index];
      final liked = !c.likedByMe;
      _comments[index] = c.copyWith(
        likedByMe: liked,
        likeCount: c.likeCount + (liked ? 1 : -1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final secondary = theme.colorScheme.onSurfaceVariant;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Commentaires',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Divider(color: theme.dividerColor, height: 1),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  itemCount:
                      _comments.length + (widget.caption != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (widget.caption != null && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Avatar(url: widget.postAuthor.avatarUrl, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: onSurface,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${widget.postAuthor.username} ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(text: widget.caption!),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeAgo(
                                      widget.postCreatedAt ??
                                          DateTime.now().subtract(
                                            const Duration(hours: 2),
                                          ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final commentIndex = widget.caption != null
                        ? index - 1
                        : index;
                    final comment = _comments[commentIndex];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Avatar(url: comment.author.avatarUrl, size: 34),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: onSurface,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${comment.author.username} ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(text: comment.text),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      timeAgo(comment.createdAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Répondre',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _toggleLike(commentIndex),
                                child: Icon(
                                  comment.likedByMe
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 16,
                                  color: comment.likedByMe
                                      ? AppColors.like
                                      : secondary,
                                ),
                              ),
                              if (comment.likeCount > 0)
                                Text(
                                  '${comment.likeCount}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: secondary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: EdgeInsets.fromLTRB(14, 8, 14, 8 + bottomInset),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(color: theme.dividerColor, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Avatar(url: me.avatarUrl, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: TextStyle(fontSize: 14, color: onSurface),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _addComment(),
                        decoration: InputDecoration(
                          hintText:
                              'Ajouter un commentaire pour ${widget.postAuthor.username}...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? const Color(0xFF666666)
                                : const Color(0xFFAAAAAA),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    ListenableBuilder(
                      listenable: _commentController,
                      builder: (context, _) {
                        final canSend = _commentController.text
                            .trim()
                            .isNotEmpty;
                        return TextButton(
                          onPressed: canSend ? _addComment : null,
                          child: Text(
                            'Publier',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: canSend
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.35),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
