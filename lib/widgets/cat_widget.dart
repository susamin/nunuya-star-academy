import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/game_constants.dart';
import 'nunu_painter.dart';

class CatWidget extends StatefulWidget {
  final void Function(int multiplier) onTap;
  final int mood;
  final int level;

  const CatWidget({
    super.key,
    required this.onTap,
    required this.mood,
    required this.level,
  });

  @override
  State<CatWidget> createState() => _CatWidgetState();
}

class _CatWidgetState extends State<CatWidget>
    with TickerProviderStateMixin {

  // ── Tap bounce ────────────────────────────────────────────────
  late final AnimationController _bounceCtrl;
  late final Animation<double> _scaleAnim;

  // ── Breathing glow (outer shadow pulse) ───────────────────────
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // ── Body float (gentle sine bob) ─────────────────────────────
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // ── Ear wiggle (derived from float phase) ─────────────────────
  // earWiggle = sin(float phase * pi) ∈ [-1, 1]

  // ── Blink ────────────────────────────────────────────────────
  late final AnimationController _blinkCtrl;
  Timer? _blinkTimer;

  // ── Combined repaint listenable ───────────────────────────────
  late final Listenable _liveListenable;

  // ── Combo ────────────────────────────────────────────────────
  int _comboCount = 0;
  Timer? _comboTimer;

  // ── Expression ───────────────────────────────────────────────
  NunuExpression _expression = NunuExpression.idle;
  Timer? _expressionResetTimer;

  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Tap bounce (80 ms, no repeat)
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.86).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    // Glow pulse (2400 ms, reverse-repeat)
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.50, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    // Body float (2600 ms, reverse-repeat)
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -7.0, end: 7.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    // Blink (200 ms, fire → reverse via timer)
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Merged listenable so AnimatedBuilder rebuilds on every animation tick
    _liveListenable = Listenable.merge([_floatCtrl, _blinkCtrl]);

    _updateExpressionFromMood();
    _scheduleBlink();
  }

  @override
  void didUpdateWidget(CatWidget old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood &&
        _expression != NunuExpression.excited &&
        _expression != NunuExpression.levelUp) {
      _updateExpressionFromMood();
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    _blinkCtrl.dispose();
    _comboTimer?.cancel();
    _expressionResetTimer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  // ── Expression helpers ────────────────────────────────────────
  void _updateExpressionFromMood() {
    if (!mounted) return;
    NunuExpression next;
    if (widget.mood < 20) {
      next = NunuExpression.sleeping;
    } else if (widget.mood >= 80) {
      next = NunuExpression.happy;
    } else {
      next = NunuExpression.idle;
    }
    if (_expression != NunuExpression.excited &&
        _expression != NunuExpression.levelUp) {
      setState(() => _expression = next);
    }
  }

  void _setTempExpression(NunuExpression expr, int ms) {
    _expressionResetTimer?.cancel();
    setState(() => _expression = expr);
    _expressionResetTimer = Timer(Duration(milliseconds: ms), () {
      if (mounted) _updateExpressionFromMood();
    });
  }

  // ── Blink scheduler ───────────────────────────────────────────
  void _scheduleBlink() {
    if (!mounted) return;
    // Random gap 2.5 – 5.5 seconds between blinks
    final delayMs = 2500 + (_random.nextDouble() * 3000).toInt();
    _blinkTimer = Timer(Duration(milliseconds: delayMs), _doBlink);
  }

  void _doBlink() {
    if (!mounted) return;
    // Only blink during idle/happy — not during excited/sleeping/levelUp
    if (_expression == NunuExpression.excited ||
        _expression == NunuExpression.sleeping ||
        _expression == NunuExpression.levelUp) {
      _scheduleBlink();
      return;
    }
    _blinkCtrl.forward().then((_) {
      if (!mounted) return;
      _blinkCtrl.reverse().then((_) {
        if (mounted) _scheduleBlink();
      });
    });
  }

  // ── Tap handler ───────────────────────────────────────────────
  void _handleTap() {
    _bounceCtrl.forward().then((_) => _bounceCtrl.reverse());

    _comboTimer?.cancel();
    _comboCount++;
    _comboTimer = Timer(
      Duration(milliseconds: GameConstants.comboWindowMs),
      () => setState(() => _comboCount = 0),
    );

    final multiplier = GameConstants.comboMultiplier(_comboCount);
    if (multiplier == 3) {
      _setTempExpression(NunuExpression.excited, 600);
    } else if (multiplier == 2) {
      _setTempExpression(NunuExpression.happy, 600);
    }

    setState(() {});
    widget.onTap(multiplier);
  }

  // ── Combo colours ─────────────────────────────────────────────
  Color get _comboStart {
    final m = GameConstants.comboMultiplier(_comboCount);
    return m == 3 ? const Color(0xFFE040FB) : m == 2 ? const Color(0xFFFF5722) : Colors.transparent;
  }
  Color get _comboEnd {
    final m = GameConstants.comboMultiplier(_comboCount);
    return m == 3 ? const Color(0xFF9C27B0) : m == 2 ? const Color(0xFFE91E63) : Colors.transparent;
  }

  // ─────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final multiplier  = GameConstants.comboMultiplier(_comboCount);
    final showCombo   = _comboCount >= GameConstants.combo2xThreshold;

    return Column(
      children: [
        // ── Combo badge ──────────────────────────────────────
        AnimatedOpacity(
          opacity: showCombo ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_comboStart, _comboEnd]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: _comboStart.withAlpha(120),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              '${AppStrings.comboLabel}  ×$multiplier  🔥  $_comboCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ── Animated cat ─────────────────────────────────────
        GestureDetector(
          onTap: _handleTap,
          child: AnimatedBuilder(
            animation: _liveListenable,
            builder: (_, child) {
              // Derive earWiggle from float phase: peaks at top/bottom of bob
              final earWiggle = math.sin(_floatCtrl.value * math.pi) * 0.9;
              final blinkProg = _blinkCtrl.value;

              return Transform.translate(
                // Gentle up-down float
                offset: Offset(0, _floatAnim.value),
                child: AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (_, innerChild) {
                    return Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(255, 152, 0, 0.55 * _glowAnim.value),
                            blurRadius: 36 * _glowAnim.value,
                            spreadRadius: 6 * _glowAnim.value,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(255, 107, 157, 0.40 * _glowAnim.value),
                            blurRadius: 58 * _glowAnim.value,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.glassFill,
                            border: Border.all(
                              color: AppColors.glassBorder,
                              width: 2.5,
                            ),
                          ),
                          child: CustomPaint(
                            painter: NunuPainter(
                              expression: _expression,
                              level: widget.level,
                              blinkProgress: blinkProg,
                              earWiggle: earWiggle,
                            ),
                            size: const Size(220, 220),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
