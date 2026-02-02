import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/cache_service.dart';
import '../../models/chapter_model.dart';
import '../../models/verse_model.dart';
import '../../models/search_result_model.dart';

class QuranRemoteDataSource {
  final ApiClient _client;
  final CacheService _cache;

  QuranRemoteDataSource(this._client, this._cache);

  Future<List<ChapterModel>> fetchChapters() async {
    const cacheKey = 'chapters_ar';
    final cached = await _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached
          .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _client.get('/chapters', queryParameters: {'language': 'ar'});
      final chaptersJson = response.data['chapters'] as List<dynamic>;
      final chapters = chaptersJson
          .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
          .toList();

      // Cache the raw JSON for rehydration
      await _cache.put(cacheKey, chaptersJson, ttlMs: chapterCacheTtl);
      return chapters;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch chapters: $e');
    }
  }

  Future<List<VerseModel>> fetchVerses(
    int chapterId, {
    List<int> translationIds = const [inlineTranslationId],
    bool withWords = false,
    bool withTajweed = false,
  }) async {
    final translations = translationIds.join(',');
    final cacheKey = 'verses_${chapterId}_${translations}_${withWords}_$withTajweed';
    final cached = await _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached
          .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    try {
      final fields = withTajweed ? 'text_uthmani,text_uthmani_tajweed' : 'text_uthmani';
      final response = await _client.get(
        '/verses/by_chapter/$chapterId',
        queryParameters: {
          'language': 'ar',
          'words': withWords,
          if (withWords) 'word_fields': 'text_uthmani,translation',
          'translations': translations,
          'fields': fields,
          'per_page': versesPerPage,
        },
      );
      final versesJson = response.data['verses'] as List<dynamic>;
      final verses = versesJson
          .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
          .toList();

      await _cache.put(cacheKey, versesJson, ttlMs: versesCacheTtl);
      return verses;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch verses: $e');
    }
  }

  Future<VerseModel> fetchVerseByKey(
    String verseKey, {
    List<int> translationIds = const [inlineTranslationId],
  }) async {
    try {
      final translations = translationIds.join(',');
      final response = await _client.get(
        '/verses/by_key/$verseKey',
        queryParameters: {
          'language': 'ar',
          'words': false,
          'translations': translations,
          'fields': 'text_uthmani',
        },
      );
      return VerseModel.fromJson(response.data['verse'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch verse: $e');
    }
  }

  Future<String> fetchTafsirContent(int tafsirId, String verseKey) async {
    final cacheKey = 'tafsir_${tafsirId}_$verseKey';
    final cached = await _cache.get<String>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _client.get('/tafsirs/$tafsirId/by_ayah/$verseKey');
      final text = response.data['tafsir']['text'] as String;
      await _cache.put(cacheKey, text, ttlMs: tafsirCacheTtl);
      return text;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch tafsir: $e');
    }
  }

  Future<String?> fetchChapterAudioUrl(int chapterId, int reciterId) async {
    final cacheKey = 'audio_chapter_${reciterId}_$chapterId';
    final cached = await _cache.get<String>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _client.get('/chapter_recitations/$reciterId/$chapterId');
      final url = response.data['audio_file']['audio_url'] as String?;
      if (url != null) {
        await _cache.put(cacheKey, url, ttlMs: audioCacheTtl);
      }
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<String?> fetchVerseAudioUrl(String verseKey, int reciterId) async {
    if (reciterId <= 0) return null;

    final cacheKey = 'audio_verse_${reciterId}_$verseKey';
    final cached = await _cache.get<String>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _client.get('/recitations/$reciterId/by_ayah/$verseKey');
      final audioFile = (response.data['audio_files'] as List<dynamic>?)?.firstOrNull;
      if (audioFile == null) return null;
      final url = (audioFile as Map<String, dynamic>)['url'] as String?;
      if (url == null) return null;
      final fullUrl = url.startsWith('http') ? url : '$audioBaseUrl/$url';
      await _cache.put(cacheKey, fullUrl, ttlMs: audioCacheTtl);
      return fullUrl;
    } catch (e) {
      return null;
    }
  }

  Future<List<VerseModel>> fetchJuzVerses(int juzNumber) async {
    final cacheKey = 'juz_verses_$juzNumber';
    final cached = await _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached
          .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _client.get(
        '/verses/by_juz/$juzNumber',
        queryParameters: {
          'language': 'ar',
          'words': false,
          'translations': '$inlineTranslationId',
          'fields': 'text_uthmani',
          'per_page': versesPerPage,
        },
      );
      final versesJson = response.data['verses'] as List<dynamic>;
      final verses = versesJson
          .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
          .toList();

      await _cache.put(cacheKey, versesJson, ttlMs: versesCacheTtl);
      return verses;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch juz verses: $e');
    }
  }

  Future<List<SearchResultModel>> searchGlobal(String query) async {
    if (query.trim().length < searchMinLength) return [];

    final cacheKey = 'search_${query.trim()}';
    final cached = await _cache.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached
          .map((r) => SearchResultModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _client.get(
        '/search',
        queryParameters: {
          'q': query.trim(),
          'size': 20,
          'page': 1,
          'language': 'ar',
        },
      );
      final resultsJson = response.data['search']?['results'] as List<dynamic>? ?? [];
      final results = resultsJson
          .map((r) => SearchResultModel.fromJson(r as Map<String, dynamic>))
          .toList();

      if (resultsJson.isNotEmpty) {
        await _cache.put(cacheKey, resultsJson, ttlMs: searchCacheTtl);
      }
      return results;
    } catch (e) {
      return [];
    }
  }
}
