import 'package:flutter/material.dart';

abstract final class BrandColors {
  static const sehsBlue = Color(0xFF1E487A);
  static const sehsGreen = Color(0xFF239E6C);
  static const kerussoLime = Color(0xFFA8D542);
  static const warmGold = Color(0xFFEBD35B);
  static const ink = Color(0xFF183030);
  static const softSurface = Color(0xFFF3FAF6);
  static const charcoal = Color(0xFF26332F);
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors =
        ColorScheme.fromSeed(
          seedColor: BrandColors.sehsBlue,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? const Color(0xFFAAC7F4) : BrandColors.sehsBlue,
          secondary: isDark ? const Color(0xFF70DBAA) : BrandColors.sehsGreen,
          tertiary: isDark ? const Color(0xFFC4E878) : BrandColors.kerussoLime,
          surface: isDark ? const Color(0xFF111A18) : BrandColors.softSurface,
          onSurface: isDark ? const Color(0xFFE2ECE7) : BrandColors.ink,
        );
    final outline = isDark ? const Color(0xFF83928B) : const Color(0xFF6C7B73);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF192421) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outline.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF192421) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: outline.withValues(alpha: 0.18)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
