import '../../domain/entities/verse.dart';

class VerseModel extends Verse {
  const VerseModel({
    required super.id,
    required super.verseKey,
    required super.textUthmani,
    super.translations,
    super.words,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      id: json['id'] as int,
      verseKey: json['verse_key'] as String,
      textUthmani: json['text_uthmani'] as String? ?? '',
      translations: (json['translations'] as List<dynamic>?)
          ?.map((t) => TranslationModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      words: (json['words'] as List<dynamic>?)
          ?.map((w) => WordModel.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verse_key': verseKey,
      'text_uthmani': textUthmani,
      if (translations != null)
        'translations': translations!
            .map((t) => {
                  'id': t.id,
                  'resource_id': t.resourceId,
                  'text': t.text,
                })
            .toList(),
      if (words != null)
        'words': words!
            .map((w) => {
                  'id': w.id,
                  'position': w.position,
                  'text_uthmani': w.textUthmani,
                  'translation': {'text': w.translationText},
                  'transliteration': {'text': w.transliterationText},
                })
            .toList(),
    };
  }
}

class TranslationModel extends Translation {
  const TranslationModel({
    required super.id,
    required super.resourceId,
    required super.text,
  });

  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      id: json['id'] as int? ?? 0,
      resourceId: json['resource_id'] as int? ?? 0,
      text: json['text'] as String? ?? '',
    );
  }
}

class WordModel extends Word {
  const WordModel({
    required super.id,
    required super.position,
    required super.textUthmani,
    required super.translationText,
    required super.transliterationText,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] as int? ?? 0,
      position: json['position'] as int? ?? 0,
      textUthmani: json['text_uthmani'] as String? ?? '',
      translationText: (json['translation'] as Map<String, dynamic>?)?['text'] as String? ?? '',
      transliterationText: (json['transliteration'] as Map<String, dynamic>?)?['text'] as String? ?? '',
    );
  }
}
