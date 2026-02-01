import 'package:equatable/equatable.dart';

class ReciterInfo extends Equatable {
  final int id;
  final int chapterRecitationId;
  final int verseRecitationId;
  final String name;
  final String nameArabic;
  final String? style;

  const ReciterInfo({
    required this.id,
    required this.chapterRecitationId,
    required this.verseRecitationId,
    required this.name,
    required this.nameArabic,
    this.style,
  });

  bool get hasVerseRecitation => verseRecitationId > 0;

  @override
  List<Object?> get props => [id];
}
