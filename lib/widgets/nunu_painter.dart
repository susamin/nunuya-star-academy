import 'dart:math' as math;
import 'package:flutter/material.dart';

enum NunuExpression { idle, happy, excited, sleeping, levelUp }

class NunuPainter extends CustomPainter {
  final NunuExpression expression;
  final int level;

  const NunuPainter({
    this.expression = NunuExpression.idle,
    this.level = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = w * 0.42;

    // ── Base colors ───────────────────────────────────────────
    const orange = Color(0xFFFF9800);
    const stripeColor = Color(0x50E65100);
    const pink = Color(0xFFFFB6C1);
    const darkBrown = Color(0xFF5D4037);
    const whiskerColor = Color(0xA0BF8040);

    final bodyPaint = Paint()..color = orange;
    final innerEarPaint = Paint()..color = pink;

    // ── Accessories (behind ears) ─────────────────────────────
    if (level >= 7) _drawCrown(canvas, cx, cy, r);

    // ── Ears ──────────────────────────────────────────────────
    final leftEar = Path()
      ..moveTo(cx - r * 0.7, cy - r * 0.55)
      ..lineTo(cx - r * 0.38, cy - r * 1.12)
      ..lineTo(cx - r * 0.02, cy - r * 0.68)
      ..close();
    canvas.drawPath(leftEar, bodyPaint);

    final rightEar = Path()
      ..moveTo(cx + r * 0.7, cy - r * 0.55)
      ..lineTo(cx + r * 0.38, cy - r * 1.12)
      ..lineTo(cx + r * 0.02, cy - r * 0.68)
      ..close();
    canvas.drawPath(rightEar, bodyPaint);

    // Inner ears
    final leftInner = Path()
      ..moveTo(cx - r * 0.58, cy - r * 0.60)
      ..lineTo(cx - r * 0.38, cy - r * 1.00)
      ..lineTo(cx - r * 0.10, cy - r * 0.72)
      ..close();
    canvas.drawPath(leftInner, innerEarPaint);

    final rightInner = Path()
      ..moveTo(cx + r * 0.58, cy - r * 0.60)
      ..lineTo(cx + r * 0.38, cy - r * 1.00)
      ..lineTo(cx + r * 0.10, cy - r * 0.72)
      ..close();
    canvas.drawPath(rightInner, innerEarPaint);

    // ── Face circle ───────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), r, bodyPaint);

    // ── Accessories (on face) ─────────────────────────────────
    if (level >= 3 && level < 7) _drawBow(canvas, cx, cy, r);
    if (level >= 5) _drawStarBadge(canvas, cx, cy, r);
    if (level >= 9) _drawSparkles(canvas, cx, cy, r);

    // ── Forehead stripes ──────────────────────────────────────
    final stripePaint = Paint()
      ..color = stripeColor
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(cx + i * r * 0.22, cy - r * 0.52),
        Offset(cx + i * r * 0.16, cy - r * 0.74),
        stripePaint,
      );
    }

    // ── Eyes ──────────────────────────────────────────────────
    _drawEyes(canvas, cx, cy, r, darkBrown);

    // ── Nose ──────────────────────────────────────────────────
    final nosePaint = Paint()..color = const Color(0xFFFF69B4);
    final nose = Path()
      ..moveTo(cx, cy + r * 0.16)
      ..lineTo(cx - r * 0.10, cy + r * 0.28)
      ..lineTo(cx + r * 0.10, cy + r * 0.28)
      ..close();
    canvas.drawPath(nose, nosePaint);

    // ── Mouth ─────────────────────────────────────────────────
    _drawMouth(canvas, cx, cy, r, darkBrown, w);

    // ── Blush (happy / excited / levelUp) ─────────────────────
    if (expression == NunuExpression.happy ||
        expression == NunuExpression.excited ||
        expression == NunuExpression.levelUp) {
      _drawBlush(canvas, cx, cy, r);
    }

