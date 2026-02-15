import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/night_mode_schedule.dart';

class SettingsLocalDataSource {
  final SharedPreferences _prefs;

  SettingsLocalDataSource(this._prefs);

  // Font size
  int getFontSize() => _prefs.getInt('fontSize') ?? defaultFontSize;
  Future<void> setFontSize(int size) => _prefs.setInt('fontSize', size);

  // Quran font
  String getQuranFont() => _prefs.getString('quranFont') ?? 'Hafs Smart';
  Future<void> setQuranFont(String font) => _prefs.setString('quranFont', font);

  // Script mode
  String getScriptMode() => _prefs.getString('scriptMode') ?? 'madinah';
  Future<void> setScriptMode(String mode) =>
      _prefs.setString('scriptMode', mode);

  // Ayah number style
  String getAyahNumberStyle() =>
      _prefs.getString('ayahNumberStyle') ?? 'native';
  Future<void> setAyahNumberStyle(String style) =>
      _prefs.setString('ayahNumberStyle', style);

  // Line height
  String getLineHeight() => _prefs.getString('lineHeight') ?? 'normal';
  Future<void> setLineHeight(String height) =>
      _prefs.setString('lineHeight', height);

  // Show translation
  bool getShowTranslation() => _prefs.getBool('showTranslation') ?? true;
  Future<void> setShowTranslation(bool show) =>
      _prefs.setBool('showTranslation', show);

  // Active translation IDs
  List<int> getActiveTranslationIds() {
    final json = _prefs.getString('activeTranslationIds');
    if (json == null) return [16];
    try {
      return (jsonDecode(json) as List<dynamic>).cast<int>();
    } catch (_) {
      return [16];
    }
  }

  Future<void> setActiveTranslationIds(List<int> ids) =>
      _prefs.setString('activeTranslationIds', jsonEncode(ids));

  // Reading view mode
  String getReadingViewMode() =>
      _prefs.getString('readingViewMode') ?? 'flowing';
  Future<void> setReadingViewMode(String mode) =>
      _prefs.setString('readingViewMode', mode);

  // Resume behavior
  bool getAutoResumeLastAyah() => _prefs.getBool('autoResumeLastAyah') ?? true;
  Future<void> setAutoResumeLastAyah(bool enabled) =>
      _prefs.setBool('autoResumeLastAyah', enabled);

  // Default tafsir source
  int getDefaultTafsirId() => _prefs.getInt('defaultTafsirId') ?? 16;
  Future<void> setDefaultTafsirId(int id) =>
      _prefs.setInt('defaultTafsirId', id);

  // Theme
  String getTheme() => _prefs.getString('theme') ?? 'system';
  Future<void> setTheme(String theme) => _prefs.setString('theme', theme);

  // Night mode schedule
  NightModeSchedule getNightModeSchedule() {
    final json = _prefs.getString('nightModeSchedule');
    if (json == null) return const NightModeSchedule();
    try {
      return NightModeSchedule.fromJson(
          jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return const NightModeSchedule();
    }
  }

  Future<void> setNightModeSchedule(NightModeSchedule schedule) =>
      _prefs.setString('nightModeSchedule', jsonEncode(schedule.toJson()));

  // Reciter
  int getSelectedReciterId() => _prefs.getInt('selectedReciterId') ?? 7;
  Future<void> setSelectedReciterId(int id) =>
      _prefs.setInt('selectedReciterId', id);

  // Reduced motion
  bool getReducedMotion() => _prefs.getBool('reducedMotion') ?? false;
  Future<void> setReducedMotion(bool val) =>
      _prefs.setBool('reducedMotion', val);

  // Word by word
  bool getShowWordByWord() => _prefs.getBool('showWordByWord') ?? false;
  Future<void> setShowWordByWord(bool val) =>
      _prefs.setBool('showWordByWord', val);

  // Tajweed colors
  bool getShowTajweed() => _prefs.getBool('showTajweed') ?? false;
  Future<void> setShowTajweed(bool val) => _prefs.setBool('showTajweed', val);
}
