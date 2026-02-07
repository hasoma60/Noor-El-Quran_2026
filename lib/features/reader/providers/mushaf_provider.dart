import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local/mushaf_page_datasource.dart';
import '../../../domain/entities/verse.dart';
import '../../home/providers/chapters_provider.dart';
import '../../../core/constants/quran_constants.dart';

final mushafPageDataSourceProvider = Provider<MushafPageDataSource>((ref) {
  return MushafPageDataSource();
});

final mushafPagesProvider = FutureProvider<List<MushafPage>>((ref) async {
  final dataSource = ref.watch(mushafPageDataSourceProvider);
  return dataSource.getAllPages();
});

/// Fetches verses for a specific mushaf page.
final mushafPageVersesProvider =
    FutureProvider.family<List<Verse>, MushafPage>((ref, page) async {
  final repository = ref.watch(quranRepositoryProvider);
  final verses = <Verse>[];

  // Collect verses across potentially multiple chapters
  for (var ch = page.startChapterId; ch <= page.endChapterId; ch++) {
    final chapterVerses = await repository.getVerses(ch);
    for (final v in chapterVerses) {
      final vCh = v.chapterId;
      final vNum = v.verseNumber;

      bool include = false;
      if (page.startChapterId == page.endChapterId) {
        include = vCh == page.startChapterId &&
            vNum >= page.startVerseNumber &&
            vNum <= page.endVerseNumber;
      } else if (vCh == page.startChapterId) {
        include = vNum >= page.startVerseNumber;
      } else if (vCh == page.endChapterId) {
        include = vNum <= page.endVerseNumber;
      } else {
        include = vCh > page.startChapterId && vCh < page.endChapterId;
      }

      if (include) verses.add(v);
    }
  }

  return verses;
});

/// Returns the juz number for a given chapter:verse.
int getJuzForVerse(int chapterId, int verseNumber) {
  for (int i = juzBoundaries.length - 1; i >= 0; i--) {
    final juz = juzBoundaries[i];
    final juzCh = juz.chapterId;
    final juzV = juz.verseNumber;
    if (chapterId > juzCh || (chapterId == juzCh && verseNumber >= juzV)) {
      return juz.juz;
    }
  }
  return 1;
}

/// Arabic names for the 30 juz
const List<String> juzArabicNames = [
  'الجُزْءُ الأَوَّلُ',
  'الجُزْءُ الثَّانِي',
  'الجُزْءُ الثَّالِثُ',
  'الجُزْءُ الرَّابِعُ',
  'الجُزْءُ الخَامِسُ',
  'الجُزْءُ السَّادِسُ',
  'الجُزْءُ السَّابِعُ',
  'الجُزْءُ الثَّامِنُ',
  'الجُزْءُ التَّاسِعُ',
  'الجُزْءُ العَاشِرُ',
  'الجُزْءُ الحَادِي عَشَرَ',
  'الجُزْءُ الثَّانِي عَشَرَ',
  'الجُزْءُ الثَّالِثَ عَشَرَ',
  'الجُزْءُ الرَّابِعَ عَشَرَ',
  'الجُزْءُ الخَامِسَ عَشَرَ',
  'الجُزْءُ السَّادِسَ عَشَرَ',
  'الجُزْءُ السَّابِعَ عَشَرَ',
  'الجُزْءُ الثَّامِنَ عَشَرَ',
  'الجُزْءُ التَّاسِعَ عَشَرَ',
  'الجُزْءُ العِشْرُونَ',
  'الجُزْءُ الحَادِي وَالعِشْرُونَ',
  'الجُزْءُ الثَّانِي وَالعِشْرُونَ',
  'الجُزْءُ الثَّالِثُ وَالعِشْرُونَ',
  'الجُزْءُ الرَّابِعُ وَالعِشْرُونَ',
  'الجُزْءُ الخَامِسُ وَالعِشْرُونَ',
  'الجُزْءُ السَّادِسُ وَالعِشْرُونَ',
  'الجُزْءُ السَّابِعُ وَالعِشْرُونَ',
  'الجُزْءُ الثَّامِنُ وَالعِشْرُونَ',
  'الجُزْءُ التَّاسِعُ وَالعِشْرُونَ',
  'الجُزْءُ الثَّلاَثُونَ',
];
