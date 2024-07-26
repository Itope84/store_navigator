// create an example theme, where headings use google font lexend, and body text uses google font manrope

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

MaterialColor getMaterialColor(Color color) {
  final int red = color.red;
  final int green = color.green;
  final int blue = color.blue;

  final Map<int, Color> shades = {
    50: Color.fromRGBO(red, green, blue, .1),
    100: Color.fromRGBO(red, green, blue, .2),
    200: Color.fromRGBO(red, green, blue, .3),
    300: Color.fromRGBO(red, green, blue, .4),
    400: Color.fromRGBO(red, green, blue, .5),
    500: Color.fromRGBO(red, green, blue, .6),
    600: Color.fromRGBO(red, green, blue, .7),
    700: Color.fromRGBO(red, green, blue, .8),
    800: Color.fromRGBO(red, green, blue, .9),
    900: Color.fromRGBO(red, green, blue, 1),
  };

  return MaterialColor(color.value, shades);
}

ThemeData createTheme() {
  Color purple = const Color(0xFF6D31ED);

  final buttonTextStyle = WidgetStateProperty.all<TextStyle>(
    GoogleFonts.manrope(
      textStyle: const TextStyle(
        fontSize: 16,
      ),
    ),
  );

  return ThemeData(
    colorScheme:
        ColorScheme.fromSeed(seedColor: purple, brightness: Brightness.light),
    primaryColor: purple,
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        textStyle: buttonTextStyle,
        backgroundColor: WidgetStateProperty.all<Color>(purple),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        textStyle: buttonTextStyle,
        foregroundColor: WidgetStateProperty.all<Color>(purple),
        side: WidgetStateProperty.all<BorderSide>(
          BorderSide(
            color: purple,
          ),
        ),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.w700,
          color: Color(0xFF171A1F),
        ),
      ),
      displayMedium: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w700,
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
          fontSize: 32,

          // TODO:
          color: Color(0xFF171A1F),
        ),
      ),
      // generate the rest
      headlineMedium: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 24,
        ),
      ),
      headlineSmall: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 20,
        ),
      ),
      bodyLarge: GoogleFonts.manrope(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
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
        ),
      ),
      titleLarge: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      titleMedium: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      titleSmall: GoogleFonts.lexend(
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      labelLarge: GoogleFonts.manrope(
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
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
        ),
      ),
    ),
  );
}
