import 'package:flutter_test/flutter_test.dart';
import 'package:noor_alquran/core/errors/exceptions.dart';
import 'package:noor_alquran/data/datasources/remote/quran_remote_datasource.dart';
import 'package:noor_alquran/data/datasources/remote/alquran_cloud_datasource.dart';
import 'package:noor_alquran/data/datasources/local/quran_local_datasource.dart';
import 'package:noor_alquran/data/models/chapter_model.dart';
import 'package:noor_alquran/data/models/verse_model.dart';
import 'package:noor_alquran/data/models/search_result_model.dart';
import 'package:noor_alquran/data/repositories/quran_repository.dart';
import 'package:noor_alquran/domain/entities/chapter.dart';
import 'package:noor_alquran/domain/entities/verse.dart';
import 'package:noor_alquran/domain/entities/search_result.dart';

import '../../../helpers/test_data.dart';

// ─── Fake datasources for testing the 3-tier fallback ───

class _FakePrimary extends Fake implements QuranRemoteDataSource {
  bool shouldFail = false;
  List<ChapterModel>? chaptersResponse;
  List<VerseModel>? versesResponse;
  List<SearchResultModel>? searchResponse;
  String? tafsirResponse;
  String? verseAudioResponse;

  @override
  Future<List<ChapterModel>> fetchChapters() async {
    if (shouldFail) throw const ServerException(message: 'Primary down');
    return chaptersResponse ?? TestData.chapters();
  }

  @override
  Future<List<VerseModel>> fetchVerses(
    int chapterId, {
    List<int> translationIds = const [16],
    bool withWords = false,
    bool withTajweed = false,
  }) async {
    if (shouldFail) throw const ServerException(message: 'Primary down');
    return versesResponse ?? TestData.verses(chapterId: chapterId);
  }

  @override
  Future<VerseModel> fetchVerseByKey(
    String verseKey, {
    List<int> translationIds = const [16],
  }) async {
    if (shouldFail) throw const ServerException(message: 'Primary down');
    return TestData.verse(verseKey: verseKey);
  }

  @override
  Future<String> fetchTafsirContent(int tafsirId, String verseKey) async {
    if (shouldFail) throw const ServerException(message: 'Tafsir fail');
    return tafsirResponse ?? '<p>Tafsir text</p>';
  }

  @override
  Future<String?> fetchChapterAudioUrl(int chapterId, int reciterId) async {
    if (shouldFail) return null;
    return 'https://audio.qurancdn.com/chapter.mp3';
  }

  @override
  Future<String?> fetchVerseAudioUrl(String verseKey, int reciterId) async {
    if (shouldFail) return null;
    return verseAudioResponse ?? 'https://audio.qurancdn.com/test.mp3';
  }

  @override
  Future<List<VerseModel>> fetchJuzVerses(int juzNumber) async {
    if (shouldFail) throw const ServerException(message: 'Juz fail');
    return versesResponse ?? TestData.verses(count: 3);
  }

  @override
  Future<List<SearchResultModel>> searchGlobal(String query) async {
    if (shouldFail) throw const ServerException(message: 'Search fail');
    return searchResponse ?? [TestData.searchResult()];
  }
}

class _FakeFallback extends Fake implements AlQuranCloudDataSource {
  bool shouldFail = false;

  @override
  Future<List<ChapterModel>> fetchChapters() async {
    if (shouldFail) throw const ServerException(message: 'Fallback down');
    return TestData.chapters(count: 2);
  }

  @override
  Future<List<VerseModel>> fetchVerses(int chapterId) async {
    if (shouldFail) throw const ServerException(message: 'Fallback down');
    return TestData.verses(chapterId: chapterId, count: 5);
  }

  @override
  Future<String?> fetchChapterAudioUrl(int chapterId,
      {String reciter = 'ar.alafasy'}) async {
    if (shouldFail) return null;
    return 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$chapterId.mp3';
  }

  @override
  Future<String?> fetchVerseAudioUrl(String verseKey,
      {String reciter = 'ar.alafasy'}) async {
    if (shouldFail) return null;
    return 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3';
  }
}

class _FakeLocal extends Fake implements QuranLocalDataSource {
  @override
  Future<List<Chapter>> fetchChapters() async => TestData.chapters(count: 1);

