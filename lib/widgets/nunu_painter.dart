import 'package:flutter/material.dart';

class NunuPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = w * 0.42;

    // Colors
    const orange = Color(0xFFFF9800);
    const stripeColor = Color(0x50E65100);
    const pink = Color(0xFFFFB6C1);
    const darkBrown = Color(0xFF5D4037);
    const whiskerColor = Color(0xA0BF8040);

    final bodyPaint = Paint()..color = orange;
    final earPaint = Paint()..color = orange;
    final innerEarPaint = Paint()..color = pink;

    // Ears (drawn behind face)
    final leftEar = Path()
      ..moveTo(cx - r * 0.7, cy - r * 0.55)
      ..lineTo(cx - r * 0.38, cy - r * 1.12)
      ..lineTo(cx - r * 0.02, cy - r * 0.68)
      ..close();
    canvas.drawPath(leftEar, earPaint);

    final rightEar = Path()
      ..moveTo(cx + r * 0.7, cy - r * 0.55)
      ..lineTo(cx + r * 0.38, cy - r * 1.12)
      ..lineTo(cx + r * 0.02, cy - r * 0.68)
      ..close();
    canvas.drawPath(rightEar, earPaint);

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

    // Face circle
    canvas.drawCircle(Offset(cx, cy), r, bodyPaint);

    // Forehead stripes
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

    // Eye whites
    final eyeWhite = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.31, cy - r * 0.08),
        width: r * 0.50,
        height: r * 0.44,
      ),
      eyeWhite,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + r * 0.31, cy - r * 0.08),
        width: r * 0.50,
        height: r * 0.44,
      ),
      eyeWhite,
    );

    // Pupils
    final pupilPaint = Paint()..color = darkBrown;
    canvas.drawCircle(Offset(cx - r * 0.31, cy - r * 0.08), r * 0.16, pupilPaint);
    canvas.drawCircle(Offset(cx + r * 0.31, cy - r * 0.08), r * 0.16, pupilPaint);

    // Eye shine
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - r * 0.25, cy - r * 0.14), r * 0.06, shinePaint);
    canvas.drawCircle(Offset(cx + r * 0.37, cy - r * 0.14), r * 0.06, shinePaint);

    // Nose
    final nosePaint = Paint()..color = const Color(0xFFFF69B4);
    final nose = Path()
      ..moveTo(cx, cy + r * 0.16)
      ..lineTo(cx - r * 0.10, cy + r * 0.28)
      ..lineTo(cx + r * 0.10, cy + r * 0.28)
      ..close();
    canvas.drawPath(nose, nosePaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = darkBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;
    final leftMouth = Path()
      ..moveTo(cx, cy + r * 0.28)
      ..quadraticBezierTo(cx - r * 0.22, cy + r * 0.44, cx - r * 0.32, cy + r * 0.36);
    canvas.drawPath(leftMouth, mouthPaint);
    final rightMouth = Path()
      ..moveTo(cx, cy + r * 0.28)
      ..quadraticBezierTo(cx + r * 0.22, cy + r * 0.44, cx + r * 0.32, cy + r * 0.36);
    canvas.drawPath(rightMouth, mouthPaint);

    // Whiskers
    final whiskerPaint = Paint()
      ..color = whiskerColor
      ..strokeWidth = w * 0.014
      ..strokeCap = StrokeCap.round;
    // Left
    canvas.drawLine(Offset(cx - r * 1.0, cy + r * 0.10), Offset(cx - r * 0.14, cy + r * 0.18), whiskerPaint);
    canvas.drawLine(Offset(cx - r * 1.0, cy + r * 0.24), Offset(cx - r * 0.14, cy + r * 0.25), whiskerPaint);
    canvas.drawLine(Offset(cx - r * 0.95, cy + r * 0.38), Offset(cx - r * 0.14, cy + r * 0.32), whiskerPaint);
    // Right
    canvas.drawLine(Offset(cx + r * 1.0, cy + r * 0.10), Offset(cx + r * 0.14, cy + r * 0.18), whiskerPaint);
    canvas.drawLine(Offset(cx + r * 1.0, cy + r * 0.24), Offset(cx + r * 0.14, cy + r * 0.25), whiskerPaint);
    canvas.drawLine(Offset(cx + r * 0.95, cy + r * 0.38), Offset(cx + r * 0.14, cy + r * 0.32), whiskerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
