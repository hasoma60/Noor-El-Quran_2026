import '../../domain/entities/search_result.dart';

class SearchResultModel extends SearchResult {
  const SearchResultModel({
    required super.verseKey,
    required super.text,
    super.translations,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      verseKey: json['verse_key'] as String,
      text: json['text'] as String? ?? '',
      translations: (json['translations'] as List<dynamic>?)
          ?.map((t) => (t as Map<String, dynamic>)['text'] as String? ?? '')
          .toList(),
    );
  }
}
