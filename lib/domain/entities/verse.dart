import 'package:equatable/equatable.dart';

class Verse extends Equatable {
  final int id;
  final String verseKey;
  final String textUthmani;
  final List<Translation>? translations;
  final List<Word>? words;

  const Verse({
    required this.id,
    required this.verseKey,
    required this.textUthmani,
    this.translations,
    this.words,
  });

  int get chapterId => int.parse(verseKey.split(':')[0]);
  int get verseNumber => int.parse(verseKey.split(':')[1]);

  @override
  List<Object?> get props => [id, verseKey];
}

class Translation extends Equatable {
  final int id;
  final int resourceId;
  final String text;

  const Translation({
    required this.id,
    required this.resourceId,
    required this.text,
  });

  @override
  List<Object?> get props => [id, resourceId];
}

class Word extends Equatable {
  final int id;
  final int position;
  final String textUthmani;
  final String translationText;
  final String transliterationText;

  const Word({
    required this.id,
    required this.position,
    required this.textUthmani,
    required this.translationText,
    required this.transliterationText,
  });

  @override
  List<Object?> get props => [id, position];
}
