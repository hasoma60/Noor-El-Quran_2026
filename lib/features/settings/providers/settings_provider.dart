import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local/settings_local_datasource.dart';
import '../../../domain/entities/night_mode_schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'SharedPreferences not initialized. '
    'Ensure SharedPreferences.getInstance() is awaited in main() '
    'and passed as an override to ProviderScope.',
  );
});

final settingsLocalDataSourceProvider =
    Provider<SettingsLocalDataSource>((ref) {
  return SettingsLocalDataSource(ref.watch(sharedPreferencesProvider));
});

class SettingsState {
  final int fontSize;
  final String quranFont;
  final String scriptMode;
  final String ayahNumberStyle;
  final String lineHeight;
  final bool showTranslation;
  final List<int> activeTranslationIds;
  final String readingViewMode;
  final bool autoResumeLastAyah;
  final int defaultTafsirId;
  final String theme;
  final NightModeSchedule nightModeSchedule;
  final int selectedReciterId;
  final bool reducedMotion;
  final bool showWordByWord;
  final bool showTajweed;

  const SettingsState({
    this.fontSize = 28,
    this.quranFont = 'Hafs Smart',
    this.scriptMode = 'madinah',
    this.ayahNumberStyle = 'native',
    this.lineHeight = 'normal',
    this.showTranslation = true,
    this.activeTranslationIds = const [16],
    this.readingViewMode = 'flowing',
    this.autoResumeLastAyah = true,
    this.defaultTafsirId = 16,
    this.theme = 'system',
    this.nightModeSchedule = const NightModeSchedule(),
    this.selectedReciterId = 7,
    this.reducedMotion = false,
    this.showWordByWord = false,
    this.showTajweed = false,
  });

