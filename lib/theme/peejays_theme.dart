import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PeejaysTheme {
  // Light Colors
  static const Color lightPrimary = Color(0xFF4A3B33);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFF8B7E74);
  static const Color lightAccent = Color(0xFFC25E5E);
  static const Color lightBackground = Color(0xFFF4EFE6);
  static const Color lightSecondaryBackground = Color(0xFFEBE3D5);
  static const Color lightSurface = Color(0xFFFCF9F2);
  static const Color lightOnBackground = Color(0xFF2C2420);
  static const Color lightOutline = Color(0xFF8B7E74);
  static const Color lightDivider = Color(0xFFD9D0C1);
  static const Color lightSecondaryText = Color(0xFF5E544E);

  // Dark Colors
  static const Color darkPrimary = Color(0xFFD9D0C1);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkSecondary = Color(0xFFA69B92);
  static const Color darkAccent = Color(0xFFE58E8E);
  static const Color darkBackground = Color(0xFF1A1614);
  static const Color darkSecondaryBackground = Color(0xFF26211E);
  static const Color darkSurface = Color(0xFF2C2622);
  static const Color darkOnBackground = Color(0xFFF4EFE6);
  static const Color darkOutline = Color(0xFF5E544E);
  static const Color darkDivider = Color(0xFF3D352F);
  static const Color darkSecondaryText = Color(0xFFC7BDB3);

  // Retro Border Builder
  static Border retroBorder(Color color, {double width = 2}) {
    return Border.all(color: color, width: width);
  }

  // Retro Card Decoration
  static BoxDecoration retroCardDecoration({
    required Color bgColor,
    required Color outlineColor,
    double shadowOffset = 4,
  }) {
    return BoxDecoration(
      color: bgColor,
      border: retroBorder(outlineColor),
      boxShadow: [
        BoxShadow(
          color: outlineColor,
          offset: Offset(shadowOffset, shadowOffset),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        secondary: lightSecondary,
        background: lightBackground,
        surface: lightSurface,
        onBackground: lightOnBackground,
        onSurface: lightOnBackground,
        outline: lightOutline,
        error: const Color(0xFFA34343),
      ),
      scaffoldBackgroundColor: lightBackground,
      dividerTheme: const DividerThemeData(color: lightDivider, thickness: 2),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSecondaryBackground,
        foregroundColor: lightPrimary,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: lightOutline, width: 2)),
        centerTitle: true,
        titleTextStyle: GoogleFonts.specialElite(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.specialElite(color: lightOnBackground, fontSize: 48, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.specialElite(color: lightOnBackground, fontSize: 36, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.specialElite(color: lightOnBackground, fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.specialElite(color: lightOnBackground, fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.courierPrime(color: lightOnBackground, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.courierPrime(color: lightOnBackground, fontSize: 18, fontWeight: FontWeight.bold),
        titleSmall: GoogleFonts.courierPrime(color: lightOnBackground, fontSize: 16, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.courierPrime(color: lightOnBackground, fontSize: 16, height: 1.6),
        bodyMedium: GoogleFonts.courierPrime(color: lightOnBackground, fontSize: 14, height: 1.5),
        bodySmall: GoogleFonts.courierPrime(color: lightOnBackground, fontSize: 12, height: 1.4),
        labelLarge: GoogleFonts.spaceMono(color: lightOnBackground, fontSize: 14, fontWeight: FontWeight.bold),
        labelMedium: GoogleFonts.spaceMono(color: lightOnBackground, fontSize: 12, fontWeight: FontWeight.bold),
        labelSmall: GoogleFonts.spaceMono(color: lightOnBackground, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        secondary: darkSecondary,
        background: darkBackground,
        surface: darkSurface,
        onBackground: darkOnBackground,
        onSurface: darkOnBackground,
        outline: darkOutline,
        error: const Color(0xFFE57373),
      ),
      scaffoldBackgroundColor: darkBackground,
      dividerTheme: const DividerThemeData(color: darkDivider, thickness: 2),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSecondaryBackground,
        foregroundColor: darkPrimary,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: darkOutline, width: 2)),
        centerTitle: true,
        titleTextStyle: GoogleFonts.specialElite(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.specialElite(color: darkOnBackground, fontSize: 48, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.specialElite(color: darkOnBackground, fontSize: 36, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.specialElite(color: darkOnBackground, fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.specialElite(color: darkOnBackground, fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.courierPrime(color: darkOnBackground, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.courierPrime(color: darkOnBackground, fontSize: 18, fontWeight: FontWeight.bold),
        titleSmall: GoogleFonts.courierPrime(color: darkOnBackground, fontSize: 16, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.courierPrime(color: darkOnBackground, fontSize: 16, height: 1.6),
        bodyMedium: GoogleFonts.courierPrime(color: darkOnBackground, fontSize: 14, height: 1.5),
        bodySmall: GoogleFonts.courierPrime(color: darkOnBackground, fontSize: 12, height: 1.4),
        labelLarge: GoogleFonts.spaceMono(color: darkOnBackground, fontSize: 14, fontWeight: FontWeight.bold),
        labelMedium: GoogleFonts.spaceMono(color: darkOnBackground, fontSize: 12, fontWeight: FontWeight.bold),
        labelSmall: GoogleFonts.spaceMono(color: darkOnBackground, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
