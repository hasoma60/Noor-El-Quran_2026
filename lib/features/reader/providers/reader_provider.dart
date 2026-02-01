import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/verse.dart';
import '../../home/providers/chapters_provider.dart';

final versesProvider = FutureProvider.family<List<Verse>, int>((ref, chapterId) async {
  final dataSource = ref.watch(quranRemoteDataSourceProvider);
  return dataSource.fetchVerses(chapterId);
});

final tafsirContentProvider = FutureProvider.family<String, ({int tafsirId, String verseKey})>((ref, params) async {
  final dataSource = ref.watch(quranRemoteDataSourceProvider);
  try {
    return await dataSource.fetchTafsirContent(params.tafsirId, params.verseKey);
  } catch (_) {
    return 'تعذر تحميل التفسير. يرجى التأكد من الاتصال بالإنترنت.';
  }
});
