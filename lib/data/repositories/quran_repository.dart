import '../../core/errors/exceptions.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/verse.dart';
import '../../domain/entities/search_result.dart';
import '../datasources/remote/quran_remote_datasource.dart';
import '../datasources/remote/alquran_cloud_datasource.dart';
import '../datasources/local/quran_local_datasource.dart';

/// Repository that tries primary API → fallback API → local bundle.
class QuranRepository {
  final QuranRemoteDataSource _primary;
  final AlQuranCloudDataSource _fallback;
  final QuranLocalDataSource _local;

  QuranRepository(this._primary, this._fallback, this._local);

  Future<List<Chapter>> getChapters() async {
    try {
      return await _primary.fetchChapters();
    } on ServerException {
      // Primary failed, try cloud fallback
    } catch (_) {}

    try {
      return await _fallback.fetchChapters();
    } catch (_) {}

    // Both APIs failed, use local bundle
    return await _local.fetchChapters();
  }

  Future<List<Verse>> getVerses(
    int chapterId, {
    List<int> translationIds = const [16],
    bool withWords = false,
    bool withTajweed = false,
  }) async {
    try {
      return await _primary.fetchVerses(
        chapterId,
        translationIds: translationIds,
        withWords: withWords,
        withTajweed: withTajweed,
      );
    } on ServerException {
      // Primary failed
    } catch (_) {}

    try {
      return await _fallback.fetchVerses(chapterId);
    } catch (_) {}

    // Both APIs failed, use local bundle
    return await _local.fetchVerses(chapterId);
  }

  Future<Verse?> getVerseByKey(
    String verseKey, {
    List<int> translationIds = const [16],
  }) async {
    try {
      return await _primary.fetchVerseByKey(verseKey, translationIds: translationIds);
    } catch (_) {}

    // Fallback to local
    return await _local.fetchVerseByKey(verseKey);
  }

  Future<String> getTafsirContent(int tafsirId, String verseKey) async {
    return await _primary.fetchTafsirContent(tafsirId, verseKey);
  }

  Future<String?> getChapterAudioUrl(int chapterId, int reciterId) async {
    try {
      final url = await _primary.fetchChapterAudioUrl(chapterId, reciterId);
      if (url != null) return url;
    } catch (_) {}

    // Fallback to AlQuran Cloud CDN
    return _fallback.fetchChapterAudioUrl(chapterId);
  }

  Future<String?> getVerseAudioUrl(String verseKey, int reciterId) async {
    return await _primary.fetchVerseAudioUrl(verseKey, reciterId);
  }

  Future<List<Verse>> getJuzVerses(int juzNumber) async {
    try {
      return await _primary.fetchJuzVerses(juzNumber);
    } on ServerException {
      rethrow;
    }
  }

  Future<List<SearchResult>> search(String query) async {
    try {
      final results = await _primary.searchGlobal(query);
      if (results.isNotEmpty) return results;
    } catch (_) {}

    // Fallback to offline FTS5 search
    return await _local.searchOffline(query);
  }
}
