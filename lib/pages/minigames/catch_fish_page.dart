import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/minigame_constants.dart';
import '../../providers/game_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nunu_painter.dart';

// ─────────────────────────────────────────────────────────────────
//  Fish model
// ─────────────────────────────────────────────────────────────────
class _Fish {
  final int id;
  final bool gold;
  /// 0..1 fraction of arena width
  double x;
  double y;
  /// units / second across the arena (positive = rightward)
  double vx;
  bool caught = false;

  _Fish({
    required this.id,
    required this.gold,
    required this.x,
    required this.y,
    required this.vx,
  });
}

class CatchFishPage extends ConsumerStatefulWidget {
  const CatchFishPage({super.key});
  @override
  ConsumerState<CatchFishPage> createState() => _CatchFishPageState();
}

class _CatchFishPageState extends ConsumerState<CatchFishPage> {
  Timer? _gameTimer;
  Timer? _countdown;

  final _rand = math.Random();
  final List<_Fish> _fishes = [];
  int _nextId = 0;
  int _smallCaught = 0;
  int _goldCaught = 0;
  double _secondsLeft = MinigameConstants.fishDurationSec.toDouble();

  // Nunu's horizontal position (0..1)
  double _nunuX = 0.5;

  // Arena size, set on first layout
  double _arenaW = 0;
  double _arenaH = 0;

  bool _started = false;
  bool _finished = false;

