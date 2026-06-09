import 'dart:async';
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
  // ── Bounce animation ──────────────────────────────────────
  late final AnimationController _bounceCtrl;
  late final Animation<double> _scale;

  // ── Breathing glow animation ──────────────────────────────
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // ── Combo state ───────────────────────────────────────────
  int _comboCount = 0;
  Timer? _comboTimer;

  // ── Expression state ──────────────────────────────────────
  NunuExpression _expression = NunuExpression.idle;
  Timer? _expressionResetTimer;

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.86).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _updateExpressionFromMood();
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
    _comboTimer?.cancel();
    _expressionResetTimer?.cancel();
    super.dispose();
  }

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

  Color get _comboGradientStart {
    final m = GameConstants.comboMultiplier(_comboCount);
    if (m == 3) return const Color(0xFFE040FB);
    if (m == 2) return const Color(0xFFFF5722);
    return Colors.transparent;
  }

  Color get _comboGradientEnd {
    final m = GameConstants.comboMultiplier(_comboCount);
    if (m == 3) return const Color(0xFF9C27B0);
    if (m == 2) return const Color(0xFFE91E63);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final multiplier = GameConstants.comboMultiplier(_comboCount);
    final showCombo = _comboCount >= GameConstants.combo2xThreshold;

    return Column(
      children: [
        // ── Combo badge ──────────────────────────────────────
        AnimatedOpacity(
          opacity: showCombo ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_comboGradientStart, _comboGradientEnd],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: _comboGradientStart.withAlpha(120),
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

        // ── Cat with breathing glow ───────────────────────────
        GestureDetector(
          onTap: _handleTap,
          child: AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, child) {
              return Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(255, 152, 0,
                          0.55 * _glowAnim.value), // orange
                      blurRadius: 36 * _glowAnim.value,
                      spreadRadius: 6 * _glowAnim.value,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(255, 107, 157,
                          0.40 * _glowAnim.value), // pink
                      blurRadius: 58 * _glowAnim.value,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: ScaleTransition(
              scale: _scale,
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
                  ),
                  size: const Size(220, 220),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
