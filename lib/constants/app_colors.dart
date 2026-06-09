import 'package:flutter/material.dart';

class AppColors {
  // ── Brand accents ────────────────────────────────────────────
  static const Color idolPink  = Color(0xFFFF6B9D);
  static const Color starGold  = Color(0xFFFFD700);
  static const Color lavender  = Color(0xFFC77DFF);
  static const Color roseRed   = Color(0xFFFF1744);
  static const Color softMint  = Color(0xFF80DEEA);

  // ── Background gradient ──────────────────────────────────────
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A0533),  // very deep purple
      Color(0xFF3D1C6E),  // deep purple
      Color(0xFF6B2FA0),  // medium purple
      Color(0xFFAD1457),  // dark pink
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  // ── Glassmorphism ────────────────────────────────────────────
  static const Color glassFill   = Color(0x1EFFFFFF); // 12% white
  static const Color glassBorder = Color(0x40FFFFFF); // 25% white

  // ── Text on dark background ──────────────────────────────────
  static const Color textOnDark      = Colors.white;
  static const Color textOnDarkMuted = Color(0xB3FFFFFF); // 70%
  static const Color textOnDarkFaint = Color(0x66FFFFFF); // 40%

  // ── Progress bar gradients ───────────────────────────────────
  static const LinearGradient heartBarGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF1744)],
  );
  static const Color barBackground = Color(0x33FFFFFF); // 20% white

  // ── Cat glow ─────────────────────────────────────────────────
  static const Color catGlowCore  = Color(0xCCFF9800); // orange core
  static const Color catGlowOuter = Color(0x80FF6B9D); // pink outer

  // ── Legacy aliases ───────────────────────────────────────────
  // (kept so widgets not yet updated continue to compile)
  static const Color primary         = idolPink;
  static const Color primaryLight    = Color(0x1AFF6B9D);
  static const Color primaryBorder   = Color(0x4DFF6B9D);
  static const Color secondary       = Color(0xFFFFB347);
  static const Color background      = Color(0xFF1A0533);
  static const Color heartRed        = Color(0xFFFF4444);
  static const Color heartRedLight   = Color(0x33FF4444);
  static const Color heartRedClaimed = Color(0xB3FF4444);
  static const Color fanGold         = starGold;
  static const Color levelPurple     = Color(0xFF9B59B6);
  static const Color textDark        = Color(0xFF2C2C2C);
  static const Color textLight       = Color(0xFF888888);
}
