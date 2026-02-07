# Noor El-Quran 2026 - Project Context

## Architecture
- **Framework**: Flutter 3.6.2+ / Dart
- **State Management**: Flutter Riverpod 2.6.1
- **Navigation**: GoRouter 14.8.1
- **HTTP Client**: Dio 5.7.0
- **Audio**: just_audio 0.9.43 + audio_service 0.18.17
- **Database**: Drift 2.28+ (SQLite) with FTS5 for offline search
- **Storage**: SharedPreferences (settings/bookmarks/progress) + Drift SQLite (Quran text)
- **Pattern**: Clean Architecture (core/data/domain/features)

## API Sources
- **Primary**: Quran.com API v4 (`https://api.quran.com/api/v4`)
- **Fallback**: AlQuran Cloud (`https://api.alquran.cloud/v1`) - no auth required
- **Local Bundle**: `assets/data/quran_uthmani.json` (~6.3MB) - offline fallback
- **Audio CDN**: `https://audio.qurancdn.com` + AlQuran Cloud CDN fallback

## Key Directories
```
lib/
  core/         - Constants, errors, network, router, services, theme, utils, widgets
  core/database - Drift SQLite tables, database, initializer (app_database.dart, tables.dart)
  data/         - Datasources (local/remote), models, repositories
  domain/       - Entities
  features/     - Feature modules (home, reader, bookmarks, settings, etc.)
assets/data/    - quran_uthmani.json, quran_pages.json, quran_metadata.json
scripts/        - generate_quran_data.dart (data generation tool)
```

## Data Flow (3-tier fallback)
1. Primary API (Quran.com v4) -> 2. Fallback API (AlQuran Cloud) -> 3. Local bundle (JSON/SQLite)

