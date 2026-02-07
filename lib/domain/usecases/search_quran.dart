import '../../data/repositories/quran_repository.dart';
import '../entities/search_result.dart';

/// Use case wrapping search with offline/online strategy.
class SearchQuran {
  final QuranRepository _repository;

  SearchQuran(this._repository);

  Future<List<SearchResult>> call(String query) {
    return _repository.search(query);
  }
}
