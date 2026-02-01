import 'package:equatable/equatable.dart';

class ReadingProgress extends Equatable {
  final int chapterId;
  final String lastVerseKey;
  final int lastReadAt;
  final int versesRead;
  final int totalVerses;

  const ReadingProgress({
    required this.chapterId,
    required this.lastVerseKey,
    required this.lastReadAt,
    required this.versesRead,
    required this.totalVerses,
  });

  double get progressPercent =>
      totalVerses > 0 ? (versesRead / totalVerses).clamp(0.0, 1.0) : 0.0;

  ReadingProgress copyWith({
    String? lastVerseKey,
    int? lastReadAt,
    int? versesRead,
    int? totalVerses,
  }) {
    return ReadingProgress(
      chapterId: chapterId,
      lastVerseKey: lastVerseKey ?? this.lastVerseKey,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      versesRead: versesRead ?? this.versesRead,
      totalVerses: totalVerses ?? this.totalVerses,
    );
  }

  @override
  List<Object?> get props => [chapterId];
}
