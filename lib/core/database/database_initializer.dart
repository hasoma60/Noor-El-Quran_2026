import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'app_database.dart';

/// Initializes the database from bundled JSON on first launch.
class DatabaseInitializer {
  final AppDatabase _db;

  DatabaseInitializer(this._db);

  Future<void> initializeIfNeeded() async {
    final populated = await _db.isPopulated();
    if (populated) return;

    await _populateFromBundle();
  }

  Future<void> _populateFromBundle() async {
    final jsonString =
        await rootBundle.loadString('assets/data/quran_uthmani.json');
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Insert chapters
    final chaptersJson = data['chapters'] as List<dynamic>;
    final chapterCompanions = chaptersJson.map((c) {
      final ch = c as Map<String, dynamic>;
      final translatedNameMap = ch['translated_name'];
      final translatedName = translatedNameMap is Map<String, dynamic>
          ? translatedNameMap['name'] as String? ?? ''
          : '';

      return DbChaptersCompanion.insert(
        id: Value(ch['id'] as int),
        nameArabic: ch['name_arabic'] as String? ?? '',
        nameSimple: ch['name_simple'] as String? ?? '',
        nameComplex: Value(ch['name_complex'] as String? ?? ''),
        versesCount: ch['verses_count'] as int? ?? 0,
        revelationPlace: Value(ch['revelation_place'] as String? ?? ''),
        revelationOrder: Value(ch['revelation_order'] as int? ?? 0),
        bismillahPre: Value(ch['bismillah_pre'] as bool? ?? true),
        translatedName: Value(translatedName),
      );
    }).toList();

    await _db.insertChaptersBatch(chapterCompanions);

    // Insert verses and translations chapter by chapter
    final versesMap = data['verses'] as Map<String, dynamic>;
    for (final entry in versesMap.entries) {
      final versesList = entry.value as List<dynamic>;
      final verseCompanions = <DbVersesCompanion>[];
      final translationCompanions = <DbTranslationsCompanion>[];

      for (final v in versesList) {
        final verse = v as Map<String, dynamic>;
        final verseId = verse['id'] as int;
        final verseKey = verse['verse_key'] as String;
        final parts = verseKey.split(':');
        final chapterId = int.parse(parts[0]);
        final verseNumber = int.parse(parts[1]);

        verseCompanions.add(DbVersesCompanion.insert(
          id: Value(verseId),
          chapterId: chapterId,
          verseNumber: verseNumber,
          verseKey: verseKey,
          textUthmani: verse['text_uthmani'] as String? ?? '',
          textUthmaniTajweed:
              Value(verse['text_uthmani_tajweed'] as String?),
        ));

        // Insert translations
        final translations = verse['translations'] as List<dynamic>?;
        if (translations != null) {
          for (final t in translations) {
            final tr = t as Map<String, dynamic>;
            translationCompanions.add(DbTranslationsCompanion.insert(
              verseId: verseId,
              resourceId: tr['resource_id'] as int? ?? 0,
              translationText: tr['text'] as String? ?? '',
            ));
          }
        }
      }

      await _db.insertVersesBatch(verseCompanions);
      if (translationCompanions.isNotEmpty) {
        await _db.insertTranslationsBatch(translationCompanions);
      }
    }

    // Rebuild FTS5 index after population
    await _db.rebuildFtsIndex();
  }
}
