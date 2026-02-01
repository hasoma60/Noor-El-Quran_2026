import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Cairo',
      colorSchemeSeed: appAccentColor,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE4E4E7)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: appAccentColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: appAccentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Cairo',
      colorSchemeSeed: appAccentColor,
      scaffoldBackgroundColor: const Color(0xFF18181B),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF3F3F46)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: appAccentColorLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF27272A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F3F46)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F3F46)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: appAccentColorLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static ThemeData sepia() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD97706),
        brightness: Brightness.light,
        surface: SepiaColors.background,
        onSurface: SepiaColors.textPrimary,
        primary: const Color(0xFFD97706),
        onPrimary: Colors.white,
        secondary: SepiaColors.borderMedium,
        onSecondary: Colors.white,
        surfaceContainerHighest: SepiaColors.surfaceVariant,
      ),
      scaffoldBackgroundColor: SepiaColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: SepiaColors.surface,
        foregroundColor: SepiaColors.textPrimary,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: SepiaColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SepiaColors.borderLight),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: SepiaColors.surface,
        selectedItemColor: Color(0xFFD97706),
        unselectedItemColor: SepiaColors.textMuted,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SepiaColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SepiaColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SepiaColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD97706), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerColor: SepiaColors.borderLight,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: SepiaColors.textPrimary),
        bodyMedium: TextStyle(color: SepiaColors.textSecondary),
        bodySmall: TextStyle(color: SepiaColors.textTertiary),
        titleLarge: TextStyle(color: SepiaColors.textPrimary),
        titleMedium: TextStyle(color: SepiaColors.textPrimary),
        titleSmall: TextStyle(color: SepiaColors.textSecondary),
        labelLarge: TextStyle(color: SepiaColors.textSubtle),
        labelMedium: TextStyle(color: SepiaColors.textMuted),
        labelSmall: TextStyle(color: SepiaColors.textDisabled),
      ),
    );
  }

  static ThemeData amoled() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme.fromSeed(
        seedColor: appAccentColor,
        brightness: Brightness.dark,
        surface: AmoledColors.background,
        onSurface: AmoledColors.textPrimary,
        primary: appAccentColorAmoled,
        onPrimary: Colors.black,
        secondary: appAccentColorLight,
        onSecondary: Colors.black,
        surfaceContainerHighest: AmoledColors.surfaceContainerHigh,
      ),
      scaffoldBackgroundColor: AmoledColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AmoledColors.background,
        foregroundColor: AmoledColors.textPrimary,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AmoledColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AmoledColors.borderLight),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AmoledColors.background,
        selectedItemColor: appAccentColorAmoled,
        unselectedItemColor: AmoledColors.textTertiary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AmoledColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AmoledColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AmoledColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: appAccentColorAmoled, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerColor: AmoledColors.borderLight,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AmoledColors.textPrimary),
        bodyMedium: TextStyle(color: AmoledColors.textSecondary),
        bodySmall: TextStyle(color: AmoledColors.textTertiary),
        titleLarge: TextStyle(color: AmoledColors.textPrimary),
        titleMedium: TextStyle(color: AmoledColors.textPrimary),
        titleSmall: TextStyle(color: AmoledColors.textSecondary),
        labelLarge: TextStyle(color: AmoledColors.textSecondary),
        labelMedium: TextStyle(color: AmoledColors.textTertiary),
        labelSmall: TextStyle(color: AmoledColors.textTertiary),
      ),
    );
  }

  static ThemeData getTheme(String themeMode) {
    switch (themeMode) {
      case 'dark':
        return dark();
      case 'amoled':
        return amoled();
      case 'sepia':
        return sepia();
      case 'light':
      default:
        return light();
    }
  }
}
