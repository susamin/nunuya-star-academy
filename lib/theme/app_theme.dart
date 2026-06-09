import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // Text theme: Nunito on white (used on dark bg)
    final base = GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.idolPink,
        brightness: Brightness.dark,
        primary: AppColors.idolPink,
        secondary: AppColors.lavender,
        surface: const Color(0xFF2D0A52),
      ),
      // Each Scaffold sets its own bg — we default to deep purple
      scaffoldBackgroundColor: const Color(0xFF1A0533),
      textTheme: base.copyWith(
        displayLarge: base.displayLarge?.copyWith(color: Colors.white),
        bodyMedium: base.bodyMedium?.copyWith(color: Colors.white),
        bodySmall: base.bodySmall?.copyWith(color: AppColors.textOnDarkMuted),
        labelSmall: base.labelSmall?.copyWith(color: AppColors.textOnDarkMuted),
        labelMedium: base.labelMedium?.copyWith(color: AppColors.textOnDarkMuted),
        titleSmall: base.titleSmall?.copyWith(color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Cards are styled via GlassCard; theme card is a fallback
      cardTheme: CardThemeData(
        color: AppColors.glassFill,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.idolPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.idolPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF2D0A52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF3D1C6E),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      dividerColor: AppColors.glassBorder,
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.lavender,
        textColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: AppColors.barBackground,
      ),
    );
  }
}
