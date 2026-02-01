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

const int fontSizeMin = 20;
const int fontSizeMax = 60;
const int defaultFontSize = 32;
const String defaultFont = 'Amiri';
const String defaultLineHeight = 'normal';
const String defaultTheme = 'system';

// Cache TTLs in milliseconds
const int chapterCacheTtl = 60 * 60 * 1000; // 1 hour
const int versesCacheTtl = 30 * 60 * 1000; // 30 minutes
const int tafsirCacheTtl = 60 * 60 * 1000; // 1 hour
const int audioCacheTtl = 60 * 60 * 1000; // 1 hour
const int searchCacheTtl = 5 * 60 * 1000; // 5 minutes
