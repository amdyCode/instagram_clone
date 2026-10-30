import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

// Thèmes clair / sombre.
abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    bg: AppColors.lightBg,
    text: AppColors.lightText,
    secondary: AppColors.lightSecondary,
    divider: AppColors.lightDivider,
    fieldBorder: AppColors.fieldBorder,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    bg: AppColors.darkBg,
    text: AppColors.darkText,
    secondary: AppColors.darkSecondary,
    divider: AppColors.darkDivider,
    fieldBorder: AppColors.darkFieldBorder,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color text,
    required Color secondary,
    required Color divider,
    required Color fieldBorder,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.metaBlue,
      onPrimary: Colors.white,
      secondary: AppColors.primary,
      onSecondary: Colors.white,
      error: AppColors.like,
      onError: Colors.white,
      surface: bg,
      onSurface: text,
      onSurfaceVariant: secondary,
      outline: fieldBorder,
      outlineVariant: divider,
    );

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      dividerColor: divider,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      iconTheme: IconThemeData(color: text),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 21,
        ),
        labelStyle: TextStyle(color: secondary, fontSize: 16),
        floatingLabelStyle: TextStyle(color: secondary, fontSize: 13),
        border: border(fieldBorder),
        enabledBorder: border(fieldBorder),
        focusedBorder: border(text, 1.2),
        errorBorder: border(AppColors.like),
        focusedErrorBorder: border(AppColors.like, 1.2),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: text,
        selectionColor: AppColors.metaBlue.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.metaBlue,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: text,
          // Dérivé de la typo de base pour garder la police par défaut.
          textStyle: ThemeData(brightness: brightness).textTheme.labelLarge
              ?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
