import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/verse.dart';
import '../../home/providers/chapters_provider.dart';
import '../../settings/providers/settings_provider.dart';

final versesProvider = FutureProvider.family<List<Verse>, int>((ref, chapterId) async {
  final repository = ref.watch(quranRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  return repository.getVerses(
    chapterId,
    withWords: settings.showWordByWord,
    withTajweed: settings.showTajweed,
  );
});

final tafsirContentProvider = FutureProvider.family<String, ({int tafsirId, String verseKey})>((ref, params) async {
  final repository = ref.watch(quranRepositoryProvider);
  try {
    return await repository.getTafsirContent(params.tafsirId, params.verseKey);
  } catch (_) {
    return 'تعذر تحميل التفسير. يرجى التأكد من الاتصال بالإنترنت.';
  }
});
