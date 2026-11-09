import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_clone/core/widgets/post/post_settings_tile.dart';
import '../feed/feed_controller.dart';
import '../auth/auth_controller.dart';
import 'post_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common/avatar.dart';
import '../../core/widgets/post/post_image_preview.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  final FocusNode _captionFocusNode = FocusNode();

  String _imageUrl = '';
  bool _isSubmitting = false;

  final List<(String, String)> _presetImages = const [
    ('Nature', 'https://picsum.photos/seed/nature123/1080/1080'),
    ('Voyage', 'https://picsum.photos/seed/travel456/1080/1080'),
    ('Skate', 'https://picsum.photos/seed/skate789/1080/1080'),
    ('Ville', 'https://picsum.photos/seed/city321/1080/1080'),
  ];

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    _captionController.dispose();
    _urlFocusNode.dispose();
    _captionFocusNode.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    final text = _urlController.text.trim();
    if (text != _imageUrl) {
      setState(() {
        _imageUrl = text;
      });
    }
  }

  void _selectPreset(String url) {
    _urlController.text = url;
    _urlController.selection = TextSelection.fromPosition(
      TextPosition(offset: url.length),
    );
  }

  Future<void> _submit() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner une URL d\'image valide'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final caption = _captionController.text.trim();
    final post = await ref.read(postControllerProvider.notifier).createPost(
      caption: caption,
      mediaUrls: [url],
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if (post != null) {
      ref.read(feedControllerProvider.notifier).addPost(post);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publication partagee avec succes !'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    } else {
      final error = ref.read(postControllerProvider).error ??
          'Impossible de creer la publication';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(authControllerProvider).user;
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;
    final canPublish = _imageUrl.isNotEmpty && !_isSubmitting;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 26),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Nouvelle publication',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: canPublish ? _submit : null,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Publier',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: canPublish
                          ? AppColors.primary
                          : secondaryColor.withValues(alpha: 0.5),
                    ),
                  ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostImagePreview(imageUrl: _imageUrl, height: 280),
            const SizedBox(height: 16),
            Text(
              'URL de l\'image',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF262626)
                    : const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.link, size: 20, color: secondaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      focusNode: _urlFocusNode,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                        hintText: 'https://...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ),
                  if (_urlController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _urlController.clear();
                      },
                      child: Icon(
                        Icons.cancel,
                        size: 18,
                        color: secondaryColor,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ..._presetImages.map((preset) {
                  final isSelected = _imageUrl == preset.$2;
                  return ChoiceChip(
                    label: Text(
                      preset.$1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    onSelected: (_) => _selectPreset(preset.$2),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Avatar(url: currentUser?.avatarUrl, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.username ?? 'moi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TextField(
                        controller: _captionController,
                        focusNode: _captionFocusNode,
                        maxLines: 4,
                        minLines: 2,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          border: InputBorder.none,
                          hintText: 'Ecrivez une legende...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),
            PostSettingsTile(
              icon: Icons.location_on_outlined,
              title: 'Ajouter un lieu',
              onTap: () {},
            ),
            PostSettingsTile(
              icon: Icons.person_outline,
              title: 'Identifier des personnes',
              onTap: () {},
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: canPublish ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.35,
                  ),
                  disabledForegroundColor: Colors.white60,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Publier',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}