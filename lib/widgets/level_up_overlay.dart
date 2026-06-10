import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'nunu_painter.dart';

/// Full-screen level-up celebration: confetti burst + Nunu with star
/// eyes + the new title card. Dismisses on tap or after 2.8 s.
class LevelUpOverlay extends StatefulWidget {
  final int newLevel;
  final String newTitle;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    super.key,
    required this.newLevel,
    required this.newTitle,
    required this.onDismiss,
  });

  /// Insert into the root overlay. Self-removes.
  static void show(BuildContext context,
      {required int newLevel, required String newTitle}) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => LevelUpOverlay(
        newLevel: newLevel,
        newTitle: newTitle,
        onDismiss: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
  }

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _confettiT;
  late final Animation<double> _cardScale;
  late final Animation<double> _fade;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _confettiT = CurvedAnimation(parent: _ctrl, curve: Curves.linear);
    _cardScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 18,
      ),
      TweenSequenceItem(tween: ConstantTween(1.06), weight: 4),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 8,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
    ]).animate(_ctrl);
    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 78),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 12),
    ]).animate(_ctrl);

    _ctrl.forward().whenComplete(_dismiss);
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return GestureDetector(
          onTap: _dismiss,
          child: Opacity(
            opacity: _fade.value,
            child: Stack(
              children: [
                // Dim backdrop
                Positioned.fill(
                  child: Container(color: const Color(0xB31A0533)),
                ),
                // Confetti
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ConfettiPainter(t: _confettiT.value),
                    ),
                  ),
                ),
                // Celebration card
                Center(
                  child: Transform.scale(
                    scale: _cardScale.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(
                          vertical: 28, horizontal: 28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF3D1C6E), Color(0xFF6B2FA0)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: AppColors.starGold, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x80FFD700),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Nunu with star eyes
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CustomPaint(
                              painter: NunuPainter(
                                expression: NunuExpression.levelUp,
                                level: widget.newLevel,
                              ),
                              size: const Size(120, 120),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ShaderMask(
                            shaderCallback: (b) => const LinearGradient(
                              colors: [
                                AppColors.starGold,
                                Color(0xFFFFF176),
                                AppColors.starGold,
                              ],
                            ).createShader(b),
                            child: const Text(
                              'LEVEL UP!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Text(
                              'Lv.${widget.newLevel}  ${widget.newTitle}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Nunu 的粉絲增加了！',
                            style: TextStyle(
                              color: AppColors.textOnDarkMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Confetti painter — 60 deterministic particles falling + spinning
// ─────────────────────────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final double t; // 0..1 animation progress
  _ConfettiPainter({required this.t});

  static const _colors = [
    Color(0xFFFFD700), Color(0xFFFF6B9D), Color(0xFFC77DFF),
    Color(0xFF80DEEA), Color(0xFF76FF03), Color(0xFFFFAB40),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(7); // fixed seed → deterministic per frame
    for (int i = 0; i < 60; i++) {
      final x0     = rand.nextDouble();
      final delay  = rand.nextDouble() * 0.3;
      final speed  = 0.7 + rand.nextDouble() * 0.6;
      final drift  = (rand.nextDouble() - 0.5) * 0.3;
      final spin   = rand.nextDouble() * 12;
      final wSize  = 6 + rand.nextDouble() * 7;
      final color  = _colors[i % _colors.length];

      final p = ((t - delay) * speed).clamp(0.0, 1.0);
      if (p <= 0) continue;

      final x = (x0 + drift * p) * size.width;
      final y = p * (size.height + 40) - 20;
      final angle = p * spin;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: wSize, height: wSize * 0.55),
          const Radius.circular(2),
        ),
        Paint()..color = color.withAlpha((255 * (1.0 - p * 0.3)).toInt()),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
