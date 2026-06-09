import 'dart:math' as math;
import 'package:flutter/material.dart';

enum NunuExpression { idle, happy, excited, sleeping, levelUp }

class NunuPainter extends CustomPainter {
  final NunuExpression expression;
  final int level;

  /// 0.0 = eyes open, 1.0 = eyes fully closed (blink)
  final double blinkProgress;

  /// -1.0 to +1.0: how much the right ear tip flicks outward
  final double earWiggle;

  const NunuPainter({
    this.expression = NunuExpression.idle,
    this.level = 1,
    this.blinkProgress = 0.0,
    this.earWiggle = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    final cy = size.height / 2;
    final r = w * 0.42;

    const orange      = Color(0xFFFF9800);
    const stripeColor = Color(0x50E65100);
    const pink        = Color(0xFFFFB6C1);
    const darkBrown   = Color(0xFF5D4037);
    const whiskerColor = Color(0xA0BF8040);

    final bodyPaint    = Paint()..color = orange;
    final innerEarPaint = Paint()..color = pink;

    // ── Accessories behind ears ───────────────────────────────
    if (level >= 7) _drawCrown(canvas, cx, cy, r);

    // ── Ears (with earWiggle on right ear) ───────────────────
    final wx = earWiggle * r * 0.18;   // horizontal tip offset
    final wy = earWiggle.abs() * r * 0.06; // slight lift

    // Left ear (subtle counter-wiggle)
    final leftEar = Path()
      ..moveTo(cx - r * 0.7, cy - r * 0.55)
      ..lineTo(cx - r * 0.38 - earWiggle * r * 0.04, cy - r * 1.12)
      ..lineTo(cx - r * 0.02, cy - r * 0.68)
      ..close();
    canvas.drawPath(leftEar, bodyPaint);

    // Right ear (main wiggle)
    final rightEar = Path()
      ..moveTo(cx + r * 0.7, cy - r * 0.55)
      ..lineTo(cx + r * 0.38 + wx, cy - r * 1.12 - wy)
      ..lineTo(cx + r * 0.02, cy - r * 0.68)
      ..close();
    canvas.drawPath(rightEar, bodyPaint);

    // Inner left ear
    final leftInner = Path()
      ..moveTo(cx - r * 0.58, cy - r * 0.60)
      ..lineTo(cx - r * 0.38 - earWiggle * r * 0.03, cy - r * 1.00)
      ..lineTo(cx - r * 0.10, cy - r * 0.72)
      ..close();
    canvas.drawPath(leftInner, innerEarPaint);

    // Inner right ear
    final rightInner = Path()
      ..moveTo(cx + r * 0.58, cy - r * 0.60)
      ..lineTo(cx + r * 0.38 + wx * 0.65, cy - r * 1.00 - wy * 0.5)
      ..lineTo(cx + r * 0.10, cy - r * 0.72)
      ..close();
    canvas.drawPath(rightInner, innerEarPaint);

    // ── Face circle ───────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), r, bodyPaint);

    // ── Accessories on face ───────────────────────────────────
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

    // ── Eyes (blink-aware) ────────────────────────────────────
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

    // ── Blush ─────────────────────────────────────────────────
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

    // ── Sleeping Zzz ──────────────────────────────────────────
    if (expression == NunuExpression.sleeping) {
      _drawZzz(canvas, cx, cy, r);
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  Eyes  (blink-aware)
  // ─────────────────────────────────────────────────────────────
  void _drawEyes(Canvas canvas, double cx, double cy, double r, Color darkBrown) {
    // During a blink, override expression with half-closed/closed
    if (blinkProgress > 0 &&
        expression == NunuExpression.idle &&
        expression != NunuExpression.sleeping) {
      _drawBlinkingEyes(canvas, cx, cy, r, darkBrown);
      return;
    }

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

  void _drawBlinkingEyes(Canvas canvas, double cx, double cy, double r, Color darkBrown) {
    // Smoothly squish the eyes shut then open again
    final openFactor = 1.0 - blinkProgress; // 1 = open, 0 = closed
    final eyeWhite = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = darkBrown;
    final shinePaint = Paint()..color = Colors.white;

    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * r * 0.31;
      final ey = cy - r * 0.08;

      if (openFactor < 0.08) {
        // Fully closed — draw a simple arc line
        final closedPaint = Paint()
          ..color = darkBrown
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.07
          ..strokeCap = StrokeCap.round;
        final path = Path()
          ..moveTo(ex - r * 0.20, ey + r * 0.02)
          ..quadraticBezierTo(ex, ey + r * 0.12, ex + r * 0.20, ey + r * 0.02);
        canvas.drawPath(path, closedPaint);
      } else {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(ex, ey),
            width: r * 0.50,
            height: r * 0.44 * openFactor,
          ),
          eyeWhite,
        );
        if (openFactor > 0.35) {
          canvas.drawCircle(Offset(ex, ey), r * 0.15 * openFactor, pupilPaint);
          canvas.drawCircle(Offset(ex + sign * r * 0.05, ey - r * 0.05 * openFactor), r * 0.055, shinePaint);
        }
      }
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
    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * r * 0.31;
      final ey = cy - r * 0.08;
      final path = Path()
        ..moveTo(ex - r * 0.20, ey)
        ..quadraticBezierTo(ex, ey + r * 0.16, ex + r * 0.20, ey);
      canvas.drawPath(path, eyePaint);
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
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex, ey), width: r * 0.60, height: r * 0.54),
        eyeWhite,
      );
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
    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * r * 0.31;
      final ey = cy - r * 0.10;
      final path = Path()
        ..moveTo(ex - r * 0.20, ey)
        ..quadraticBezierTo(ex, ey - r * 0.10, ex + r * 0.20, ey);
      canvas.drawPath(path, eyePaint);
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
    const points = 5;
    final innerRadius = radius * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final rad = i.isEven ? radius : innerRadius;
      final x = cx + rad * math.cos(angle);
      final y = cy + rad * math.sin(angle);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
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
        canvas.drawPath(Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx - r * 0.18, cy + r * 0.36, cx - r * 0.28, cy + r * 0.30),
          mouthPaint);
        canvas.drawPath(Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx + r * 0.18, cy + r * 0.36, cx + r * 0.28, cy + r * 0.30),
          mouthPaint);
      case NunuExpression.excited:
      case NunuExpression.levelUp:
        canvas.drawPath(Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx - r * 0.28, cy + r * 0.52, cx - r * 0.40, cy + r * 0.40),
          mouthPaint);
        canvas.drawPath(Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx + r * 0.28, cy + r * 0.52, cx + r * 0.40, cy + r * 0.40),
          mouthPaint);
      default:
        canvas.drawPath(Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx - r * 0.22, cy + r * 0.44, cx - r * 0.32, cy + r * 0.36),
          mouthPaint);
        canvas.drawPath(Path()
          ..moveTo(cx, cy + r * 0.28)
          ..quadraticBezierTo(cx + r * 0.22, cy + r * 0.44, cx + r * 0.32, cy + r * 0.36),
          mouthPaint);
    }
  }

  void _drawBlush(Canvas canvas, double cx, double cy, double r) {
    final blushPaint = Paint()..color = const Color(0x55FF69B4);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.60, cy + r * 0.20), width: r * 0.38, height: r * 0.22), blushPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.60, cy + r * 0.20), width: r * 0.38, height: r * 0.22), blushPaint);
  }

  void _drawZzz(Canvas canvas, double cx, double cy, double r) {
    final zPaint = Paint()
      ..color = const Color(0xCC64B5F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    void drawZ(double x, double y, double size) {
      canvas.drawPath(Path()
        ..moveTo(x, y)
        ..lineTo(x + size, y)
        ..lineTo(x, y + size)
        ..lineTo(x + size, y + size), zPaint);
    }
    drawZ(cx + r * 0.55, cy - r * 1.15, r * 0.12);
    drawZ(cx + r * 0.70, cy - r * 1.35, r * 0.18);
  }

  void _drawBow(Canvas canvas, double cx, double cy, double r) {
    final bowPaint  = Paint()..color = const Color(0xFFE91E63);
    final bowStroke = Paint()
      ..color = const Color(0xFFC2185B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.03;
    final bx = cx + r * 0.36;
    final by = cy - r * 0.98;
    final leftLobe = Path()
      ..moveTo(bx, by)
      ..quadraticBezierTo(bx - r * 0.26, by - r * 0.20, bx - r * 0.30, by + r * 0.04)
      ..quadraticBezierTo(bx - r * 0.14, by + r * 0.06, bx, by);
    canvas..drawPath(leftLobe, bowPaint)..drawPath(leftLobe, bowStroke);
    final rightLobe = Path()
      ..moveTo(bx, by)
      ..quadraticBezierTo(bx + r * 0.26, by - r * 0.20, bx + r * 0.30, by + r * 0.04)
      ..quadraticBezierTo(bx + r * 0.14, by + r * 0.06, bx, by);
    canvas..drawPath(rightLobe, bowPaint)..drawPath(rightLobe, bowStroke);
    canvas.drawCircle(Offset(bx, by), r * 0.06, Paint()..color = const Color(0xFFF48FB1));
  }

  void _drawStarBadge(Canvas canvas, double cx, double cy, double r) {
    final micPaint   = Paint()..color = const Color(0xFFFFEB3B);
    final micStroke  = Paint()
      ..color = const Color(0xFFF9A825)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.035;
    _drawStar(canvas, cx + r * 0.70, cy + r * 0.30, r * 0.14, micPaint);
    _drawStar(canvas, cx + r * 0.70, cy + r * 0.30, r * 0.14, micStroke);
  }

  void _drawCrown(Canvas canvas, double cx, double cy, double r) {
    final goldPaint  = Paint()..color = const Color(0xFFFFD700);
    final goldStroke = Paint()
      ..color = const Color(0xFFFF8F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04;
    final topY  = cy - r * 1.16;
    final baseY = cy - r * 0.86;
    final halfW = r * 0.48;
    final crown = Path()
      ..moveTo(cx - halfW, baseY)
      ..lineTo(cx - halfW * 0.7, topY + r * 0.18)
      ..lineTo(cx - halfW * 0.5, baseY - r * 0.08)
      ..lineTo(cx - halfW * 0.2, topY - r * 0.04)
      ..lineTo(cx, baseY - r * 0.08)
      ..lineTo(cx + halfW * 0.2, topY - r * 0.04)
      ..lineTo(cx + halfW * 0.5, baseY - r * 0.08)
      ..lineTo(cx + halfW * 0.7, topY + r * 0.18)
      ..lineTo(cx + halfW, baseY)
      ..close();
    canvas..drawPath(crown, goldPaint)..drawPath(crown, goldStroke);
    canvas.drawCircle(Offset(cx, topY - r * 0.02), r * 0.07, Paint()..color = const Color(0xFFE040FB));
    canvas.drawCircle(Offset(cx - halfW * 0.2, topY - r * 0.02), r * 0.05, Paint()..color = const Color(0xFF29B6F6));
    canvas.drawCircle(Offset(cx + halfW * 0.2, topY - r * 0.02), r * 0.05, Paint()..color = const Color(0xFF66BB6A));
  }

  void _drawSparkles(Canvas canvas, double cx, double cy, double r) {
    final sparkPaint = Paint()..color = const Color(0xCCFFD740);
    for (final pos in [
      Offset(cx - r * 1.05, cy - r * 0.55),
      Offset(cx + r * 1.05, cy - r * 0.55),
      Offset(cx - r * 1.10, cy + r * 0.20),
      Offset(cx + r * 1.10, cy + r * 0.20),
      Offset(cx, cy - r * 1.22),
    ]) {
      _drawSparkle(canvas, pos.dx, pos.dy, r * 0.10, sparkPaint);
    }
  }

  void _drawSparkle(Canvas canvas, double cx, double cy, double size, Paint paint) {
    canvas.drawPath(Path()
      ..moveTo(cx, cy - size)
      ..lineTo(cx + size * 0.25, cy - size * 0.25)
      ..lineTo(cx + size, cy)
      ..lineTo(cx + size * 0.25, cy + size * 0.25)
      ..lineTo(cx, cy + size)
      ..lineTo(cx - size * 0.25, cy + size * 0.25)
      ..lineTo(cx - size, cy)
      ..lineTo(cx - size * 0.25, cy - size * 0.25)
      ..close(), paint);
  }

  @override
  bool shouldRepaint(covariant NunuPainter old) =>
      old.expression != expression ||
      old.level != level ||
      old.blinkProgress != blinkProgress ||
      old.earWiggle != earWiggle;
}
