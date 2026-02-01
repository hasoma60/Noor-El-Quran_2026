import 'package:equatable/equatable.dart';

class Bookmark extends Equatable {
  final String id;
  final String verseKey;
  final int chapterId;
  final String chapterName;
  final String text;
  final int timestamp;
  final String category;
  final String? note;

  const Bookmark({
    required this.id,
    required this.verseKey,
    required this.chapterId,
    required this.chapterName,
    required this.text,
    required this.timestamp,
    required this.category,
    this.note,
  });

  Bookmark copyWith({
    String? id,
    String? verseKey,
    int? chapterId,
    String? chapterName,
    String? text,
    int? timestamp,
    String? category,
    String? note,
  }) {
    return Bookmark(
      id: id ?? this.id,
      verseKey: verseKey ?? this.verseKey,
      chapterId: chapterId ?? this.chapterId,
      chapterName: chapterName ?? this.chapterName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, verseKey];
}
