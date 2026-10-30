import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum PillVariant { primary, secondary, outlined }

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PillVariant.primary,
    this.loading = false,
  });

  const PillButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  }) : variant = PillVariant.secondary;

  const PillButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  }) : variant = PillVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final PillVariant variant;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final (Color bg, Color fg, BorderSide side) = switch (variant) {
      PillVariant.primary => (
        AppColors.metaBlue,
        Colors.white,
        BorderSide.none,
      ),
      PillVariant.secondary => (
        isDark ? AppColors.darkSecondaryButton : AppColors.secondaryButton,
        onSurface,
        BorderSide.none,
      ),
      PillVariant.outlined => (
        Colors.transparent,
        AppColors.metaBlue,
        const BorderSide(color: AppColors.metaBlue),
      ),
    };

    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
      shape: WidgetStatePropertyAll(StadiumBorder(side: side)),
      elevation: const WidgetStatePropertyAll(0),
      overlayColor: WidgetStatePropertyAll(fg.withValues(alpha: 0.08)),
      textStyle: WidgetStatePropertyAll(
        Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) && !loading
            ? bg.withValues(alpha: bg.a * 0.4)
            : bg,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) && !loading
            ? fg.withValues(alpha: variant == PillVariant.primary ? 0.9 : 0.4)
            : fg,
      ),
    );

    return TextButton(
      style: style,
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
            )
          : Text(label),
    );
  }
}
