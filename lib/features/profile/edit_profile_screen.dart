import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common/avatar.dart';
import '../auth/auth_controller.dart';
import 'profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, this.profile});

  final Profile? profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _avatarController;
  late final TextEditingController _linkController;

  late String _currentAvatarUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    final p = widget.profile ??
        ref.read(myProfileControllerProvider).profile ??
        (user != null
            ? Profile.fromUser(user)
            : const Profile(
                username: '',
                fullName: '',
                avatarUrl: null,
                bio: '',
                postCount: 0,
                followerCount: 0,
                followingCount: 0,
                isMe: true,
                isFollowing: false,
              ));

    _nameController = TextEditingController(text: p.fullName);
    _bioController = TextEditingController(text: p.bio);
    _avatarController = TextEditingController(
      text: p.avatarUrl ?? '',
    );
    _linkController = TextEditingController(text: p.link ?? '');

    _currentAvatarUrl = p.avatarUrl ?? '';

    _avatarController.addListener(() {
      final text = _avatarController.text.trim();
      if (text != _currentAvatarUrl) {
        setState(() {
          _currentAvatarUrl = text;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _avatarController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final fullName = _nameController.text.trim();
    final bio = _bioController.text.trim();
    final avatarUrl =
        _currentAvatarUrl.isNotEmpty ? _currentAvatarUrl : null;
    final link = _linkController.text.trim().isNotEmpty
        ? _linkController.text.trim()
        : null;

    final success = await ref
        .read(myProfileControllerProvider.notifier)
        .updateProfile(
          fullName: fullName,
          bio: bio,
          avatarUrl: avatarUrl,
          link: link,
        );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (success) {
      final user = ref.read(authControllerProvider).user;
      final base =
          widget.profile ?? ref.read(myProfileControllerProvider).profile;
      final updated = base?.copyWith(
            fullName: fullName,
            bio: bio,
            avatarUrl: avatarUrl,
            link: link,
          ) ??
          (user != null
              ? Profile.fromUser(user).copyWith(
                  fullName: fullName,
                  bio: bio,
                  avatarUrl: avatarUrl,
                  link: link,
                )
              : Profile(
                  username: '',
                  fullName: fullName,
                  bio: bio,
                  avatarUrl: avatarUrl,
                  link: link,
                  postCount: 0,
                  followerCount: 0,
                  followingCount: 0,
                  isMe: true,
                  isFollowing: false,
                ));
      Navigator.of(context).pop(updated);
    } else {
      final error = ref.read(myProfileControllerProvider).error ??
          'Erreur lors de la mise a jour';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final dividerColor = theme.dividerColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Annuler',
          icon: const Icon(Icons.close, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Modifier le profil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check, color: AppColors.primary, size: 28),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Avatar(
                      url: _currentAvatarUrl.isNotEmpty
                          ? _currentAvatarUrl
                          : null,
                      size: 96,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: const Text(
                    'Modifier la photo de profil',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: dividerColor, height: 1),
          const SizedBox(height: 16),
          _FormFieldRow(
            label: 'Nom',
            controller: _nameController,
            hintText: 'Votre nom complet',
            isDark: isDark,
            onSurface: onSurface,
          ),
          const SizedBox(height: 14),
          _FormFieldRow(
            label: 'URL Avatar',
            controller: _avatarController,
            hintText: 'https://exemple.com/photo.jpg',
            keyboardType: TextInputType.url,
            isDark: isDark,
            onSurface: onSurface,
            helperText: 'Apercu instantane au-dessus',
          ),
          const SizedBox(height: 14),
          _FormFieldRow(
            label: 'Bio',
            controller: _bioController,
            hintText: 'Presentez-vous en quelques mots...',
            maxLines: 3,
            isDark: isDark,
            onSurface: onSurface,
          ),
          const SizedBox(height: 14),
          _FormFieldRow(
            label: 'Liens',
            controller: _linkController,
            hintText: 'Ajouter un lien externe (ex: site.com)',
            keyboardType: TextInputType.url,
            isDark: isDark,
            onSurface: onSurface,
          ),
          const SizedBox(height: 24),
          Divider(color: dividerColor, height: 1),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Enregistrer les modifications',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FormFieldRow extends StatelessWidget {
  const _FormFieldRow({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.isDark,
    required this.onSurface,
    this.maxLines = 1,
    this.keyboardType,
    this.helperText,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool isDark;
  final Color onSurface;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFA8A8A8) : const Color(0xFF737373),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 15, color: onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            helperStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
            ),
            hintStyle: TextStyle(
              fontSize: 14,
              color:
                  isDark ? const Color(0xFF555555) : const Color(0xFFB0B0B0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor:
                isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF9F9F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF2E2E2E)
                    : const Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF2E2E2E)
                    : const Color(0xFFE0E0E0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
