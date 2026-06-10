import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class FanCounterWidget extends StatefulWidget {
  final int fans;

  const FanCounterWidget({super.key, required this.fans});

  @override
  State<FanCounterWidget> createState() => _FanCounterWidgetState();
}

class _FanCounterWidgetState extends State<FanCounterWidget> {
  // Where the count-up animation starts from (last shown value)
  int _from = 0;

  @override
  void didUpdateWidget(FanCounterWidget old) {
    super.didUpdateWidget(old);
    if (old.fans != widget.fans) _from = old.fans;
  }

  String _format(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}萬';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gold gradient number, counting up on change
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.starGold, Color(0xFFFFF176)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: TweenAnimationBuilder<double>(
            key: ValueKey(widget.fans),
            tween: Tween(begin: _from.toDouble(), end: widget.fans.toDouble()),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, value, _) => Text(
              _format(value.round()),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.people_rounded, color: AppColors.starGold, size: 16),
            SizedBox(width: 4),
            Text(
              AppStrings.fans,
              style: TextStyle(
                color: AppColors.starGold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
