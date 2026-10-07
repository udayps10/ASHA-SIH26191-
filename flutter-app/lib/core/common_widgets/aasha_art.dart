import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Hand-drawn feel banner: rolling contour hills with a path linking two pins.
class AashaHeroArt extends StatelessWidget {
  const AashaHeroArt({super.key, this.height = 190});
  final double height;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _HeroArtPainter()),
    ),
  );
}

/// Compact motif for empty states and placeholders.
class AashaEmptyArt extends StatelessWidget {
  const AashaEmptyArt({super.key, this.size = 120});
  final double size;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _EmptyArtPainter());
}

class _HeroArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEAF4F9), Color(0xFFDCEBF3), Color(0xFFF4EFE4)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final sun = Paint()..color = const Color(0xFFF7D9A8);
    canvas.drawCircle(Offset(w * .78, h * .3), h * .16, sun);
    final sunRing = Paint()
      ..color = const Color(0xFFEFC489)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(Offset(w * .78, h * .3), h * .22, sunRing);

    void hill(double baseY, Color fill, {double amp = 18}) {
      final p = Path()..moveTo(0, h);
      p.lineTo(0, baseY);
      for (double x = 0; x <= w; x += w / 6) {
        p.quadraticBezierTo(
          x + w / 12,
          baseY - (x / w * 2 - 1).abs() * amp - amp,
          x + w / 6,
          baseY,
        );
      }
      p.lineTo(w, h);
      p.close();
      canvas.drawPath(p, Paint()..color = fill);
    }

    hill(h * .68, const Color(0xFFCBE0D7), amp: 14);
    hill(h * .78, const Color(0xFFB7D3CB), amp: 11);
    hill(h * .88, const Color(0xFF9FC0B8), amp: 8);

    final contour = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..strokeCap = StrokeCap.round;
    for (double i = 0; i < 5; i++) {
      final y = h * (.62 + i * .08);
      final p = Path()..moveTo(0, y);
      for (double x = 0; x <= w; x += w / 4) {
        p.quadraticBezierTo(x + w / 8, y - 6 - i, x + w / 4, y);
      }
      canvas.drawPath(p, contour..color = Colors.white.withAlpha((140 - i * 22).clamp(0, 255).toInt()));
    }

    final route = Path()
      ..moveTo(w * .16, h * .58)
      ..cubicTo(w * .34, h * .46, w * .5, h * .74, w * .66, h * .6)
      ..cubicTo(w * .74, h * .53, w * .8, h * .5, w * .84, h * .45);
    canvas.drawPath(
      route,
      Paint()
        ..color = AppTheme.primaryColor.withAlpha(160)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, .4),
    );
    final dash = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    const dashLen = 7.0, gap = 7.0;
    for (double d = 0; d < 900; d += dashLen + gap) {
      final t1 = (d / 900).clamp(0.0, 1.0).toDouble();
      final t2 = ((d + dashLen) / 900).clamp(0.0, 1.0).toDouble();
      if (t1 >= 1) break;
      canvas.drawLine(
        _cubicAt(route, t1),
        _cubicAt(route, t2),
        dash,
      );
    }

    void pin(Offset c, Color color, double scale) {
      final p = Path();
      p.addOval(Rect.fromCircle(center: Offset(c.dx, c.dy - 12 * scale), radius: 8 * scale));
      p.moveTo(c.dx - 5.5 * scale, c.dy - 7 * scale);
      p.lineTo(c.dx, c.dy + 5 * scale);
      p.lineTo(c.dx + 5.5 * scale, c.dy - 7 * scale);
      p.close();
      canvas.drawPath(p, Paint()..color = color);
      canvas.drawCircle(Offset(c.dx, c.dy - 12 * scale), 3.1 * scale, Paint()..color = Colors.white);
      final halo = Paint()
        ..color = color.withAlpha(46)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawCircle(c, 16 * scale, halo);
    }

    pin(Offset(w * .16, h * .58), AppTheme.primaryColor, 1.05);
    pin(Offset(w * .84, h * .45), AppTheme.accentColor, 1.05);

    final dot = Paint()..color = AppTheme.primaryColor.withAlpha(70);
    final rnd = Random(7);
    for (int i = 0; i < 18; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * w, rnd.nextDouble() * h * .5),
        rnd.nextDouble() * 1.6 + .5,
        dot,
      );
    }
  }

  Offset _cubicAt(Path p, double t) {
    final metrics = p.computeMetrics().first;
    return metrics.getTangentForOffset(metrics.length * t)?.position ?? Offset.zero;
  }

  @override
  bool shouldRepaint(covariant _HeroArtPainter oldDelegate) => false;
}

class _EmptyArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (int i = 3; i >= 1; i--) {
      canvas.drawCircle(
        c,
        size.width * .14 * i,
        Paint()
          ..color = AppTheme.primaryColor.withAlpha(14 + (3 - i) * 6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
    }
    final pin = Path()
      ..addOval(Rect.fromCircle(center: Offset(c.dx, c.dy - size.width * .09), radius: size.width * .085));
    pin.moveTo(c.dx - size.width * .06, c.dy - size.width * .03);
    pin.lineTo(c.dx, c.dy + size.width * .11);
    pin.lineTo(c.dx + size.width * .06, c.dy - size.width * .03);
    pin.close();
    canvas.drawPath(pin, Paint()..color = AppTheme.primaryColor);
    canvas.drawCircle(Offset(c.dx, c.dy - size.width * .09), size.width * .032, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(c.dx, c.dy - size.width * .09),
      size.width * .13,
      Paint()
        ..color = AppTheme.accentColor.withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
  }

  @override
  bool shouldRepaint(covariant _EmptyArtPainter oldDelegate) => false;
}
