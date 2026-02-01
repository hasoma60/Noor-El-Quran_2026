import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  final String verseKey;
  final String text;
  final List<String>? translations;

  const SearchResult({
    required this.verseKey,
    required this.text,
    this.translations,
  });

  int get chapterId => int.parse(verseKey.split(':')[0]);
  int get verseNumber => int.parse(verseKey.split(':')[1]);

  @override
  List<Object?> get props => [verseKey];
}
