import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/chapter_model.dart';
import '../../models/verse_model.dart';

/// Fallback API using AlQuran Cloud (no authentication required)
class AlQuranCloudDataSource {
  late final Dio _dio;

  AlQuranCloudDataSource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: alquranCloudBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<List<ChapterModel>> fetchChapters() async {
    try {
      final response = await _dio.get('/surah');
      final data = response.data['data'] as List<dynamic>;
      return data.map((s) {
        final surah = s as Map<String, dynamic>;
        return ChapterModel(
          id: surah['number'] as int,
          revelationPlace: (surah['revelationType'] as String?)?.toLowerCase() ?? '',
          revelationOrder: surah['number'] as int,
          bismillahPre: (surah['number'] as int) != 1 && (surah['number'] as int) != 9,
          nameSimple: surah['englishName'] as String? ?? '',
          nameComplex: surah['englishName'] as String? ?? '',
          nameArabic: surah['name'] as String? ?? '',
          versesCount: surah['numberOfAyahs'] as int? ?? 0,
          translatedName: surah['englishNameTranslation'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      throw ServerException(message: 'AlQuran Cloud: Failed to fetch chapters: $e');
    }
  }

  Future<List<VerseModel>> fetchVerses(int chapterId) async {
    try {
      final response = await _dio.get('/surah/$chapterId/quran-uthmani');
      final data = response.data['data'] as Map<String, dynamic>;
      final ayahs = data['ayahs'] as List<dynamic>;
      return ayahs.map((a) {
        final ayah = a as Map<String, dynamic>;
        return VerseModel(
          id: ayah['number'] as int,
          verseKey: '$chapterId:${ayah['numberInSurah']}',
          textUthmani: ayah['text'] as String? ?? '',
          translations: const [],
          words: const [],
        );
      }).toList();
    } catch (e) {
      throw ServerException(message: 'AlQuran Cloud: Failed to fetch verses: $e');
    }
  }

  Future<String?> fetchChapterAudioUrl(int chapterId, {String reciter = 'ar.alafasy'}) async {
    try {
      // AlQuran Cloud provides full surah audio
      // URL pattern: https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/{chapterId}.mp3
      return 'https://cdn.islamic.network/quran/audio-surah/128/$reciter/$chapterId.mp3';
    } catch (e) {
      return null;
    }
  }
}
