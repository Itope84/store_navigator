// create an example theme, where headings use google font lexend, and body text uses google font manrope

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData createTheme() {
  return ThemeData(
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
      ),
      displayMedium: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      displaySmall: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
        ),
      ),
      headlineLarge: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 36,
          letterSpacing: -1.5,
        ),
      ),
      // generate the rest
      headlineMedium: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 24,
          letterSpacing: -0.5,
        ),
      ),
      headlineSmall: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 18,
        ),
      ),
      bodyLarge: GoogleFonts.manrope(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
      bodyMedium: GoogleFonts.manrope(
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      bodySmall: GoogleFonts.manrope(
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
      ),
      titleLarge: GoogleFonts.manrope(
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      titleMedium: GoogleFonts.manrope(
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      titleSmall: GoogleFonts.manrope(
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.25,
        ),
      ),
      labelLarge: GoogleFonts.manrope(
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
      labelMedium: GoogleFonts.manrope(
        textStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
      labelSmall: GoogleFonts.manrope(
        textStyle: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
      ),
    ),
  );
}
