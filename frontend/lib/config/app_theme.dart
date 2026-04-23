import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background     = Color(0xFF1A1A2E);
  static const Color surface        = Color(0xFF16213E);
  static const Color surfaceVariant = Color(0xFF0F3460);
  static const Color primary        = Color(0xFFC8A45A); // Dorado D&D Beyond
  static const Color primaryDark    = Color(0xFF9E7B3A);
  static const Color accent         = Color(0xFFC53030); // Rojo carmesí
  static const Color textPrimary    = Color(0xFFE8E0D0); // Pergamino
  static const Color textSecondary  = Color(0xFF9E9282);
  static const Color divider        = Color(0xFF2A2A4A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onPrimary: Color(0xFF1A1A2E),
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge:  GoogleFonts.cinzel(color: primary,    fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.cinzel(color: primary,    fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge:    GoogleFonts.cinzel(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge:     GoogleFonts.lato(color: textPrimary,  fontSize: 16),
        bodyMedium:    GoogleFonts.lato(color: textPrimary,  fontSize: 14),
        bodySmall:     GoogleFonts.lato(color: textSecondary, fontSize: 12),
        labelLarge:    GoogleFonts.lato(color: primary, fontSize: 14,
                         fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          color: primary, fontSize: 20, fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: primary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: surfaceVariant, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.lato(color: textSecondary),
        hintStyle: GoogleFonts.lato(color: textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: surfaceVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          minimumSize: const Size(double.infinity, 48),
          textStyle: GoogleFonts.cinzel(
            fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
      ),
    );
  }
}