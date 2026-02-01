const String appName = 'نور القرآن';
const String appVersion = '3.0.0';
const String quranApiBaseUrl = 'https://api.quran.com/api/v4';
const String audioBaseUrl = 'https://audio.qurancdn.com';

const int defaultReciterId = 7;
const int defaultTafsirId = 16;
const int inlineTranslationId = 16;
const int versesPerPage = 300;
const int searchDebounceMs = 600;
const int searchMinLength = 2;

const int fontSizeMin = 24;
const int fontSizeMax = 60;
const int defaultFontSize = 32;
const String defaultFont = 'KFGQPC Uthman Taha';
const String defaultLineHeight = 'normal';
const String defaultTheme = 'system';

// Line Heights (optimized for Arabic script)
const double quranLineHeight = 2.0;       // 1.8-2.2 for diacritics
const double translationLineHeight = 1.6;  // 1.5-1.7
const double uiLineHeight = 1.3;           // 1.2-1.4

// Cache TTLs in milliseconds
const int chapterCacheTtl = 60 * 60 * 1000; // 1 hour
const int versesCacheTtl = 30 * 60 * 1000; // 30 minutes
const int tafsirCacheTtl = 60 * 60 * 1000; // 1 hour
const int audioCacheTtl = 60 * 60 * 1000; // 1 hour
const int searchCacheTtl = 5 * 60 * 1000; // 5 minutes
