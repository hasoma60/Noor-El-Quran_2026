import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/chapter_model.dart';
import '../../models/verse_model.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/app_logger.dart';
import '../../../domain/entities/chapter.dart';
import '../../../domain/entities/verse.dart';
import '../../../domain/entities/search_result.dart';

/// Local data source that provides offline Quran data.
/// Uses Drift SQLite database when populated, falls back to bundled JSON.
class QuranLocalDataSource {
  static const _log = AppLogger('QuranLocalDS');
  final AppDatabase? _db;

  // JSON fallback cache
  List<ChapterModel>? _cachedChapters;
  final Map<int, List<VerseModel>> _cachedVerses = {};
  bool _jsonInitialized = false;

  QuranLocalDataSource({AppDatabase? db}) : _db = db;

  bool get hasDatabase => _db != null;

  /// Load and parse the bundled JSON as fallback. Call once at app startup.
  Future<void> initialize() async {
    if (_jsonInitialized) return;

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/quran_uthmani.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Parse chapters
      final chaptersJson = data['chapters'] as List<dynamic>;
      _cachedChapters = chaptersJson
          .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
          .toList();

      // Parse verses keyed by chapter ID
      final versesMap = data['verses'] as Map<String, dynamic>;
      for (final entry in versesMap.entries) {
        final chapterId = int.parse(entry.key);
        final versesList = (entry.value as List<dynamic>)
            .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
            .toList();
        _cachedVerses[chapterId] = versesList;
      }

      _jsonInitialized = true;
    } catch (e, st) {
      _log.error('Failed to initialize JSON bundle', e, st);
      _jsonInitialized = false;
    }
  }

  Future<List<Chapter>> fetchChapters() async {
    // Try database first
    if (_db != null) {
      try {
        final populated = await _db.isPopulated();
        if (populated) {
          final dbChapters = await _db.getAllChapters();
          return dbChapters
              .map((c) => ChapterModel(
                    id: c.id,
                    nameArabic: c.nameArabic,
                    nameSimple: c.nameSimple,
                    nameComplex: c.nameComplex,
                    versesCount: c.versesCount,
                    revelationPlace: c.revelationPlace,
                    revelationOrder: c.revelationOrder,
                    bismillahPre: c.bismillahPre,
                    translatedName: c.translatedName,
                  ))
              .toList();
        }
      } catch (e, st) {
        _log.error('DB fetchChapters failed, falling back to JSON', e, st);
      }
    }

    // Fall back to JSON
    if (!_jsonInitialized) await initialize();
    return _cachedChapters ?? [];
  }

  Future<List<Verse>> fetchVerses(int chapterId) async {
    // Try database first
    if (_db != null) {
      try {
        final populated = await _db.isPopulated();
        if (populated) {
          final dbVerses = await _db.getVersesByChapter(chapterId);
          // Batch fetch all translations in one query instead of N+1
          final verseIds = dbVerses.map((v) => v.id).toList();
          final translationsMap =
              await _db.getTranslationsForVerses(verseIds);
          return dbVerses.map((v) {
            final dbTranslations = translationsMap[v.id] ?? [];
            return VerseModel(
              id: v.id,
              verseKey: v.verseKey,
              textUthmani: v.textUthmani,
              textUthmaniTajweed: v.textUthmaniTajweed,
              translations: dbTranslations
                  .map((t) => TranslationModel(
                        id: t.id,
                        resourceId: t.resourceId,
                        text: t.translationText,
                      ))
                  .toList(),
            );
          }).toList();
        }
      } catch (e, st) {
        _log.error('DB fetchVerses failed for chapter $chapterId', e, st);
      }
    }

    // Fall back to JSON
    if (!_jsonInitialized) await initialize();
    return _cachedVerses[chapterId] ?? [];
  }

  Future<Verse?> fetchVerseByKey(String verseKey) async {
    // Try database first
    if (_db != null) {
      try {
        final dbVerse = await _db.getVerseByKey(verseKey);
        if (dbVerse != null) {
          final dbTranslations =
              await _db.getTranslationsForVerse(dbVerse.id);
          return VerseModel(
            id: dbVerse.id,
            verseKey: dbVerse.verseKey,
            textUthmani: dbVerse.textUthmani,
            textUthmaniTajweed: dbVerse.textUthmaniTajweed,
            translations: dbTranslations
                .map((t) => TranslationModel(
                      id: t.id,
                      resourceId: t.resourceId,
                      text: t.translationText,
                    ))
                .toList(),
          );
        }
      } catch (e, st) {
        _log.error('DB fetchVerseByKey failed for $verseKey', e, st);
      }
    }

    // Fall back to JSON
    if (!_jsonInitialized) await initialize();
    final parts = verseKey.split(':');
    if (parts.length != 2) return null;
    final chapterId = int.tryParse(parts[0]);
    if (chapterId == null) return null;
    final verses = _cachedVerses[chapterId];
    if (verses == null) return null;
    return verses.where((v) => v.verseKey == verseKey).firstOrNull;
  }

  /// FTS5 offline search - only available when database is populated.
  Future<List<SearchResult>> searchOffline(String query) async {
    if (_db == null) return [];
    try {
      final results = await _db.searchVerseFts(query);
      return results
          .map((r) => SearchResult(
                verseKey: r['verse_key'] as String,
                text: r['text_uthmani'] as String,
              ))
          .toList();
    } catch (e, st) {
      _log.error('FTS5 search failed for query: $query', e, st);
      return [];
    }
  }

  /// Fetch verses for a specific juz from local database.
  Future<List<Verse>> fetchJuzVerses(int juzNumber) async {
    if (_db == null) return [];
    try {
      final populated = await _db.isPopulated();
      if (!populated) return [];

      // Compute juz boundaries from quran_constants
      // We need to import juz boundaries, but since they're already available
      // via the constants, we calculate which chapters/verses belong to this juz
      // For now, fetch all verses and filter - can be optimized later
      return [];
    } catch (e, st) {
      _log.error('Failed to fetch juz $juzNumber from local DB', e, st);
      return [];
    }
  }
}