## Implemented Improvements (2026-02-02)
1. **AMOLED Theme**: Pure black (#000000) theme added with proper contrast (#E0E0E0 text)
2. **Font Stack Optimization**: Removed Lateef (Sindhi font). Stack: Amiri, Scheherazade New, Noto Naskh Arabic, Cairo
3. **Multi-Level Caching**: Memory + disk cache with TTL (chapters 1hr, verses 30min, tafsir 1hr, audio 1hr, search 5min)
4. **AlQuran Cloud Fallback**: Automatic fallback when primary API fails (auth errors, network)
5. **Repository Pattern**: QuranRepository wraps primary + fallback + local datasources
6. **Wakelock**: Screen stays awake during Quran reading
7. **Tajweed Color Constants**: 7-color Darussalam standard + Quran.com API class mappings
8. **Extended Reciters**: 18 reciters (up from 10)
9. **Typography Standards**: Font size range 18-48sp, proper Arabic line heights
10. **Stats Screen Fix**: Fixed "Bottom Overflowed by 17 Pixels" on S25 Ultra (childAspectRatio 1.5->1.2, padding adjusted)
11. **Offline Quran Bundle**: All 6236 verses + 114 chapters + Al-Muyassar translation bundled in JSON (~6.3MB)
12. **Drift SQLite Database**: Tables (DbChapters, DbVerses, DbTranslations) with FTS5 virtual table for offline Arabic search
13. **Database Initializer**: Auto-populates SQLite from bundled JSON on first launch, rebuilds FTS5 index
14. **Tajweed Rendering**: TajweedText widget parses Quran.com tajweed HTML and renders color-coded TextSpans
15. **Word-by-Word Display**: WordByWordWidget shows each word with its translation in RTL Wrap layout
16. **Mushaf Page View**: 604-page traditional mushaf reading with RTL PageView swipe, page jump dialog
17. **Settings Extensions**: showWordByWord, showTajweed toggles added to SettingsState/SettingsNotifier/SettingsLocalDataSource
18. **Reading Mode Toggle**: AppBar button switches between flowing (ListView) and mushaf (PageView) modes
19. **Tajweed Legend**: Bottom sheet showing 7 tajweed rule colors with Arabic names
20. **Offline Search**: FTS5-based Arabic text search falls back when API is unreachable

## Themes Available
- Light, Dark, AMOLED (pure black), Sepia, System (auto)
- Night mode schedule (auto-switch by hour)

## Reading Modes
- **Flowing**: Verse-by-verse ListView with toolbar, translation, tafsir links
- **Mushaf**: Traditional 604-page PageView with RTL swipe, chapter headers, page numbers

## Reciters (18)
Mishary Alafasy, AbdulBaset (Mujawwad + Murattal), Husary, Maher, Saad Al-Ghamdi, Sudais, Shuraim, Shatri, Rifai, Qatami, Ajmy, Dossari, Minshawi, Basfar, Ali Jaber, Fares Abbad, Ibrahim Al-Akhdar

## Refactoring (2026-02-08) - 5-Phase Comprehensive Overhaul

### Phase 1: Stability & Reliability
21. **Mushaf Swipe Direction Fix**: Wrapped PageView.builder in `Directionality(textDirection: TextDirection.ltr)` to fix RTL swipe cancellation from global Directionality
22. **App Logger**: `lib/core/services/app_logger.dart` - Lightweight logger using `dart:developer` with per-class tags for DevTools filtering
23. **N+1 Query Fix**: Added `getTranslationsForVerses()` batch method using `isIn()` clause - reduces Al-Baqarah from 287 queries to 2
24. **Database Indexes**: Schema v1->v2 with 4 indexes (idx_verses_chapter_id, idx_verses_verse_key, idx_translations_verse_id, idx_translations_resource_id)
25. **Transaction-Wrapped DB Init**: `_populateFromBundle()` runs in transaction with integrity check (~6236 verse count validation)
26. **Fallback Coverage Fixes**: getTafsirContent returns '' on failure, getVerseAudioUrl falls back to AlQuran Cloud CDN, getJuzVerses falls back to local
27. **LRU Cache Eviction**: CacheService bounded to 200 memory entries with LRU tracking
28. **Silent Catch Replacement**: ~20+ `catch (_) {}` blocks replaced with AppLogger calls across 10+ files

### Phase 2: Network & Architecture
29. **API Retry + Backoff**: Exponential backoff (1s, 2s, 4s), retries on 429/500/502/503/504, respects Retry-After header
30. **Translation ID Fix**: versesProvider now passes `translationIds: settings.activeTranslationIds` (was hardcoded to [16])
31. **Use Cases**: `GetChapterVerses`, `SearchQuran`, `GetJuzVerses` in `lib/domain/usecases/`
32. **Route Name Constants**: `lib/core/router/route_names.dart` - all 10 route names as constants
33. **SharedPreferences Error Fix**: Replaced `throw UnimplementedError()` with `throw StateError()` with diagnostic message

### Phase 3: UI Decomposition
34. **BaseBottomSheet**: Reusable bottom sheet widget (`lib/core/widgets/base_bottom_sheet.dart`) used by TafsirSheet, NoteSheet, ShareSheet
35. **Reader Screen Decomposition**: Extracted `ChapterHeader` widget, reduced reader_screen.dart to ~250 LOC orchestrator
36. **Mushaf Provider Extraction**: Moved providers, getJuzForVerse(), juzArabicNames to `lib/features/reader/providers/mushaf_provider.dart`
37. **Settings Screen Decomposition**: Extracted 4 section widgets (AppearanceSection, ReadingSection, AudioSection, BackupSection)

### Phase 4: Code Quality & Cleanup
38. **Unused Font Removal**: Deleted Lateef-Regular.ttf and KFGQPC-Uthmanic-Script-HAFS.otf (~236KB+ saved)
39. **UI Constants**: `lib/core/constants/ui_constants.dart` - bottomSheetRadius, accentColor, font sizes, line heights, border radii
40. **Stricter Lint Rules**: analysis_options.yaml: prefer_const_constructors, avoid_print, prefer_final_locals, sized_box_for_whitespace, etc.
41. **flutter_html Stable**: Updated from ^3.0.0-beta.2 to ^3.0.0 (stable)

### Phase 5: Testing Infrastructure
42. **Test Data Factory**: `test/helpers/test_data.dart` - shared ChapterModel, VerseModel, SearchResultModel factories
43. **Repository Tests**: 16 tests covering 3-tier fallback for getChapters, getVerses, getTafsirContent, getVerseAudioUrl, getJuzVerses, search
44. **Cache Service Tests**: 10 tests covering put/get, TTL expiry, LRU eviction, clearExpired, remove, clearAll, overwrite

## Database Schema (Drift SQLite) - Schema v2
- `db_chapters` - id PK, nameArabic, nameSimple, nameComplex, versesCount, revelationPlace, revelationOrder, bismillahPre, translatedName
- `db_verses` - id PK, chapterId FK (indexed), verseNumber, verseKey (indexed), textUthmani, textUthmaniTajweed (nullable)
- `db_translations` - id autoIncrement, verseId (indexed), resourceId (indexed), translationText
- `verse_fts` (FTS5 virtual table) - verse_key, text_uthmani (content synced from db_verses via triggers)

## Test Coverage
- **31 tests total**: 5 util tests + 16 repository tests + 10 cache service tests
- Run: `flutter test`

## Known Gaps (remaining)
- OAuth2 for Quran Foundation API
- Offline audio caching
- Advanced tajweed audio sync (word highlighting during playback)
- Widget tests for home screen and verse card (planned, not yet implemented)
