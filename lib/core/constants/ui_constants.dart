import 'package:flutter/material.dart';

/// UI constants extracted from hardcoded values across the codebase.
abstract class UiConstants {
  /// Bottom sheet corner radius
  static const double bottomSheetRadius = 28.0;

  /// Accent color used throughout the app (amber/gold)
  static const Color accentColor = Color(0xFFD97706);

  /// Arabic font sizes
  static const double mushafChapterNameSize = 28.0;
  static const double readerChapterNameSize = 42.0;
  static const double bismillahSize = 28.0;
  static const double defaultVerseNumberRatio = 0.7;

  /// Line heights for Arabic text
  static const double lineHeightCompact = 1.8;
  static const double lineHeightNormal = 2.2;
  static const double lineHeightLoose = 2.8;
  static const double mushafLineHeight = 2.0;

  /// Common border radius values
  static const double cardRadius = 12.0;
  static const double chipRadius = 8.0;
  static const double indicatorRadius = 20.0;

  /// Resolves line height setting string to actual value.
  static double resolveLineHeight(String setting) {
    switch (setting) {
      case 'compact':
        return lineHeightCompact;
      case 'loose':
        return lineHeightLoose;
      default:
        return lineHeightNormal;
    }
  }
}
