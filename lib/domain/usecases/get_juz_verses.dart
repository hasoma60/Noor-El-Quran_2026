import '../../data/repositories/quran_repository.dart';
import '../entities/verse.dart';

/// Use case wrapping juz verse fetching.
class GetJuzVerses {
  final QuranRepository _repository;

  GetJuzVerses(this._repository);

  Future<List<Verse>> call(int juzNumber) {
    return _repository.getJuzVerses(juzNumber);
  }
}
