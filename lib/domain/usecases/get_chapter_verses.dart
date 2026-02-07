import '../../data/repositories/quran_repository.dart';
import '../entities/verse.dart';

/// Use case wrapping verse fetching with proper settings integration.
class GetChapterVerses {
  final QuranRepository _repository;

  GetChapterVerses(this._repository);

  Future<List<Verse>> call({
    required int chapterId,
    List<int> translationIds = const [16],
    bool withWords = false,
    bool withTajweed = false,
  }) {
    return _repository.getVerses(
      chapterId,
      translationIds: translationIds,
      withWords: withWords,
      withTajweed: withTajweed,
    );
  }
}
