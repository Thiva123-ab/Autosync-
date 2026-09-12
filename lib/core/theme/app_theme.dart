import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0072FF), // Vibrant Blue
        secondary: Color(0xFF00C6FF),
        surface: Color(0xFFF5F7FA), // Light grey surface
        onSurface: Color(0xFF1E1E2C), // Dark text on light surface
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Pure white
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E1E2C)),
        titleTextStyle: GoogleFonts.outfit(color: const Color(0xFF1E1E2C), fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00C6FF), // Electric Blue
        secondary: Color(0xFF0072FF),
        surface: Color(0xFF1E1E2C), // Deep Slate Surface
        onSurface: Color(0xFFF5F7FA), // Light text on dark surface
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF5F7FA)),
        titleTextStyle: GoogleFonts.outfit(color: const Color(0xFFF5F7FA), fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
