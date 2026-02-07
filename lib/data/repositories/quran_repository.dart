import '../../core/errors/exceptions.dart';
import '../../core/services/app_logger.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/verse.dart';
import '../../domain/entities/search_result.dart';
import '../datasources/remote/quran_remote_datasource.dart';
import '../datasources/remote/alquran_cloud_datasource.dart';
import '../datasources/local/quran_local_datasource.dart';

/// Repository that tries primary API → fallback API → local bundle.
class QuranRepository {
  static const _log = AppLogger('QuranRepository');
  final QuranRemoteDataSource _primary;
  final AlQuranCloudDataSource _fallback;
  final QuranLocalDataSource _local;

  QuranRepository(this._primary, this._fallback, this._local);

  Future<List<Chapter>> getChapters() async {
    try {
      return await _primary.fetchChapters();
    } on ServerException catch (e) {
      _log.warning('Primary fetchChapters failed: $e');
    } catch (e) {
      _log.error('Primary fetchChapters unexpected error', e);
    }

    try {
      return await _fallback.fetchChapters();
    } catch (e) {
      _log.warning('Fallback fetchChapters failed: $e');
    }

    // Both APIs failed, use local bundle
    _log.info('Using local bundle for chapters');
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
    } on ServerException catch (e) {
      _log.warning('Primary fetchVerses($chapterId) failed: $e');
    } catch (e) {
      _log.error('Primary fetchVerses($chapterId) unexpected error', e);
    }

    try {
      return await _fallback.fetchVerses(chapterId);
    } catch (e) {
      _log.warning('Fallback fetchVerses($chapterId) failed: $e');
    }

    // Both APIs failed, use local bundle
    _log.info('Using local bundle for verses of chapter $chapterId');
    return await _local.fetchVerses(chapterId);
  }

  Future<Verse?> getVerseByKey(
    String verseKey, {
    List<int> translationIds = const [16],
  }) async {
    try {
      return await _primary.fetchVerseByKey(verseKey, translationIds: translationIds);
    } catch (e) {
      _log.warning('Primary fetchVerseByKey($verseKey) failed: $e');
    }

    // Fallback to local
    return await _local.fetchVerseByKey(verseKey);
  }

  Future<String> getTafsirContent(int tafsirId, String verseKey) async {
    try {
      return await _primary.fetchTafsirContent(tafsirId, verseKey);
    } catch (e) {
      _log.error('getTafsirContent failed for $verseKey (tafsir $tafsirId)', e);
      return '';
    }
  }

  Future<String?> getChapterAudioUrl(int chapterId, int reciterId) async {
    try {
      final url = await _primary.fetchChapterAudioUrl(chapterId, reciterId);
      if (url != null) return url;
    } catch (e) {
      _log.warning('Primary chapter audio failed for ch=$chapterId: $e');
    }

    // Fallback to AlQuran Cloud CDN
    return _fallback.fetchChapterAudioUrl(chapterId);
  }

  Future<String?> getVerseAudioUrl(String verseKey, int reciterId) async {
    try {
      final url = await _primary.fetchVerseAudioUrl(verseKey, reciterId);
      if (url != null) return url;
    } catch (e) {
      _log.warning('Primary verse audio failed for $verseKey: $e');
    }

    // Fallback to AlQuran Cloud CDN for verse audio
    return _fallback.fetchVerseAudioUrl(verseKey);
  }

  Future<List<Verse>> getJuzVerses(int juzNumber) async {
    try {
      return await _primary.fetchJuzVerses(juzNumber);
    } on ServerException catch (e) {
      _log.warning('Primary fetchJuzVerses($juzNumber) failed: $e');
    } catch (e) {
      _log.error('fetchJuzVerses($juzNumber) unexpected error', e);
    }

    // Fallback to local data
    return await _local.fetchJuzVerses(juzNumber);
  }

  Future<List<SearchResult>> search(String query) async {
    try {
      final results = await _primary.searchGlobal(query);
      if (results.isNotEmpty) return results;
    } catch (e) {
      _log.warning('Primary search failed for "$query": $e');
    }

    // Fallback to offline FTS5 search
    return await _local.searchOffline(query);
  }
}
