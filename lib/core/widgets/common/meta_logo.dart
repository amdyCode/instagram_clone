import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../theme/app_colors.dart';

class MetaLogo extends StatelessWidget {
  const MetaLogo({
    super.key,
    this.size = 18,
    this.color,
    this.gradient = false,
  });

  final double size;
  final Color? color;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = gradient
        ? Colors.white
        : color ??
              (theme.brightness == Brightness.light
                  ? AppColors.metaText
                  : theme.colorScheme.onSurface);

    final logo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(FontAwesomeIcons.meta, size: size * 1.05, color: fg),
        SizedBox(width: size * 0.22),
        Text(
          'Meta',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1,
            color: fg,
          ),
        ),
      ],
    );

    if (!gradient) return Semantics(label: 'Meta', child: logo);

    return Semantics(
      label: 'Meta',
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            AppColors.brandOrange,
            AppColors.brandPink,
            AppColors.brandMagenta,
          ],
        ).createShader(bounds),
        child: logo,
      ),
    );
  }
}
