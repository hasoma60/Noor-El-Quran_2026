import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/chapter_model.dart';
import '../../models/verse_model.dart';
import '../../models/search_result_model.dart';

class QuranRemoteDataSource {
  final ApiClient _client;

  QuranRemoteDataSource(this._client);

  Future<List<ChapterModel>> fetchChapters() async {
    try {
      final response = await _client.get('/chapters', queryParameters: {'language': 'ar'});
      final chapters = (response.data['chapters'] as List<dynamic>)
          .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
          .toList();
      return chapters;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch chapters: $e');
    }
  }

  Future<List<VerseModel>> fetchVerses(
    int chapterId, {
    List<int> translationIds = const [inlineTranslationId],
    bool withWords = false,
  }) async {
    try {
      final translations = translationIds.join(',');
      final response = await _client.get(
        '/verses/by_chapter/$chapterId',
        queryParameters: {
          'language': 'ar',
          'words': withWords,
          if (withWords) 'word_fields': 'text_uthmani,translation',
          'translations': translations,
          'fields': 'text_uthmani',
          'per_page': versesPerPage,
        },
      );
      return (response.data['verses'] as List<dynamic>)
          .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
          .toList();
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
    try {
      final response = await _client.get('/tafsirs/$tafsirId/by_ayah/$verseKey');
      return response.data['tafsir']['text'] as String;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch tafsir: $e');
    }
  }

  Future<String?> fetchChapterAudioUrl(int chapterId, int reciterId) async {
    try {
      final response = await _client.get('/chapter_recitations/$reciterId/$chapterId');
      return response.data['audio_file']['audio_url'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String?> fetchVerseAudioUrl(String verseKey, int reciterId) async {
    if (reciterId <= 0) return null;
    try {
      final response = await _client.get('/recitations/$reciterId/by_ayah/$verseKey');
      final audioFile = (response.data['audio_files'] as List<dynamic>?)?.firstOrNull;
      if (audioFile == null) return null;
      final url = (audioFile as Map<String, dynamic>)['url'] as String?;
      if (url == null) return null;
      return url.startsWith('http') ? url : '$audioBaseUrl/$url';
    } catch (e) {
      return null;
    }
  }

  Future<List<VerseModel>> fetchJuzVerses(int juzNumber) async {
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
      return (response.data['verses'] as List<dynamic>)
          .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch juz verses: $e');
    }
  }

  Future<List<SearchResultModel>> searchGlobal(String query) async {
    if (query.trim().length < searchMinLength) return [];
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
      final results = response.data['search']?['results'] as List<dynamic>? ?? [];
      return results
          .map((r) => SearchResultModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
