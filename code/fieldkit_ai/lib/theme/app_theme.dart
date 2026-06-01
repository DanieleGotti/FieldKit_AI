import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static double titleSize(BuildContext context) => MediaQuery.of(context).size.width >= 800 ? 16 : 16;
  static double bodySize(BuildContext context) => MediaQuery.of(context).size.width >= 800 ? 11 : 11;
  static double smallSize(BuildContext context) => MediaQuery.of(context).size.width >= 800 ? 10 : 10;

  static const Color primary = Color(0xFFC62828); 
  static const Color primaryDark = Color(0xFF8E0000); 
  static const Color background = Color(0xFFF4F7FE); 
  static const Color surface = Colors.white;
  static const Color sidebarBg = Color(0xFF1E1E2D); 
  
  static const Color textDark = Color(0xFF2B3674);
  static const Color textLight = Color(0xFFA3AED0);
  static const Color textWhite = Colors.white;
  
  static const Color success = Color(0xFF05CD99);
  static const Color warning = Color(0xFFF57C00); 
  static const Color warningBg = Color(0xFFFFF3E0); 
  static const Color error = Color(0xFFEE5D50);

  static const Color cameraBackground = Colors.black;
  static const Color divider = Color(0xFFE2E8F0);
  static const Color mediaButtonBg = Color(0xFFEDF2F7);

  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(primary: primary, secondary: primary),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(color: textDark, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.nunito(color: textDark, fontWeight: FontWeight.w800),
        bodyLarge: GoogleFonts.nunito(color: textDark, fontWeight: FontWeight.w600),
        bodyMedium: GoogleFonts.nunito(color: textLight, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0, 
        surfaceTintColor: Colors.white, 
        centerTitle: false,
        iconTheme: IconThemeData(color: primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primary, width: 2)),
        labelStyle: const TextStyle(color: textLight, fontSize: 14), 
      ),
    );
  }
}