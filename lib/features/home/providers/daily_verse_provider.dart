import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/chapter.dart';
import '../../../domain/entities/verse.dart';
import 'chapters_provider.dart';

class DailyVerseData {
  final Verse verse;
  final Chapter chapter;

  const DailyVerseData({required this.verse, required this.chapter});
}

final dailyVerseProvider = FutureProvider<DailyVerseData?>((ref) async {
  final repository = ref.watch(quranRepositoryProvider);

  try {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 0)).inDays;
    final verseIndex = (dayOfYear * 17 + now.year) % 6236;

    final chapters = await ref.watch(chaptersProvider.future);
    var accumulated = 0;

    for (final ch in chapters) {
      if (accumulated + ch.versesCount > verseIndex) {
        final verseNum = verseIndex - accumulated + 1;
        final verseKey = '${ch.id}:$verseNum';
        final verse = await repository.getVerseByKey(verseKey);
        return DailyVerseData(verse: verse, chapter: ch);
      }
      accumulated += ch.versesCount;
    }
    return null;
  } catch (_) {
    return null;
  }
});
