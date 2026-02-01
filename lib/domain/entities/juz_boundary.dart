import 'package:equatable/equatable.dart';

class JuzBoundary extends Equatable {
  final int juz;
  final String verseKey;
  final String name;

  const JuzBoundary({
    required this.juz,
    required this.verseKey,
    required this.name,
  });

  int get chapterId => int.parse(verseKey.split(':')[0]);
  int get verseNumber => int.parse(verseKey.split(':')[1]);

  @override
  List<Object?> get props => [juz];
}
