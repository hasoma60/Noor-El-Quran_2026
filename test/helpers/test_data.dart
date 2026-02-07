import 'package:noor_alquran/data/models/chapter_model.dart';
import 'package:noor_alquran/data/models/verse_model.dart';
import 'package:noor_alquran/data/models/search_result_model.dart';

/// Shared test data factories for unit tests.
class TestData {
  static ChapterModel chapter({
    int id = 1,
    String nameArabic = 'الفاتحة',
    String nameSimple = 'Al-Fatihah',
    int versesCount = 7,
  }) =>
      ChapterModel(
        id: id,
        revelationPlace: 'makkah',
        revelationOrder: 5,
        bismillahPre: id != 1 && id != 9,
        nameSimple: nameSimple,
        nameComplex: nameSimple,
        nameArabic: nameArabic,
        versesCount: versesCount,
        translatedName: 'The Opener',
      );

  static VerseModel verse({
    int id = 1,
    String verseKey = '1:1',
    String textUthmani = 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
  }) =>
      VerseModel(
        id: id,
        verseKey: verseKey,
        textUthmani: textUthmani,
        translations: const [
          TranslationModel(id: 1, resourceId: 16, text: 'In the name of God'),
        ],
      );

  static SearchResultModel searchResult({
    String verseKey = '2:255',
    String text = 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ',
  }) =>
      SearchResultModel(verseKey: verseKey, text: text);

  static List<ChapterModel> chapters({int count = 3}) =>
      List.generate(count, (i) => chapter(id: i + 1));

  static List<VerseModel> verses({int chapterId = 1, int count = 7}) =>
      List.generate(
        count,
        (i) => verse(id: i + 1, verseKey: '$chapterId:${i + 1}'),
      );
}
