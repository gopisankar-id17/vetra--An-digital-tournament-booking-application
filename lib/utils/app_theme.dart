import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF6f42c1);
  static const Color primaryLightColor = Color(0xFF9f7aca);
  static const Color primaryDarkColor = Color(0xFF563691);

  // Secondary colors
  static const Color secondaryColor = Color(0xFF94c142);
  static const Color secondaryLightColor = Color(0xFFb1d46b);
  static const Color secondaryDarkColor = Color(0xFF76a328);

  // Neutral colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFDC3545);
  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF17A2B8);

  // Text colors
  static const Color textDarkColor = Color(0xFF2C3E50);
  static const Color textMediumColor = Color(0xFF7F8C8D);
  static const Color textLightColor = Color(0xFFBDC3C7);

  // Get the theme data
  static ThemeData getTheme() {
    return ThemeData(
      // Primary and accent colors
      primaryColor: primaryColor,
      primaryColorLight: primaryLightColor,
      primaryColorDark: primaryDarkColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),

      // Scaffold and app bar theme
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 70,
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 5,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        labelStyle: const TextStyle(color: textMediumColor),
        hintStyle: TextStyle(color: textMediumColor.withOpacity(0.7)),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: textDarkColor,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: textDarkColor,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: textDarkColor,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: textDarkColor,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textDarkColor),
        bodyMedium: TextStyle(fontSize: 14, color: textDarkColor),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: textDarkColor,
        ),
      ),

      // Other theme properties
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Color(0xFFEAECEF),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textDarkColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      // Font family
      fontFamily: 'Roboto',
    );
  }
}
