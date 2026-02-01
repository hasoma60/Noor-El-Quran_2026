import '../../core/errors/exceptions.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/verse.dart';
import '../../domain/entities/search_result.dart';
import '../datasources/remote/quran_remote_datasource.dart';
import '../datasources/remote/alquran_cloud_datasource.dart';

/// Repository that tries the primary API (Quran Foundation) first,
/// then falls back to AlQuran Cloud on failure (auth errors, network issues).
class QuranRepository {
  final QuranRemoteDataSource _primary;
  final AlQuranCloudDataSource _fallback;

  QuranRepository(this._primary, this._fallback);

  Future<List<Chapter>> getChapters() async {
    try {
      return await _primary.fetchChapters();
    } on ServerException {
      return await _fallback.fetchChapters();
    } catch (_) {
      return await _fallback.fetchChapters();
    }
  }

  Future<List<Verse>> getVerses(
    int chapterId, {
    List<int> translationIds = const [16],
    bool withWords = false,
  }) async {
    try {
      return await _primary.fetchVerses(
        chapterId,
        translationIds: translationIds,
        withWords: withWords,
      );
    } on ServerException {
      // Fallback only provides Uthmani text without translations
      return await _fallback.fetchVerses(chapterId);
    } catch (_) {
      return await _fallback.fetchVerses(chapterId);
    }
  }

  Future<Verse> getVerseByKey(
    String verseKey, {
    List<int> translationIds = const [16],
  }) async {
    return await _primary.fetchVerseByKey(verseKey, translationIds: translationIds);
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
      // No juz endpoint in AlQuran Cloud, rethrow
      rethrow;
    }
  }

  Future<List<SearchResult>> search(String query) async {
    return await _primary.searchGlobal(query);
  }
}
