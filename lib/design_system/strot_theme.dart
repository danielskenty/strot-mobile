import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'strot_tokens.dart';

abstract final class StrotTypography {
  static TextTheme get textTheme => GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 56,
      fontWeight: FontWeight.w600,
      color: StrotColors.forest,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 44,
      fontWeight: FontWeight.w600,
      color: StrotColors.forest,
    ),
    headlineLarge: GoogleFonts.playfairDisplay(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      color: StrotColors.forest,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: StrotColors.forest,
    ),
    titleLarge: GoogleFonts.playfairDisplay(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: StrotColors.forest,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      height: 1.6,
      color: StrotColors.charcoal,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      height: 1.5,
      color: StrotColors.charcoal,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: StrotColors.charcoal,
    ),
  );
}

abstract final class StrotTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: StrotColors.forest,
      onPrimary: StrotColors.cream,
      secondary: StrotColors.gold,
      onSecondary: StrotColors.forest,
      surface: StrotColors.cream,
      onSurface: StrotColors.charcoal,
      error: StrotColors.gold,
      onError: StrotColors.forest,
      outline: StrotColors.forestMuted,
    ),
    scaffoldBackgroundColor: StrotColors.cream,
    textTheme: StrotTypography.textTheme,
    dividerColor: StrotColors.forestMuted,
    shadowColor: StrotColors.forestMuted,
    appBarTheme: const AppBarTheme(
      backgroundColor: StrotColors.forest,
      foregroundColor: StrotColors.cream,
      elevation: StrotElevation.none,
    ),
    cardTheme: const CardThemeData(
      color: StrotColors.cream,
      elevation: StrotElevation.none,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: StrotColors.forestMuted),
        borderRadius: BorderRadius.all(Radius.circular(StrotRadius.md)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: StrotColors.cream,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: StrotColors.forestMuted),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: StrotColors.gold),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: StrotColors.forest,
        foregroundColor: StrotColors.cream,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: StrotSpacing.lg,
          vertical: StrotSpacing.md,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: StrotColors.forest,
        side: const BorderSide(color: StrotColors.gold),
        padding: const EdgeInsets.symmetric(
          horizontal: StrotSpacing.lg,
          vertical: StrotSpacing.md,
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: StrotColors.gold,
      linearTrackColor: StrotColors.forestMuted,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: StrotColors.cream,
      surfaceTintColor: StrotColors.cream,
    ),
  );
}
