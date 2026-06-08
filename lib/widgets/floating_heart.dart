import 'package:flutter/material.dart';

/// Spawns a floating "+N❤️" label that rises and fades.
/// Wrap it in an [Overlay] entry (see home_page.dart).
class FloatingHeartOverlay extends StatefulWidget {
  final int multiplier;
  final double startX;
  final double startY;
  final VoidCallback onComplete;

  const FloatingHeartOverlay({
    super.key,
    required this.multiplier,
    required this.startX,
    required this.startY,
    required this.onComplete,
  });

  @override
  State<FloatingHeartOverlay> createState() => _FloatingHeartOverlayState();
}

class _FloatingHeartOverlayState extends State<FloatingHeartOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _offsetY;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _offsetY = Tween<double>(begin: 0, end: -90).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_ctrl);

    _ctrl.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bubbleColor {
    switch (widget.multiplier) {
      case 3:
        return const Color(0xFFE040FB); // purple for ×3
      case 2:
        return const Color(0xFFFF5722); // deep orange for ×2
      default:
        return const Color(0xFFE91E63); // pink for ×1
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          return Stack(
            children: [
              Positioned(
                left: widget.startX - 28,
                top: widget.startY + _offsetY.value,
                child: Opacity(
                  opacity: _opacity.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _bubbleColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _bubbleColor.withAlpha(100),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '+${widget.multiplier}❤️',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
