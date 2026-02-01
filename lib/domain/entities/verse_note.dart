import 'package:equatable/equatable.dart';

class VerseNote extends Equatable {
  final String id;
  final String verseKey;
  final int chapterId;
  final String chapterName;
  final String verseText;
  final String note;
  final int createdAt;
  final int updatedAt;

  const VerseNote({
    required this.id,
    required this.verseKey,
    required this.chapterId,
    required this.chapterName,
    required this.verseText,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  VerseNote copyWith({
    String? note,
    int? updatedAt,
  }) {
    return VerseNote(
      id: id,
      verseKey: verseKey,
      chapterId: chapterId,
      chapterName: chapterName,
      verseText: verseText,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, verseKey];
}
