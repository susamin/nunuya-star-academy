import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/minigame_constants.dart';
import '../../providers/game_provider.dart';
import '../../widgets/glass_card.dart';

// ─────────────────────────────────────────────────────────────────
//  Falling note (heart) model
// ─────────────────────────────────────────────────────────────────
enum _NoteJudge { pending, perfect, good, miss }

class _Note {
  final int id;
  /// Lane 0, 1, or 2
  final int lane;
  /// Spawn time, in seconds since the game started
  final double spawnTime;
  _NoteJudge state = _NoteJudge.pending;
  _Note({required this.id, required this.lane, required this.spawnTime});
}

// ─────────────────────────────────────────────────────────────────
//  Page
// ─────────────────────────────────────────────────────────────────
class RhythmTapPage extends ConsumerStatefulWidget {
  const RhythmTapPage({super.key});
  @override
  ConsumerState<RhythmTapPage> createState() => _RhythmTapPageState();
}

class _RhythmTapPageState extends ConsumerState<RhythmTapPage>
    with SingleTickerProviderStateMixin {

  static const double _fallSeconds   = 2.0;   // time from spawn to hit line
  static const double _perfectWindow = 0.18;  // seconds, ±
  static const double _goodWindow    = 0.40;

  late final Ticker _ticker = Ticker(_onTick);
  Duration _started = Duration.zero;
  double _now = 0;   // seconds since game start

  final _random = math.Random();
  final List<_Note> _notes = [];

  int _perfectCount = 0;
  int _goodCount    = 0;
  int _missCount    = 0;
  int _combo        = 0;
  int _maxCombo     = 0;
  String _judgeText = '';
  Color _judgeColor = Colors.transparent;
  double _judgeOpacity = 0;
  Timer? _judgeFade;

  bool _started_ = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _generateNotes();
  }

  void _generateNotes() {
    // Distribute notes between 0.0 and (duration - 1.5) seconds, with min gap
    final maxT = MinigameConstants.rhythmDurationSec - 2.0;
    final times = <double>[];
    while (times.length < MinigameConstants.rhythmNoteCount) {
      final t = _random.nextDouble() * maxT;
      // ensure 0.45 s gap to nearest existing time
      if (times.every((x) => (x - t).abs() > 0.45)) times.add(t);
    }
    times.sort();
    for (int i = 0; i < times.length; i++) {
      _notes.add(_Note(
        id: i,
        lane: _random.nextInt(3),
        spawnTime: times[i],
      ));
    }
  }

  void _start() {
    setState(() => _started_ = true);
    _started = Duration.zero;
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (_started == Duration.zero) _started = elapsed;
    final t = (elapsed - _started).inMicroseconds / 1e6;

    // Auto-miss notes that have passed the window
    bool anyMiss = false;
    for (final n in _notes) {
      if (n.state != _NoteJudge.pending) continue;
      final hitTime = n.spawnTime + _fallSeconds;
      if (t > hitTime + _goodWindow) {
        n.state = _NoteJudge.miss;
        _missCount++;
        _combo = 0;
        anyMiss = true;
      }
    }
    if (anyMiss) _showJudge(AppStrings.miss, const Color(0xFF9E9E9E));

    setState(() => _now = t);

    if (t >= MinigameConstants.rhythmDurationSec) {
      _ticker.stop();
      _finish();
    }
  }

  void _showJudge(String text, Color color) {
    _judgeFade?.cancel();
    setState(() {
      _judgeText = text;
      _judgeColor = color;
      _judgeOpacity = 1.0;
    });
    _judgeFade = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _judgeOpacity = 0);
    });
  }

  void _tapLane(int lane) {
    if (_finished || !_started_) return;
    // Find the earliest pending note in this lane near the hit line
    _Note? candidate;
    double bestDelta = double.infinity;
    for (final n in _notes) {
      if (n.state != _NoteJudge.pending) continue;
      if (n.lane != lane) continue;
      final delta = (_now - (n.spawnTime + _fallSeconds)).abs();
      if (delta < bestDelta && delta <= _goodWindow) {
        bestDelta = delta;
        candidate = n;
      }
    }
    if (candidate == null) return; // tap with no note → ignore (no penalty)

    if (bestDelta <= _perfectWindow) {
      candidate.state = _NoteJudge.perfect;
      _perfectCount++;
      _combo++;
      _maxCombo = math.max(_maxCombo, _combo);
      HapticFeedback.mediumImpact();
      _showJudge(AppStrings.perfect, const Color(0xFFFFD700));
    } else {
      candidate.state = _NoteJudge.good;
      _goodCount++;
      _combo++;
      _maxCombo = math.max(_maxCombo, _combo);
      HapticFeedback.lightImpact();
      _showJudge(AppStrings.good, const Color(0xFF66BB6A));
    }
    setState(() {});
  }

  int get _totalHearts {
    final base = _perfectCount * MinigameConstants.rhythmPerfectHearts +
        _goodCount * MinigameConstants.rhythmGoodHearts;
    final clearPct = _perfectCount / MinigameConstants.rhythmNoteCount;
    final bonus = clearPct >= 0.9
        ? MinigameConstants.rhythmClearBonus
        : (clearPct >= 0.7 ? MinigameConstants.rhythmClearBonus ~/ 2 : 0);
    return (base + bonus).clamp(0, MinigameConstants.maxRewardPerPlay);
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    final reward = _totalHearts;
    ref.read(gameProvider.notifier).addMinigameReward(
          gameId: 'rhythm',
          hearts: reward,
          moodGain: 10 + _perfectCount,
        );
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _judgeFade?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          AppStrings.rhythmName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background owned by MainScaffold — page is transparent
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(gradient: AppColors.bgGradient),
              ),
            ),
            if (!_started_ && !_finished) _buildStartOverlay(),
            if (_started_ && !_finished) _buildGameplay(),
            if (_finished) _buildResultsOverlay(),
          ],
        ),
      ),
    );
  }

  // ── Start screen ───────────────────────────────────────────
  Widget _buildStartOverlay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎵', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 14),
              const Text(
                AppStrings.rhythmName,
                style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '愛心會從上方掉到圓形判定線\n在愛心進入圈內時點擊獲得 PERFECT！',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.idolPink,
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
  }

  // ── Gameplay ───────────────────────────────────────────────
  Widget _buildGameplay() {
    return LayoutBuilder(
      builder: (context, c) {
        final laneWidth = c.maxWidth / 3;
        final hitLineY  = c.maxHeight - 160;
        final spawnY    = 40.0;
        return Stack(
          children: [
            // Lane dividers + hit line
            CustomPaint(
              size: Size(c.maxWidth, c.maxHeight),
              painter: _LanesPainter(hitLineY: hitLineY),
            ),
            // Falling notes
            ..._notes.where((n) => n.state == _NoteJudge.pending).map((n) {
              final progress =
                  ((_now - n.spawnTime) / _fallSeconds).clamp(-0.2, 1.2);
              if (progress < 0) return const SizedBox.shrink();
              final y = spawnY + (hitLineY - spawnY) * progress;
              return Positioned(
                left: n.lane * laneWidth + (laneWidth - 56) / 2,
                top: y - 28,
                child: _NoteWidget(),
              );
            }),
            // Tap lanes (transparent buttons)
            Positioned(
              left: 0, right: 0,
              top: hitLineY - 80, height: 160,
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _tapLane(i),
                      child: const SizedBox.expand(),
                    ),
                  );
                }),
              ),
            ),
            // Top HUD
            Positioned(
              top: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _hudChip(
                      label: AppStrings.time,
                      value: '${(MinigameConstants.rhythmDurationSec - _now).clamp(0, 99).toStringAsFixed(1)}s',
                    ),
                    _hudChip(
                      label: AppStrings.score,
                      value: '$_perfectCount P  $_goodCount G',
                    ),
                    _hudChip(
                      label: 'COMBO',
                      value: '×$_combo',
                      gold: _combo >= 5,
                    ),
                  ],
                ),
              ),
            ),
            // Center judge text
            Positioned(
              top: hitLineY - 220, left: 0, right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _judgeOpacity,
                  duration: const Duration(milliseconds: 280),
                  child: Center(
                    child: Text(
                      _judgeText,
                      style: TextStyle(
                        color: _judgeColor,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: _judgeColor.withAlpha(140),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _hudChip({required String label, required String value, bool gold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textOnDarkFaint, fontSize: 10, letterSpacing: 1)),
          Text(
            value,
            style: TextStyle(
              color: gold ? AppColors.starGold : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Results ────────────────────────────────────────────────
  Widget _buildResultsOverlay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              const Text(
                AppStrings.gameOver,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _resultRow('PERFECT', '$_perfectCount', const Color(0xFFFFD700)),
              _resultRow('GOOD',    '$_goodCount',    const Color(0xFF66BB6A)),
              _resultRow('MISS',    '$_missCount',    const Color(0xFFEF5350)),
              _resultRow('MAX COMBO', '×$_maxCombo',  Colors.white),
              const Divider(color: AppColors.glassBorder, height: 24),
              Text(
                AppStrings.yourReward,
                style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13),
              ),
              const SizedBox(height: 6),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [AppColors.starGold, AppColors.idolPink],
                ).createShader(b),
                child: Text(
                  '+$_totalHearts ❤️',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.idolPink,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    AppStrings.backToHub,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color) {
    return Padding(
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
}

// ─────────────────────────────────────────────────────────────────
//  Falling heart note widget
// ─────────────────────────────────────────────────────────────────
class _NoteWidget extends StatelessWidget {
  const _NoteWidget();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56, height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFF8A80), Color(0xFFD81B60)],
        ),
        boxShadow: [
          BoxShadow(color: Color(0x88FF1744), blurRadius: 14, spreadRadius: 1),
        ],
      ),
      child: const Center(child: Text('❤️', style: TextStyle(fontSize: 26))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Lane / hit-line painter
// ─────────────────────────────────────────────────────────────────
class _LanesPainter extends CustomPainter {
  final double hitLineY;
  _LanesPainter({required this.hitLineY});

  @override
  void paint(Canvas canvas, Size size) {
    final laneW = size.width / 3;

    // Vertical lane dividers
    final divider = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(laneW, 0), Offset(laneW, size.height - 60), divider);
    canvas.drawLine(Offset(laneW * 2, 0), Offset(laneW * 2, size.height - 60), divider);

    // Hit line (glowing)
    final glow = Paint()
      ..color = const Color(0x66FFEB3B)
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawLine(Offset(8, hitLineY), Offset(size.width - 8, hitLineY), glow);

    final core = Paint()
      ..color = const Color(0xFFFFEB3B)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(8, hitLineY), Offset(size.width - 8, hitLineY), core);

    // Lane target circles on hit line
    for (int i = 0; i < 3; i++) {
      final cx = laneW * i + laneW / 2;
      canvas.drawCircle(
        Offset(cx, hitLineY),
        34,
        Paint()
          ..color = const Color(0x33FFEB3B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        Offset(cx, hitLineY),
        34,
        Paint()..color = const Color(0x18FFFFFF),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LanesPainter old) => old.hitLineY != hitLineY;
}

// ─────────────────────────────────────────────────────────────────
//  Lightweight Ticker (no SchedulerBinding import needed because we use it from material)
// ─────────────────────────────────────────────────────────────────
class Ticker {
  final void Function(Duration elapsed) onTick;
  late final _ticker = _ScheduledTicker(onTick);
  Ticker(this.onTick);
  void start() => _ticker.start();
  void stop()  => _ticker.stop();
  void dispose() => _ticker.dispose();
}

class _ScheduledTicker {
  final void Function(Duration) cb;
  bool _running = false;
  Duration _origin = Duration.zero;
  _ScheduledTicker(this.cb);

  void start() {
    if (_running) return;
    _running = true;
    _origin = Duration.zero;
    WidgetsBinding.instance.scheduleFrameCallback(_step);
  }

  void _step(Duration ts) {
    if (!_running) return;
    if (_origin == Duration.zero) _origin = ts;
    cb(ts - _origin);
    WidgetsBinding.instance.scheduleFrameCallback(_step);
  }

  void stop() => _running = false;
  void dispose() => _running = false;
}
