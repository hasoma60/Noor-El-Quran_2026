# Noor El-Quran 2026 - Project Context

## Architecture
- **Framework**: Flutter 3.6.2+ / Dart
- **State Management**: Flutter Riverpod 2.6.1
- **Navigation**: GoRouter 14.8.1
- **HTTP Client**: Dio 5.7.0
- **Audio**: just_audio 0.9.43 + audio_service 0.18.17
- **Storage**: SharedPreferences (structured data in JSON)
- **Pattern**: Clean Architecture (core/data/domain/features)

## API Sources
- **Primary**: Quran.com API v4 (`https://api.quran.com/api/v4`)
- **Fallback**: AlQuran Cloud (`https://api.alquran.cloud/v1`) - no auth required
- **Audio CDN**: `https://audio.qurancdn.com` + AlQuran Cloud CDN fallback

## Key Directories
```
lib/
  core/         - Constants, errors, network, router, services, theme, utils, widgets
  data/         - Datasources (local/remote), models, repositories
  domain/       - Entities
  features/     - Feature modules (home, reader, bookmarks, settings, etc.)
```

## Implemented Improvements (2026-02-02)
1. **AMOLED Theme**: Pure black (#000000) theme added with proper contrast (#E0E0E0 text)
2. **Font Stack Optimization**: Removed Lateef (Sindhi font). Stack: Amiri, Scheherazade New, Noto Naskh Arabic, Cairo
3. **Multi-Level Caching**: Memory + disk cache with TTL (chapters 1hr, verses 30min, tafsir 1hr, audio 1hr, search 5min)
4. **AlQuran Cloud Fallback**: Automatic fallback when primary API fails (auth errors, network)
5. **Repository Pattern**: QuranRepository wraps primary + fallback datasources
6. **Wakelock**: Screen stays awake during Quran reading
7. **Tajweed Color Constants**: 7-color Darussalam standard defined
8. **Extended Reciters**: 18 reciters (up from 10)
9. **Typography Standards**: Font size range 18-48sp, proper Arabic line heights

## Themes Available
- Light, Dark, AMOLED (pure black), Sepia, System (auto)
- Night mode schedule (auto-switch by hour)

## Reciters (18)
Mishary Alafasy, AbdulBaset (Mujawwad + Murattal), Husary, Maher, Saad Al-Ghamdi, Sudais, Shuraim, Shatri, Rifai, Qatami, Ajmy, Dossari, Minshawi, Basfar, Ali Jaber, Fares Abbad, Ibrahim Al-Akhdar

## Known Gaps (from research report, not yet implemented)
- Offline Quran text bundle (SQLite)
- Database migration to Drift (SQLite) + Hive
- OAuth2 for Quran Foundation API
- Word-by-word translation
- Tajweed color rendering in verses
- Mushaf page view
- Advanced search with FTS5
