import 'package:flutter/material.dart';
import '../../core/models/profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common/avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final Profile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _avatarController;
  late final TextEditingController _linkController;

  late String _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _avatarController = TextEditingController(
      text: widget.profile.avatarUrl ?? '',
    );
    _linkController = TextEditingController(text: widget.profile.link ?? '');

    _currentAvatarUrl = widget.profile.avatarUrl ?? '';

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

  void _save() {
    final updated = widget.profile.copyWith(
      fullName: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      avatarUrl: _currentAvatarUrl.isNotEmpty ? _currentAvatarUrl : null,
      link: _linkController.text.trim().isNotEmpty
          ? _linkController.text.trim()
          : null,
    );

    Navigator.of(context).pop(updated);
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
            icon: const Icon(Icons.check, color: AppColors.primary, size: 28),
            onPressed: _save,
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
            helperText: 'Aperçu instantané au-dessus',
          ),
          const SizedBox(height: 14),

          _FormFieldRow(
            label: 'Bio',
            controller: _bioController,
            hintText: 'Présentez-vous en quelques mots...',
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
            onPressed: _save,
            child: const Text(
              'Enregistrer les modifications',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
              color: isDark ? const Color(0xFF555555) : const Color(0xFFB0B0B0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFF9F9F9),
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
