import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/minigame_constants.dart';
import '../../providers/game_provider.dart';
import '../../widgets/glass_card.dart';

class _Card {
  final int id;
  final String emoji;
  bool flipped = false;
  bool matched = false;
  _Card({required this.id, required this.emoji});
}

class MemoryMatchPage extends ConsumerStatefulWidget {
  const MemoryMatchPage({super.key});
  @override
  ConsumerState<MemoryMatchPage> createState() => _MemoryMatchPageState();
}

class _MemoryMatchPageState extends ConsumerState<MemoryMatchPage> {
  static const _emojis = ['🐟', '🧶', '🥛', '🐭', '🦴', '🔔'];
  late final List<_Card> _cards;
  _Card? _firstPick;
  bool _locking = false;

  bool _started = false;
  bool _finished = false;
  int _pairsFound = 0;
  int _moves      = 0;
  double _secondsLeft = MinigameConstants.memoryDurationSec.toDouble();
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _cards = _buildDeck();
  }

  List<_Card> _buildDeck() {
    final deck = <_Card>[];
    int id = 0;
    for (final e in _emojis) {
      deck.add(_Card(id: id++, emoji: e));
      deck.add(_Card(id: id++, emoji: e));
    }
    deck.shuffle();
    return deck;
  }

  void _start() {
    setState(() => _started = true);
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft -= 1);
      if (_secondsLeft <= 0) _finish();
    });
  }

  void _tapCard(_Card c) {
    if (_locking || c.flipped || c.matched || _finished) return;
    setState(() => c.flipped = true);

    if (_firstPick == null) {
      _firstPick = c;
      return;
    }

    _moves++;

    if (_firstPick!.emoji == c.emoji) {
      // Match!
      HapticFeedback.lightImpact();
      setState(() {
        _firstPick!.matched = true;
        c.matched = true;
        _pairsFound++;
      });
      _firstPick = null;
      if (_pairsFound >= MinigameConstants.memoryPairCount) _finish();
    } else {
      // Not a match — flip both back after 700ms
      _locking = true;
      final a = _firstPick!;
      _firstPick = null;
      Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          a.flipped = false;
          c.flipped = false;
          _locking = false;
        });
      });
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _countdown?.cancel();

    final base = _pairsFound * MinigameConstants.memoryRewardPerPair;
    final cleared = _pairsFound == MinigameConstants.memoryPairCount;
    final timeBonus = cleared ? MinigameConstants.memoryTimeBonus : 0;
    // Penalise moves heavier than perfect (perfect = pairCount)
    final movePenalty =
        (_moves > MinigameConstants.memoryPairCount * 2)
            ? (_moves - MinigameConstants.memoryPairCount * 2) * 2
            : 0;
    final reward = (base + timeBonus - movePenalty)
        .clamp(0, MinigameConstants.maxRewardPerPlay);

    ref.read(gameProvider.notifier).addMinigameReward(
          gameId: 'memory',
          hearts: reward,
          moodGain: cleared ? 15 : 5,
        );
    setState(() {});
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          AppStrings.memoryName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(gradient: AppColors.bgGradient),
              ),
            ),
            if (!_started && !_finished) _buildStart(),
            if (_started && !_finished) _buildBoard(),
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
                const Text('🎴', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 14),
                const Text(
                  AppStrings.memoryName,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '翻牌找出 6 對相同圖案\n步驟越少獎勵越多',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _start,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAB47BC),
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

  Widget _buildBoard() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _chip('${AppStrings.time}  ${_secondsLeft.toStringAsFixed(0)}s'),
              _chip('配對 $_pairsFound / 6'),
              _chip('步驟 $_moves'),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: _cards.length,
              itemBuilder: (_, i) => _CardTile(
                card: _cards[i],
                onTap: () => _tapCard(_cards[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      );

  Widget _buildResults() {
    final base = _pairsFound * MinigameConstants.memoryRewardPerPair;
    final cleared = _pairsFound == MinigameConstants.memoryPairCount;
    final timeBonus = cleared ? MinigameConstants.memoryTimeBonus : 0;
    final movePenalty = (_moves > MinigameConstants.memoryPairCount * 2)
        ? (_moves - MinigameConstants.memoryPairCount * 2) * 2
        : 0;
    final reward = (base + timeBonus - movePenalty)
        .clamp(0, MinigameConstants.maxRewardPerPlay);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(cleared ? '🏆' : '🎴', style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              Text(
                cleared ? '完美過關！' : AppStrings.gameOver,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _row('配對成功', '$_pairsFound / 6', Colors.white),
              _row('翻牌步驟', '$_moves', Colors.white),
              if (cleared) _row('過關獎勵', '+$timeBonus', const Color(0xFFFFD700)),
              if (movePenalty > 0)
                _row('多步扣分', '-$movePenalty', const Color(0xFFEF5350)),
              const Divider(color: AppColors.glassBorder, height: 24),
              const Text(AppStrings.yourReward, style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13)),
              const SizedBox(height: 6),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [AppColors.starGold, AppColors.idolPink],
                ).createShader(b),
                child: Text(
                  '+$reward ❤️',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAB47BC),
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
//  Card tile (flip animation)
// ─────────────────────────────────────────────────────────────────
class _CardTile extends StatelessWidget {
  final _Card card;
  final VoidCallback onTap;
  const _CardTile({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final showFront = card.flipped || card.matched;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: showFront
            ? Container(
                key: ValueKey('front-${card.id}'),
                decoration: BoxDecoration(
                  gradient: card.matched
                      ? const LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFFFE082), Color(0xFFFFA000)],
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha(120), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: (card.matched ? const Color(0xFF2E7D32) : const Color(0xFFFFA000))
                          .withAlpha(120),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(card.emoji, style: const TextStyle(fontSize: 42)),
                ),
              )
            : Container(
                key: ValueKey('back-${card.id}'),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder, width: 1.5),
                ),
                child: const Center(
                  child: Text('✦',
                      style: TextStyle(color: AppColors.starGold, fontSize: 32, fontWeight: FontWeight.bold)),
                ),
              ),
      ),
    );
  }
}
