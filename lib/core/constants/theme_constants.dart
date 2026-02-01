import 'package:flutter/material.dart';

// Line height mappings
const Map<String, double> lineHeightValues = {
  'compact': 1.8,
  'normal': 2.2,
  'loose': 2.8,
};

// Sepia theme colors (from web app index.html CSS)
class SepiaColors {
  // Backgrounds
  static const Color background = Color(0xFFFFFBEB);
  static const Color surface = Color(0xFFFEF9E7);
  static const Color surfaceVariant = Color(0xFFFDE68A);
  static const Color surfaceDim = Color(0xFFFDE2A8);

  // Text
  static const Color textPrimary = Color(0xFF5C2D0E);
  static const Color textSecondary = Color(0xFF6B3410);
  static const Color textTertiary = Color(0xFF7C4A12);
  static const Color textSubtle = Color(0xFF854D0E);
  static const Color textMuted = Color(0xFF92400E);
  static const Color textDisabled = Color(0xFFA16207);
  static const Color textHint = Color(0xFFB8862D);

  // Borders
  static const Color borderLight = Color(0xFFD4A24A);
  static const Color borderMedium = Color(0xFFC28A30);
  static const Color borderDark = Color(0xFFA67623);
  static const Color borderAccent = Color(0xFFB8862D);

  // Hover/Interactive
  static const Color hoverBackground = Color(0xFFFEF3C7);
  static const Color hoverBackgroundAlt = Color(0xFFFDE68A);

  // Shadows
  static const Color shadow = Color(0x3378350F); // rgba(120, 53, 15, 0.2)

  // Slider
  static const Color sliderTrack = Color(0xFFC28A30);
}

// App accent color (amber)
const Color appAccentColor = Color(0xFFD97706);
const Color appAccentColorLight = Color(0xFFF59E0B);

// Bookmark category colors
const Map<String, Color> bookmarkCategoryColors = {
  'general': Color(0xFFA3A3A3),
  'favorite': Color(0xFFF59E0B),
  'dua': Color(0xFF10B981),
  'stories': Color(0xFF3B82F6),
  'rulings': Color(0xFF8B5CF6),
  'memorize': Color(0xFFEF4444),
};
