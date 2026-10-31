import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum ProfileButtonVariant { primary, secondary }

class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ProfileButtonVariant.secondary,
    this.icon,
  });

  const ProfileActionButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : variant = ProfileButtonVariant.primary;

  final String label;
  final VoidCallback onPressed;
  final ProfileButtonVariant variant;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final (Color bg, Color fg) = switch (variant) {
      ProfileButtonVariant.primary => (AppColors.primary, Colors.white),
      ProfileButtonVariant.secondary => (
        isDark ? AppColors.darkDivider : const Color(0xFFEFEFEF),
        onSurface,
      ),
    };

    return SizedBox(
      height: 34,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        onPressed: onPressed,
        child: icon == null
            ? Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ProfileIconButton extends StatelessWidget {
  const ProfileIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SizedBox.square(
      dimension: 34,
      child: Tooltip(
        message: tooltip ?? '',
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: isDark
                ? AppColors.darkDivider
                : const Color(0xFFEFEFEF),
            foregroundColor: onSurface,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onPressed,
          child: icon,
        ),
      ),
    );
  }
}
