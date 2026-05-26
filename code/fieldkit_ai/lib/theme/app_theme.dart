import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colori Brand e Struttura
  static const Color primary = Color(0xFFC62828); // Rosso FieldKit
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  
  // Colori Testo
  static const Color textDark = Color(0xFF2D3748);
  static const Color textLight = Color(0xFF718096);
  static const Color textWhite = Colors.white;

  // Colori di Stato (Feedback)
  static const Color success = Color(0xFF38A169); // Verde
  static const Color warning = Color(0xFFDD6B20); // Arancione
  static const Color warningBg = Color(0xFFFEEBC8); // Sfondo Arancione chiaro
  static const Color error = Color(0xFFE53E3E);   // Rosso errore
  
  // Colori Specifici UI
  static const Color cameraBackground = Colors.black;
  static const Color overlayDark = Color(0x8A000000); // Nero trasparente
  static const Color divider = Color(0xFFE2E8F0);
  static const Color mediaButtonBg = Color(0xFFEDF2F7);

  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(primary: primary, secondary: primary),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textDark),
        bodyMedium: GoogleFonts.inter(color: textLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}