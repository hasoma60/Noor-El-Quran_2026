import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [DbChapters, DbVerses, DbTranslations])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'noor_alquran'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _createFtsAndIndexes();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await _createIndexes();
        }
      },
    );
  }

  Future<void> _createFtsAndIndexes() async {
    // Create FTS5 virtual table for offline search
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS verse_fts USING fts5(
        verse_key,
        text_uthmani,
        content=db_verses,
        content_rowid=id
      )
    ''');
    // Create triggers to keep FTS index in sync
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS verses_ai AFTER INSERT ON db_verses BEGIN
        INSERT INTO verse_fts(rowid, verse_key, text_uthmani)
        VALUES (new.id, new.verse_key, new.text_uthmani);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS verses_ad AFTER DELETE ON db_verses BEGIN
        INSERT INTO verse_fts(verse_fts, rowid, verse_key, text_uthmani)
        VALUES ('delete', old.id, old.verse_key, old.text_uthmani);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS verses_au AFTER UPDATE ON db_verses BEGIN
        INSERT INTO verse_fts(verse_fts, rowid, verse_key, text_uthmani)
        VALUES ('delete', old.id, old.verse_key, old.text_uthmani);
        INSERT INTO verse_fts(rowid, verse_key, text_uthmani)
        VALUES (new.id, new.verse_key, new.text_uthmani);
      END
    ''');
    await _createIndexes();
  }

  Future<void> _createIndexes() async {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_verses_chapter_id ON db_verses(chapter_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_verses_verse_key ON db_verses(verse_key)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_translations_verse_id ON db_translations(verse_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_translations_resource_id ON db_translations(resource_id)');
  }

  // --- Chapter operations ---

  Future<List<DbChapter>> getAllChapters() =>
      (select(dbChapters)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<DbChapter?> getChapter(int id) =>
      (select(dbChapters)..where((t) => t.id.equals(id))).getSingleOrNull();

  // --- Verse operations ---

  Future<List<DbVerse>> getVersesByChapter(int chapterId) =>
      (select(dbVerses)
            ..where((t) => t.chapterId.equals(chapterId))
            ..orderBy([(t) => OrderingTerm.asc(t.verseNumber)]))
          .get();

  Future<DbVerse?> getVerseByKey(String verseKey) =>
      (select(dbVerses)..where((t) => t.verseKey.equals(verseKey)))
          .getSingleOrNull();

  // --- Translation operations ---

  Future<List<DbTranslation>> getTranslationsForVerse(int verseId) =>
      (select(dbTranslations)..where((t) => t.verseId.equals(verseId))).get();

  /// Batch fetch: get all translations for a list of verse IDs in one query.
  Future<Map<int, List<DbTranslation>>> getTranslationsForVerses(
      List<int> verseIds) async {
    if (verseIds.isEmpty) return {};
    final results = await (select(dbTranslations)
          ..where((t) => t.verseId.isIn(verseIds)))
        .get();
    final map = <int, List<DbTranslation>>{};
    for (final t in results) {
      map.putIfAbsent(t.verseId, () => []).add(t);
    }
    return map;
  }

  // --- Batch insert operations ---

  Future<void> insertChaptersBatch(List<DbChaptersCompanion> chapters) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(dbChapters, chapters);
    });
  }

  Future<void> insertVersesBatch(List<DbVersesCompanion> verses) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(dbVerses, verses);
    });
  }

  Future<void> insertTranslationsBatch(
      List<DbTranslationsCompanion> translations) async {
    await batch((b) {
      b.insertAll(dbTranslations, translations,
          mode: InsertMode.insertOrReplace);
    });
  }

  // --- FTS5 search ---

  Future<List<Map<String, dynamic>>> searchVerseFts(String query) async {
    final results = await customSelect(
      'SELECT rowid, verse_key, text_uthmani FROM verse_fts WHERE text_uthmani MATCH ? ORDER BY rank LIMIT 50',
      variables: [Variable.withString(query)],
    ).get();
    return results
        .map((row) => {
              'rowid': row.data['rowid'],
              'verse_key': row.data['verse_key'],
              'text_uthmani': row.data['text_uthmani'],
            })
        .toList();
  }

  Future<void> rebuildFtsIndex() async {
    await customStatement(
        "INSERT INTO verse_fts(verse_fts) VALUES('rebuild')");
  }

  // --- Population check ---

  Future<bool> isPopulated() async {
    final count = await (selectOnly(dbChapters)
          ..addColumns([dbChapters.id.count()]))
        .map((row) => row.read(dbChapters.id.count()))
        .getSingle();
    return (count ?? 0) > 0;
  }
}
