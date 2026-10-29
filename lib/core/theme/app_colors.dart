import 'package:flutter/material.dart';

abstract final class AppColors {
  // dégradé logo
  static const brandYellow = Color(0xFFFFD600);
  static const brandOrange = Color(0xFFFF7A00);
  static const brandPink = Color(0xFFFF0069);
  static const brandMagenta = Color(0xFFD300C5);
  static const brandPurple = Color(0xFF7638FA);

  // Anneau de story non vue
  static const storyGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [brandYellow, brandOrange, brandPink, brandMagenta],
    stops: [0.0, 0.25, 0.65, 1.0],
  );

  static const metaBlue = Color(0xFF0064E0);
  static const metaText = Color(0xFF1C2B33);
  static const fieldBorder = Color(0xFFCED0D4);
  static const secondaryButton = Color(0xFFF0F2F5);

  // Feed
  static const primary = Color(0xFF0095F6);
  static const like = Color(0xFFFF3040);
  static const closeFriends = Color(0xFF1CD14F);

  // Light
  static const lightBg = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF000000);
  static const lightSecondary = Color(0xFF737373);
  static const lightDivider = Color(0xFFDBDBDB);

  // Dark
  static const darkBg = Color(0xFF000000);
  static const darkText = Color(0xFFF5F5F5);
  static const darkSecondary = Color(0xFFA8A8A8);
  static const darkDivider = Color(0xFF262626);
  static const darkFieldBorder = Color(0xFF3E4A52);
  static const darkSecondaryButton = Color(0xFF1F2A30);
}