  @override
  Future<List<Verse>> fetchVerses(int chapterId) async =>
      TestData.verses(chapterId: chapterId, count: 3);

  @override
  Future<Verse?> fetchVerseByKey(String verseKey) async =>
      TestData.verse(verseKey: verseKey);

  @override
  Future<List<Verse>> fetchJuzVerses(int juzNumber) async => [];

  @override
  Future<List<SearchResult>> searchOffline(String query) async =>
      [TestData.searchResult(verseKey: '112:1', text: 'قُلْ هُوَ اللَّهُ أَحَدٌ')];
}

void main() {
  late _FakePrimary primary;
  late _FakeFallback fallback;
  late _FakeLocal local;
  late QuranRepository repo;

  setUp(() {
    primary = _FakePrimary();
    fallback = _FakeFallback();
    local = _FakeLocal();
    repo = QuranRepository(primary, fallback, local);
  });

  group('QuranRepository - getChapters', () {
    test('returns chapters from primary when available', () async {
      final chapters = await repo.getChapters();
      expect(chapters.length, 3);
    });

    test('falls back to AlQuran Cloud when primary fails', () async {
      primary.shouldFail = true;
      final chapters = await repo.getChapters();
      expect(chapters.length, 2);
    });

    test('falls back to local when both APIs fail', () async {
      primary.shouldFail = true;
      fallback.shouldFail = true;
      final chapters = await repo.getChapters();
      expect(chapters.length, 1);
    });
  });

  group('QuranRepository - getVerses', () {
    test('returns verses from primary when available', () async {
      final verses = await repo.getVerses(1);
      expect(verses.length, 7);
      expect(verses.first.verseKey, '1:1');
    });

    test('falls back to AlQuran Cloud when primary fails', () async {
      primary.shouldFail = true;
      final verses = await repo.getVerses(1);
      expect(verses.length, 5);
    });

    test('falls back to local when both APIs fail', () async {
      primary.shouldFail = true;
      fallback.shouldFail = true;
      final verses = await repo.getVerses(1);
      expect(verses.length, 3);
    });
  });

  group('QuranRepository - getTafsirContent', () {
    test('returns tafsir from primary', () async {
      final tafsir = await repo.getTafsirContent(16, '1:1');
      expect(tafsir, '<p>Tafsir text</p>');
    });

    test('returns empty string when primary fails', () async {
      primary.shouldFail = true;
      final tafsir = await repo.getTafsirContent(16, '1:1');
      expect(tafsir, '');
    });
  });

  group('QuranRepository - getVerseAudioUrl', () {
    test('returns audio URL from primary', () async {
      final url = await repo.getVerseAudioUrl('1:1', 7);
      expect(url, 'https://audio.qurancdn.com/test.mp3');
    });

    test('falls back to AlQuran Cloud CDN when primary returns null', () async {
      primary.shouldFail = true;
      final url = await repo.getVerseAudioUrl('1:1', 7);
      expect(url, contains('cdn.islamic.network'));
    });

    test('returns null when both sources fail', () async {
      primary.shouldFail = true;
      fallback.shouldFail = true;
      final url = await repo.getVerseAudioUrl('1:1', 7);
      expect(url, isNull);
    });
  });

  group('QuranRepository - getJuzVerses', () {
    test('returns juz verses from primary', () async {
      final verses = await repo.getJuzVerses(1);
      expect(verses.length, 3);
    });

    test('falls back to local when primary fails', () async {
      primary.shouldFail = true;
      final verses = await repo.getJuzVerses(1);
      expect(verses, isEmpty);
    });
  });

  group('QuranRepository - search', () {
    test('returns results from primary', () async {
      final results = await repo.search('الله');
      expect(results.length, 1);
      expect(results.first.verseKey, '2:255');
    });

    test('falls back to offline FTS5 search when primary fails', () async {
      primary.shouldFail = true;
      final results = await repo.search('الله');
      expect(results.length, 1);
      expect(results.first.verseKey, '112:1');
    });

    test('uses offline search when primary returns empty', () async {
      primary.searchResponse = [];
      final results = await repo.search('xyz');
      // Primary returns empty, falls through to offline
      expect(results.length, 1);
    });
  });
}
