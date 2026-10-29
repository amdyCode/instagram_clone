import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class InstagramGlyph extends StatelessWidget {
  const InstagramGlyph({super.key, this.size = 72, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Instagram',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _GlyphPainter(color)),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.color);

  final Color? color;

  static const _radial = RadialGradient(
    center: Alignment(-0.45, 1.05),
    radius: 1.55,
    colors: [
      AppColors.brandYellow,
      AppColors.brandOrange,
      AppColors.brandPink,
      AppColors.brandMagenta,
      AppColors.brandPurple,
    ],
    stops: [0.0, 0.2, 0.5, 0.78, 1.0],
  );

  static const _purpleVeil = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.1, 0.2),
    colors: [AppColors.brandPurple, Color(0x007638FA)],
  );

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final bounds = Offset.zero & Size.square(s);
    final stroke = s * 0.095;

    final shape = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          bounds.deflate(stroke / 2),
          Radius.circular(s * 0.27),
        ),
      )
      ..addOval(Rect.fromCircle(center: bounds.center, radius: s * 0.24));

    final flash = Offset(s * 0.765, s * 0.235);
    final flashRadius = s * 0.062;

    void draw(Paint paint) {
      canvas
        ..drawPath(
          shape,
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke,
        )
        ..drawCircle(flash, flashRadius, paint..style = PaintingStyle.fill);
    }

    if (color != null) {
      draw(Paint()..color = color!);
      return;
    }
    draw(Paint()..shader = _radial.createShader(bounds));
    draw(Paint()..shader = _purpleVeil.createShader(bounds));
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.color != color;
}

class InstagramWordmark extends StatelessWidget {
  const InstagramWordmark({super.key, this.fontSize = 34, this.color});

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Instagram',
      semanticsLabel: 'Instagram',
      style: TextStyle(
        fontFamily: 'GrandHotel',
        fontSize: fontSize,
        height: 1.1,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
