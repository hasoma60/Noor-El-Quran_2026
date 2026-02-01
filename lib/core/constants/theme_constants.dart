import 'package:flutter/material.dart';

// Line height mappings
const Map<String, double> lineHeightValues = {
  'compact': 1.8,
  'normal': 2.2,
  'loose': 2.8,
};

// Typography constants for Arabic Quran text
class QuranTypography {
  // Font size ranges
  static const double fontSizeMin = 18.0;
  static const double fontSizeMax = 48.0;
  static const double fontSizeDefault = 28.0;

  // Arabic Quran text needs larger line heights for diacritics
  static const double quranLineHeight = 2.0;
  static const double translationLineHeight = 1.6;
  static const double mixedLineHeight = 1.8;

  // Available Quran fonts (ordered by recommendation)
  static const List<String> quranFonts = [
    'Amiri',
    'Scheherazade New',
    'Noto Naskh Arabic',
  ];

  // UI font
  static const String uiFont = 'Cairo';
}

// Tajweed color coding (Darussalam 7-color standard)
class TajweedColors {
  static const Color ghunnah = Color(0xFFE53E3E);      // Red - Ghunnah / Madd
  static const Color idgham = Color(0xFF38A169);         // Green - Idgham
  static const Color qalqalah = Color(0xFF3182CE);      // Blue - Qalqalah
  static const Color ikhfa = Color(0xFFED8936);          // Orange - Ikhfa
  static const Color ikhfaMeemSaakin = Color(0xFF63B3ED); // Light Blue - Ikhfa Meem
  static const Color idghamMeemSaakin = Color(0xFF68D391); // Light Green - Idgham Meem
  static const Color silent = Color(0xFFA0AEC0);         // Gray - Silent letters

  static const Map<String, Color> colorMap = {
    'ghunnah': ghunnah,
    'idgham': idgham,
    'qalqalah': qalqalah,
    'ikhfa': ikhfa,
    'ikhfa_meem': ikhfaMeemSaakin,
    'idgham_meem': idghamMeemSaakin,
    'silent': silent,
  };

  static const Map<String, String> arabicLabels = {
    'ghunnah': 'غنة / مد',
    'idgham': 'إدغام',
    'qalqalah': 'قلقلة',
    'ikhfa': 'إخفاء',
    'ikhfa_meem': 'إخفاء ميم ساكنة',
    'idgham_meem': 'إدغام ميم ساكنة',
    'silent': 'حروف لا تُنطق',
  };
}

// Sepia theme colors
class SepiaColors {
  static const Color background = Color(0xFFFFFBEB);
  static const Color surface = Color(0xFFFEF9E7);
  static const Color surfaceVariant = Color(0xFFFDE68A);
  static const Color surfaceDim = Color(0xFFFDE2A8);

  static const Color textPrimary = Color(0xFF5C2D0E);
  static const Color textSecondary = Color(0xFF6B3410);
  static const Color textTertiary = Color(0xFF7C4A12);
  static const Color textSubtle = Color(0xFF854D0E);
  static const Color textMuted = Color(0xFF92400E);
  static const Color textDisabled = Color(0xFFA16207);
  static const Color textHint = Color(0xFFB8862D);

  static const Color borderLight = Color(0xFFD4A24A);
  static const Color borderMedium = Color(0xFFC28A30);
  static const Color borderDark = Color(0xFFA67623);
  static const Color borderAccent = Color(0xFFB8862D);

  static const Color hoverBackground = Color(0xFFFEF3C7);
  static const Color hoverBackgroundAlt = Color(0xFFFDE68A);

  static const Color shadow = Color(0x3378350F);
  static const Color sliderTrack = Color(0xFFC28A30);
}

// AMOLED theme colors - pure black for OLED power saving
class AmoledColors {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceContainer = Color(0xFF121212);
  static const Color surfaceContainerHigh = Color(0xFF1A1A1A);

  // Use #E0E0E0 not pure white to avoid halation
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);

  static const Color borderLight = Color(0xFF1F1F1F);
  static const Color borderMedium = Color(0xFF2A2A2A);
}

// App accent color (amber)
const Color appAccentColor = Color(0xFFD97706);
const Color appAccentColorLight = Color(0xFFF59E0B);
const Color appAccentColorAmoled = Color(0xFFFFB74D);

// Bookmark category colors
const Map<String, Color> bookmarkCategoryColors = {
  'general': Color(0xFFA3A3A3),
  'favorite': Color(0xFFF59E0B),
  'dua': Color(0xFF10B981),
  'stories': Color(0xFF3B82F6),
  'rulings': Color(0xFF8B5CF6),
  'memorize': Color(0xFFEF4444),
};