  // ── Spawn loop ────────────────────────────────────────────
  void _start() {
    setState(() => _started = true);
    // Spawn a fish every 700-1300 ms
    _scheduleSpawn();
    // 30 fps physics step
    _gameTimer = Timer.periodic(const Duration(milliseconds: 33), _tick);
    // 1 hz countdown
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft -= 1);
      if (_secondsLeft <= 0) _finish();
    });
  }

  void _scheduleSpawn() {
    if (_finished || !mounted) return;
    Timer(Duration(milliseconds: 600 + _rand.nextInt(700)), () {
      if (_finished || !mounted) return;
      _spawnFish();
      _scheduleSpawn();
    });
  }

  void _spawnFish() {
    if (_arenaW == 0) return;
    final fromLeft = _rand.nextBool();
    final speed = 0.18 + _rand.nextDouble() * 0.18; // 0.18-0.36 of arena width per second
    final gold = _rand.nextDouble() < 0.20;
    _fishes.add(_Fish(
      id: _nextId++,
      gold: gold,
      x: fromLeft ? -0.1 : 1.1,
      y: 0.55 + _rand.nextDouble() * 0.35, // bottom half
      vx: fromLeft ? speed : -speed,
    ));
  }

  // ── Physics tick (33 ms) ──────────────────────────────────
  void _tick(Timer t) {
    if (!mounted) return;
    const dt = 0.033;
    final caught = <int>[];

    for (final f in _fishes) {
      if (f.caught) continue;
      f.x += f.vx * dt;
      if (f.x < -0.2 || f.x > 1.2) caught.add(f.id);
    }

    // Collision check with Nunu hit-box (around _nunuX, y ~ 0.30 + 0.20 radius)
    const nunuY = 0.30;
    const catchRadius = 0.10;
    for (final f in _fishes) {
      if (f.caught) continue;
      final dx = (f.x - _nunuX).abs();
      final dy = (f.y - nunuY).abs();
      // Only count when Nunu is "low" enough to catch (we drop her when tapped)
      if (_diving && dx < catchRadius * 1.4 && dy < catchRadius * 1.6) {
        f.caught = true;
        if (f.gold) {
          _goldCaught++;
        } else {
          _smallCaught++;
        }
      }
    }

    // Remove fish that went off-screen
    _fishes.removeWhere((f) => caught.contains(f.id));

    setState(() {});
  }

  // ── Diving animation ──────────────────────────────────────
  bool _diving = false;
  Timer? _diveResetTimer;

  void _dive() {
    if (_finished) return;
    _diveResetTimer?.cancel();
    setState(() => _diving = true);
    _diveResetTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _diving = false);
    });
  }

  // ── Finish ────────────────────────────────────────────────
  void _finish() {
    if (_finished) return;
    _finished = true;
    _gameTimer?.cancel();
    _countdown?.cancel();
    final hearts = (_smallCaught * MinigameConstants.fishSmallReward +
            _goldCaught * MinigameConstants.fishGoldReward)
        .clamp(0, MinigameConstants.maxRewardPerPlay);
    ref.read(gameProvider.notifier).addMinigameReward(
          gameId: 'fish',
          hearts: hearts,
          moodGain: MinigameConstants.fishMoodGain,
        );
    setState(() {});
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _countdown?.cancel();
    _diveResetTimer?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          AppStrings.fishName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Ocean gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A0533),
                      Color(0xFF1565C0),
                      Color(0xFF0277BD),
                      Color(0xFF01579B),
                    ],
                  ),
                ),
              ),
            ),
            if (!_started && !_finished) _buildStart(),
            if (_started && !_finished) _buildArena(),
            if (_finished) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildStart() => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🐟', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 14),
                const Text(
                  AppStrings.fishName,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '左右拖曳移動 Nunu\n點擊讓 Nunu 撲下去抓魚！\n金魚加分更多 ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _start,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF29B6F6),
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  ),
                  child: const Text(
                    AppStrings.startGame,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildArena() {
    return LayoutBuilder(
      builder: (context, c) {
        _arenaW = c.maxWidth;
        _arenaH = c.maxHeight;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) {
            final dx = d.delta.dx / _arenaW;
            setState(() => _nunuX = (_nunuX + dx).clamp(0.06, 0.94));
          },
          onTap: _dive,
          child: Stack(
            children: [
              // HUD
              Positioned(
                top: 12, left: 16, right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _chip('${AppStrings.time}  ${_secondsLeft.toStringAsFixed(0)}s'),
                    _chip('🐟 $_smallCaught   ✨ $_goldCaught'),
                  ],
                ),
              ),
              // Fish
              ..._fishes.where((f) => !f.caught).map((f) {
                return Positioned(
                  left: f.x * _arenaW - 28,
                  top: f.y * _arenaH - 22,
                  child: Transform.scale(
                    scaleX: f.vx > 0 ? 1 : -1,
                    child: _FishSprite(gold: f.gold),
                  ),
                );
              }),
              // Nunu (the player)
              Positioned(
                left: _nunuX * _arenaW - 48,
                top: (_diving ? 0.50 : 0.30) * _arenaH - 48,
                child: AnimatedScale(
                  scale: _diving ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.glassFill,
                      border: Border.all(color: AppColors.glassBorder, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x8829B6F6), blurRadius: 24, spreadRadius: 4),
                      ],
                    ),
                    child: const CustomPaint(
                      painter: NunuPainter(expression: NunuExpression.excited),
                      size: Size(96, 96),
                    ),
                  ),
                ),
              ),
              // Bottom hint
              const Positioned(
                bottom: 24, left: 0, right: 0,
                child: Center(
                  child: Text(
                    '← 拖曳移動 · 點擊撲下抓魚 →',
                    style: TextStyle(color: AppColors.textOnDarkFaint, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      );

  Widget _buildResults() {
    final hearts = (_smallCaught * MinigameConstants.fishSmallReward +
            _goldCaught * MinigameConstants.fishGoldReward)
        .clamp(0, MinigameConstants.maxRewardPerPlay);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎣', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              const Text(AppStrings.gameOver,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _row('🐟 小魚', '$_smallCaught', Colors.white),
              _row('✨ 金魚', '$_goldCaught', AppColors.starGold),
              _row('⚡ 活力', '+${MinigameConstants.fishMoodGain}', const Color(0xFF66BB6A)),
              const Divider(color: AppColors.glassBorder, height: 24),
              const Text(AppStrings.yourReward, style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13)),
              const SizedBox(height: 6),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [AppColors.starGold, AppColors.idolPink],
                ).createShader(b),
                child: Text(
                  '+$hearts ❤️',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF29B6F6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(AppStrings.backToHub,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────
//  Fish sprite (custom-painted)
// ─────────────────────────────────────────────────────────────────
class _FishSprite extends StatelessWidget {
  final bool gold;
  const _FishSprite({required this.gold});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56, height: 44,
      child: CustomPaint(painter: _FishPainter(gold: gold)),
    );
  }
}

class _FishPainter extends CustomPainter {
  final bool gold;
  _FishPainter({required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Paint()
      ..shader = LinearGradient(
        colors: gold
            ? const [Color(0xFFFFE082), Color(0xFFFFA000)]
            : const [Color(0xFF80DEEA), Color(0xFF00838F)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    final outline = Paint()
      ..color = gold ? const Color(0xFFE65100) : const Color(0xFF004D40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Body (oval)
    final bodyRect = Rect.fromLTWH(8, 8, w - 24, h - 16);
    canvas.drawOval(bodyRect, body);
    canvas.drawOval(bodyRect, outline);

    // Tail
    final tail = Path()
      ..moveTo(w - 16, h / 2)
      ..lineTo(w - 2, 4)
      ..lineTo(w - 2, h - 4)
      ..close();
    canvas.drawPath(tail, body);
    canvas.drawPath(tail, outline);

    // Eye
    canvas.drawCircle(Offset(16, h / 2 - 2), 3.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(16, h / 2 - 2), 2, Paint()..color = Colors.black);

    // Sparkle for gold
    if (gold) {
      final s = Paint()..color = const Color(0xFFFFF59D);
      canvas.drawCircle(Offset(w / 2, h / 2), 3, s);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