  SettingsState copyWith({
    int? fontSize,
    String? quranFont,
    String? scriptMode,
    String? ayahNumberStyle,
    String? lineHeight,
    bool? showTranslation,
    List<int>? activeTranslationIds,
    String? readingViewMode,
    bool? autoResumeLastAyah,
    int? defaultTafsirId,
    String? theme,
    NightModeSchedule? nightModeSchedule,
    int? selectedReciterId,
    bool? reducedMotion,
    bool? showWordByWord,
    bool? showTajweed,
  }) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      quranFont: quranFont ?? this.quranFont,
      scriptMode: scriptMode ?? this.scriptMode,
      ayahNumberStyle: ayahNumberStyle ?? this.ayahNumberStyle,
      lineHeight: lineHeight ?? this.lineHeight,
      showTranslation: showTranslation ?? this.showTranslation,
      activeTranslationIds: activeTranslationIds ?? this.activeTranslationIds,
      readingViewMode: readingViewMode ?? this.readingViewMode,
      autoResumeLastAyah: autoResumeLastAyah ?? this.autoResumeLastAyah,
      defaultTafsirId: defaultTafsirId ?? this.defaultTafsirId,
      theme: theme ?? this.theme,
      nightModeSchedule: nightModeSchedule ?? this.nightModeSchedule,
      selectedReciterId: selectedReciterId ?? this.selectedReciterId,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      showWordByWord: showWordByWord ?? this.showWordByWord,
      showTajweed: showTajweed ?? this.showTajweed,
    );
  }

  /// Resolve the effective theme mode considering night mode schedule and system preference
  ThemeMode get effectiveThemeMode {
    if (theme == 'dark' || theme == 'amoled') return ThemeMode.dark;
    if (theme == 'light' || theme == 'sepia') return ThemeMode.light;

    // System mode with night schedule check
    if (nightModeSchedule.enabled && nightModeSchedule.isNightTime) {
      return ThemeMode.dark;
    }

    return ThemeMode.system;
  }

  bool get isSepia => theme == 'sepia';
  bool get isAmoled => theme == 'amoled';
  bool get isDarkScheduled =>
      theme == 'system' &&
      nightModeSchedule.enabled &&
      nightModeSchedule.isNightTime;
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsLocalDataSource _dataSource;

  SettingsNotifier(this._dataSource)
      : super(SettingsState(
          fontSize: _dataSource.getFontSize(),
          quranFont: _dataSource.getQuranFont(),
          scriptMode: _dataSource.getScriptMode(),
          ayahNumberStyle: _dataSource.getAyahNumberStyle(),
          lineHeight: _dataSource.getLineHeight(),
          showTranslation: _dataSource.getShowTranslation(),
          activeTranslationIds: _dataSource.getActiveTranslationIds(),
          readingViewMode: _dataSource.getReadingViewMode(),
          autoResumeLastAyah: _dataSource.getAutoResumeLastAyah(),
          defaultTafsirId: _dataSource.getDefaultTafsirId(),
          theme: _dataSource.getTheme(),
          nightModeSchedule: _dataSource.getNightModeSchedule(),
          selectedReciterId: _dataSource.getSelectedReciterId(),
          reducedMotion: _dataSource.getReducedMotion(),
          showWordByWord: _dataSource.getShowWordByWord(),
          showTajweed: _dataSource.getShowTajweed(),
        ));

  void setFontSize(int size) {
    state = state.copyWith(fontSize: size);
    _dataSource.setFontSize(size);
  }

  void setQuranFont(String font) {
    state = state.copyWith(quranFont: font);
    _dataSource.setQuranFont(font);
  }

  void setScriptMode(String mode) {
    state = state.copyWith(scriptMode: mode);
    _dataSource.setScriptMode(mode);

    // Default to a diacritic-friendly font when strict mushaf mode is enabled.
    if (mode == 'madinah' && state.quranFont != 'Hafs Smart') {
      setQuranFont('Hafs Smart');
    }
  }

  void setAyahNumberStyle(String style) {
    state = state.copyWith(ayahNumberStyle: style);
    _dataSource.setAyahNumberStyle(style);
  }

  void setLineHeight(String height) {
    state = state.copyWith(lineHeight: height);
    _dataSource.setLineHeight(height);
  }

  void setShowTranslation(bool show) {
    state = state.copyWith(showTranslation: show);
    _dataSource.setShowTranslation(show);
  }

  void setActiveTranslationIds(List<int> ids) {
    state = state.copyWith(activeTranslationIds: ids);
    _dataSource.setActiveTranslationIds(ids);
  }

  void setReadingViewMode(String mode) {
    state = state.copyWith(readingViewMode: mode);
    _dataSource.setReadingViewMode(mode);
  }

  void setAutoResumeLastAyah(bool enabled) {
    state = state.copyWith(autoResumeLastAyah: enabled);
    _dataSource.setAutoResumeLastAyah(enabled);
  }

  void setDefaultTafsirId(int id) {
    state = state.copyWith(defaultTafsirId: id);
    _dataSource.setDefaultTafsirId(id);
  }

  void setTheme(String theme) {
    state = state.copyWith(theme: theme);
    _dataSource.setTheme(theme);
  }

  void setNightModeSchedule(NightModeSchedule schedule) {
    state = state.copyWith(nightModeSchedule: schedule);
    _dataSource.setNightModeSchedule(schedule);
  }

  void setSelectedReciterId(int id) {
    state = state.copyWith(selectedReciterId: id);
    _dataSource.setSelectedReciterId(id);
  }

  void setReducedMotion(bool val) {
    state = state.copyWith(reducedMotion: val);
    _dataSource.setReducedMotion(val);
  }

  void setShowWordByWord(bool val) {
    state = state.copyWith(showWordByWord: val);
    _dataSource.setShowWordByWord(val);
  }

  void setShowTajweed(bool val) {
    state = state.copyWith(showTajweed: val);
    _dataSource.setShowTajweed(val);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(settingsLocalDataSourceProvider));
});
