import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/game_constants.dart';
import 'nunu_painter.dart';

class CatWidget extends StatefulWidget {
  /// Called with the combo multiplier (1, 2, or 3) on each tap.
  final void Function(int multiplier) onTap;

  /// Nunu's current mood (0–100) — drives expression.
  final int mood;

  /// Current level — drives costume accessories.
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _scale;

  // ── Combo state ──────────────────────────────────────────
  int _comboCount = 0;
  Timer? _comboTimer;

  // ── Expression state ─────────────────────────────────────
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
    _updateExpressionFromMood();
  }

  @override
  void didUpdateWidget(CatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood && _expression != NunuExpression.excited) {
      _updateExpressionFromMood();
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _comboTimer?.cancel();
    _expressionResetTimer?.cancel();
    super.dispose();
  }

  // ── Expression helpers ────────────────────────────────────
  void _updateExpressionFromMood() {
    if (!mounted) return;
    NunuExpression newExpr;
    if (widget.mood < 20) {
      newExpr = NunuExpression.sleeping;
    } else if (widget.mood >= 80) {
      newExpr = NunuExpression.happy;
    } else {
      newExpr = NunuExpression.idle;
    }
    if (_expression != NunuExpression.excited &&
        _expression != NunuExpression.levelUp) {
      setState(() => _expression = newExpr);
    }
  }

  void _setExpressionTemporarily(NunuExpression expr, int durationMs) {
    _expressionResetTimer?.cancel();
    setState(() => _expression = expr);
    _expressionResetTimer = Timer(Duration(milliseconds: durationMs), () {
      if (mounted) _updateExpressionFromMood();
    });
  }

  // ── Level-up flash (called from outside via GlobalKey or rebuild) ─
  void triggerLevelUpExpression() {
    _setExpressionTemporarily(NunuExpression.levelUp, 2500);
  }

  // ── Tap handler ───────────────────────────────────────────
  void _handleTap() {
    // Bounce animation
    _bounceCtrl.forward().then((_) => _bounceCtrl.reverse());

    // Increment combo
    _comboTimer?.cancel();
    _comboCount++;

    // Restart combo window timer
    _comboTimer = Timer(
      Duration(milliseconds: GameConstants.comboWindowMs),
      () {
        setState(() => _comboCount = 0);
        _updateExpressionFromMood();
      },
    );

    final multiplier = GameConstants.comboMultiplier(_comboCount);

    // Update expression based on combo
    if (multiplier == 3) {
      _setExpressionTemporarily(NunuExpression.excited, 600);
    } else if (multiplier == 2) {
      _setExpressionTemporarily(NunuExpression.happy, 600);
    }

    setState(() {}); // refresh combo display

    widget.onTap(multiplier);
  }

  // ── Combo display ─────────────────────────────────────────
  Color get _comboColor {
    final m = GameConstants.comboMultiplier(_comboCount);
    if (m == 3) return const Color(0xFFE040FB);
    if (m == 2) return const Color(0xFFFF5722);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final multiplier = GameConstants.comboMultiplier(_comboCount);

    return Column(
      children: [
        // ── Combo badge ──────────────────────────────────
        AnimatedOpacity(
          opacity: _comboCount >= GameConstants.combo2xThreshold ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: _comboColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _comboColor.withAlpha(120),
                  blurRadius: 10,
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
        const SizedBox(height: 8),

        // ── Cat ───────────────────────────────────────────
        GestureDetector(
          onTap: _handleTap,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBorder,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBorder.withAlpha(80),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: NunuPainter(
                  expression: _expression,
                  level: widget.level,
                ),
                size: const Size(200, 200),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
