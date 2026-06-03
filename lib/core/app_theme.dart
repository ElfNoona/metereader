import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryYellow = Color(
    0xFFFFCA28,
  ); // Vibrant yellow from the UI
  static const Color darkCharcoal = Color(
    0xFF2C2C2C,
  ); // Dark gray/black for secondary buttons

  // Background & Surface Colors
  static const Color backgroundWhite = Color(
    0xFFF9F9F9,
  ); // Slightly off-white background
  static const Color surfaceWhite = Color(
    0xFFFFFFFF,
  ); // Pure white for cards/inputs

  // Text Colors
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFF9E9E9E);

  // Input Colors
  static const Color inputBorder = Color(0xFFE0E0E0);

  // Status Colors
  static const Color errorRed = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryYellow,
      scaffoldBackgroundColor: backgroundWhite,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.light(
        primary: primaryYellow,
        secondary: darkCharcoal,
        surface: surfaceWhite,
        error: errorRed,
        onPrimary: textDark,
        onSecondary: textLight,
        onSurface: textDark,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Elevated Button Theme (Default: Yellow)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: textDark,
          elevation: 2,
          shadowColor: primaryYellow.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Pill-shaped buttons
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Field / Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 24,
        ),
        hintStyle: const TextStyle(
          color: textHint,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        // Default border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: inputBorder),
        ),
        // Enabled border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: inputBorder),
        ),
        // Focused border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        // Error border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: errorRed),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: primaryYellow,
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textDark,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: TextStyle(
          color: textDark,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: textDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: textDark,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Pre-defined alternate button style
  static ButtonStyle get darkButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: darkCharcoal,
      foregroundColor: textLight,
      elevation: 2,
      shadowColor: darkCharcoal.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}