    // ── Whiskers ──────────────────────────────────────────────
    final whiskerPaint = Paint()
      ..color = whiskerColor
      ..strokeWidth = w * 0.014
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - r * 1.0, cy + r * 0.10), Offset(cx - r * 0.14, cy + r * 0.18), whiskerPaint);
    canvas.drawLine(Offset(cx - r * 1.0, cy + r * 0.24), Offset(cx - r * 0.14, cy + r * 0.25), whiskerPaint);
    canvas.drawLine(Offset(cx - r * 0.95, cy + r * 0.38), Offset(cx - r * 0.14, cy + r * 0.32), whiskerPaint);
    canvas.drawLine(Offset(cx + r * 1.0, cy + r * 0.10), Offset(cx + r * 0.14, cy + r * 0.18), whiskerPaint);
    canvas.drawLine(Offset(cx + r * 1.0, cy + r * 0.24), Offset(cx + r * 0.14, cy + r * 0.25), whiskerPaint);
    canvas.drawLine(Offset(cx + r * 0.95, cy + r * 0.38), Offset(cx + r * 0.14, cy + r * 0.32), whiskerPaint);

    // ── Sleeping Zzz ─────────────────────────────────────────
    if (expression == NunuExpression.sleeping) {
      _drawZzz(canvas, cx, cy, r);
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  Eyes
  // ─────────────────────────────────────────────────────────────
  void _drawEyes(Canvas canvas, double cx, double cy, double r, Color darkBrown) {
    switch (expression) {
      case NunuExpression.idle:
        _drawIdleEyes(canvas, cx, cy, r, darkBrown);
      case NunuExpression.happy:
        _drawHappyEyes(canvas, cx, cy, r, darkBrown);
      case NunuExpression.excited:
        _drawExcitedEyes(canvas, cx, cy, r, darkBrown);
      case NunuExpression.sleeping:
        _drawSleepingEyes(canvas, cx, cy, r, darkBrown);
      case NunuExpression.levelUp:
        _drawLevelUpEyes(canvas, cx, cy, r);
    }
  }

  void _drawIdleEyes(Canvas canvas, double cx, double cy, double r, Color darkBrown) {
    final eyeWhite = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = darkBrown;
    final shinePaint = Paint()..color = Colors.white;

    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * r * 0.31;
      final ey = cy - r * 0.08;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex, ey), width: r * 0.50, height: r * 0.44),
        eyeWhite,
      );
      canvas.drawCircle(Offset(ex, ey), r * 0.16, pupilPaint);
      canvas.drawCircle(Offset(ex + sign * r * 0.06, ey - r * 0.06), r * 0.06, shinePaint);
    }
  }

  void _drawHappyEyes(Canvas canvas, double cx, double cy, double r, Color darkBrown) {
    final eyePaint = Paint()
      ..color = darkBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.075
      ..strokeCap = StrokeCap.round;

    // Draw upward-curving arcs (happy squint: ∪ shape)
    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * r * 0.31;
      final ey = cy - r * 0.08;
      final eyePath = Path()
        ..moveTo(ex - r * 0.20, ey)
        ..quadraticBezierTo(ex, ey + r * 0.16, ex + r * 0.20, ey);
      canvas.drawPath(eyePath, eyePaint);
    }
  }

  void _drawExcitedEyes(Canvas canvas, double cx, double cy, double r, Color darkBrown) {
    final eyeWhite = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = darkBrown;
    final shinePaint = Paint()..color = Colors.white;
    final highlightPaint = Paint()
      ..color = const Color(0xFFFFEB3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04;

    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * r * 0.31;
      final ey = cy - r * 0.10;
      // Larger eyes for excited look
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex, ey), width: r * 0.60, height: r * 0.54),
        eyeWhite,
      );
      // Yellow ring highlight
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex, ey), width: r * 0.60, height: r * 0.54),
        highlightPaint,
      );
      canvas.drawCircle(Offset(ex, ey), r * 0.20, pupilPaint);
      canvas.drawCircle(Offset(ex + sign * r * 0.06, ey - r * 0.07), r * 0.07, shinePaint);
    }
  }

  void _drawSleepingEyes(Canvas canvas, double cx, double cy, double r, Color darkBrown) {
    final eyePaint = Paint()
      ..color = darkBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.075
      ..strokeCap = StrokeCap.round;

    // Two curved closed lines (— — style with slight curve)
    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * r * 0.31;
      final ey = cy - r * 0.10;
      final eyePath = Path()
        ..moveTo(ex - r * 0.20, ey)
        ..quadraticBezierTo(ex, ey - r * 0.10, ex + r * 0.20, ey);
      canvas.drawPath(eyePath, eyePaint);
    }
  }

  void _drawLevelUpEyes(Canvas canvas, double cx, double cy, double r) {
    final starPaint = Paint()..color = const Color(0xFFFFD700);
    final starStroke = Paint()
      ..color = const Color(0xFFFF8F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.03;

    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * r * 0.31;
      final ey = cy - r * 0.08;
      _drawStar(canvas, ex, ey, r * 0.22, starPaint);
      _drawStar(canvas, ex, ey, r * 0.22, starStroke);
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double radius, Paint paint) {
    final path = Path();
    const int points = 5;
    final innerRadius = radius * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? radius : innerRadius;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // ─────────────────────────────────────────────────────────────
  //  Mouth
  // ─────────────────────────────────────────────────────────────
  void _drawMouth(Canvas canvas, double cx, double cy, double r, Color darkBrown, double w) {
    final mouthPaint = Paint()
      ..color = darkBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;

    switch (expression) {
      case NunuExpression.sleeping:
        // Neutral / slightly downward mouth
        final leftMouth = Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx - r * 0.18, cy + r * 0.36, cx - r * 0.28, cy + r * 0.30);
        final rightMouth = Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx + r * 0.18, cy + r * 0.36, cx + r * 0.28, cy + r * 0.30);
        canvas.drawPath(leftMouth, mouthPaint);
        canvas.drawPath(rightMouth, mouthPaint);

      case NunuExpression.excited:
      case NunuExpression.levelUp:
        // Wide open happy smile
        final leftBig = Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx - r * 0.28, cy + r * 0.52, cx - r * 0.40, cy + r * 0.40);
        final rightBig = Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx + r * 0.28, cy + r * 0.52, cx + r * 0.40, cy + r * 0.40);
        canvas.drawPath(leftBig, mouthPaint);
        canvas.drawPath(rightBig, mouthPaint);

      default:
        // Normal smile
        final leftMouth = Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx - r * 0.22, cy + r * 0.44, cx - r * 0.32, cy + r * 0.36);
        final rightMouth = Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx + r * 0.22, cy + r * 0.44, cx + r * 0.32, cy + r * 0.36);
        canvas.drawPath(leftMouth, mouthPaint);
        canvas.drawPath(rightMouth, mouthPaint);
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  Blush cheeks
  // ─────────────────────────────────────────────────────────────
  void _drawBlush(Canvas canvas, double cx, double cy, double r) {
    final blushPaint = Paint()..color = const Color(0x55FF69B4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - r * 0.60, cy + r * 0.20), width: r * 0.38, height: r * 0.22),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + r * 0.60, cy + r * 0.20), width: r * 0.38, height: r * 0.22),
      blushPaint,
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Sleeping Zzz
  // ─────────────────────────────────────────────────────────────
  void _drawZzz(Canvas canvas, double cx, double cy, double r) {
    // Draw small "Z" letters above right ear using path
    final zPaint = Paint()
      ..color = const Color(0xCC64B5F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void drawZ(double x, double y, double size) {
      final path = Path()
        ..moveTo(x, y)
        ..lineTo(x + size, y)
        ..lineTo(x, y + size)
        ..lineTo(x + size, y + size);
      canvas.drawPath(path, zPaint);
    }

    drawZ(cx + r * 0.55, cy - r * 1.15, r * 0.12);
    drawZ(cx + r * 0.70, cy - r * 1.35, r * 0.18);
  }

  // ─────────────────────────────────────────────────────────────
  //  Lv.3 Bow
  // ─────────────────────────────────────────────────────────────
  void _drawBow(Canvas canvas, double cx, double cy, double r) {
    final bowPaint = Paint()..color = const Color(0xFFE91E63);
    final bowStroke = Paint()
      ..color = const Color(0xFFC2185B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.03;

    final bx = cx + r * 0.36;
    final by = cy - r * 0.98;

    // Left lobe
    final leftLobe = Path()
      ..moveTo(bx, by)
      ..quadraticBezierTo(bx - r * 0.26, by - r * 0.20, bx - r * 0.30, by + r * 0.04)
      ..quadraticBezierTo(bx - r * 0.14, by + r * 0.06, bx, by);
    canvas.drawPath(leftLobe, bowPaint);
    canvas.drawPath(leftLobe, bowStroke);

    // Right lobe
    final rightLobe = Path()
      ..moveTo(bx, by)
      ..quadraticBezierTo(bx + r * 0.26, by - r * 0.20, bx + r * 0.30, by + r * 0.04)
      ..quadraticBezierTo(bx + r * 0.14, by + r * 0.06, bx, by);
    canvas.drawPath(rightLobe, bowPaint);
    canvas.drawPath(rightLobe, bowStroke);

    // Center knot
    canvas.drawCircle(Offset(bx, by), r * 0.06, Paint()..color = const Color(0xFFF48FB1));
  }

  // ─────────────────────────────────────────────────────────────
  //  Lv.5 Star badge (mic stand)
  // ─────────────────────────────────────────────────────────────
  void _drawStarBadge(Canvas canvas, double cx, double cy, double r) {
    final micPaint = Paint()..color = const Color(0xFFFFEB3B);
    final micStroke = Paint()
      ..color = const Color(0xFFF9A825)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.035;

    // Small star on right cheek
    _drawStar(canvas, cx + r * 0.70, cy + r * 0.30, r * 0.14, micPaint);
    _drawStar(canvas, cx + r * 0.70, cy + r * 0.30, r * 0.14, micStroke);
  }

  // ─────────────────────────────────────────────────────────────
  //  Lv.7 Crown
  // ─────────────────────────────────────────────────────────────
  void _drawCrown(Canvas canvas, double cx, double cy, double r) {
    final goldPaint = Paint()..color = const Color(0xFFFFD700);
    final goldStroke = Paint()
      ..color = const Color(0xFFFF8F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04;
    final gemPaint = Paint()..color = const Color(0xFFE040FB);

    final topY = cy - r * 1.16;
    final baseY = cy - r * 0.86;
    final halfW = r * 0.48;

    // Crown body (trapezoid base)
    final crown = Path()
      ..moveTo(cx - halfW, baseY)
      ..lineTo(cx - halfW * 0.7, topY + r * 0.18)
      ..lineTo(cx - halfW * 0.5, baseY - r * 0.08) // left inner dip
      ..lineTo(cx - halfW * 0.2, topY - r * 0.04) // left peak
      ..lineTo(cx, baseY - r * 0.08) // center dip
      ..lineTo(cx + halfW * 0.2, topY - r * 0.04) // right peak
      ..lineTo(cx + halfW * 0.5, baseY - r * 0.08)
      ..lineTo(cx + halfW * 0.7, topY + r * 0.18)
      ..lineTo(cx + halfW, baseY)
      ..close();
    canvas.drawPath(crown, goldPaint);
    canvas.drawPath(crown, goldStroke);

    // Gems
    canvas.drawCircle(Offset(cx, topY - r * 0.02), r * 0.07, gemPaint);
    canvas.drawCircle(Offset(cx - halfW * 0.2, topY - r * 0.02), r * 0.05, Paint()..color = const Color(0xFF29B6F6));
    canvas.drawCircle(Offset(cx + halfW * 0.2, topY - r * 0.02), r * 0.05, Paint()..color = const Color(0xFF66BB6A));
  }

  // ─────────────────────────────────────────────────────────────
  //  Lv.9 Sparkles
  // ─────────────────────────────────────────────────────────────
  void _drawSparkles(Canvas canvas, double cx, double cy, double r) {
    final sparkPaint = Paint()..color = const Color(0xCCFFD740);
    final positions = [
      Offset(cx - r * 1.05, cy - r * 0.55),
      Offset(cx + r * 1.05, cy - r * 0.55),
      Offset(cx - r * 1.10, cy + r * 0.20),
      Offset(cx + r * 1.10, cy + r * 0.20),
      Offset(cx, cy - r * 1.22),
    ];
    for (final pos in positions) {
      _drawSparkle(canvas, pos.dx, pos.dy, r * 0.10, sparkPaint);
    }
  }

  void _drawSparkle(Canvas canvas, double cx, double cy, double size, Paint paint) {
    // 4-pointed star / sparkle
    final path = Path()
      ..moveTo(cx, cy - size)
      ..lineTo(cx + size * 0.25, cy - size * 0.25)
      ..lineTo(cx + size, cy)
      ..lineTo(cx + size * 0.25, cy + size * 0.25)
      ..lineTo(cx, cy + size)
      ..lineTo(cx - size * 0.25, cy + size * 0.25)
      ..lineTo(cx - size, cy)
      ..lineTo(cx - size * 0.25, cy - size * 0.25)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NunuPainter old) =>
      old.expression != expression || old.level != level;
}
