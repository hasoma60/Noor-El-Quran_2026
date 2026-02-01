import 'package:equatable/equatable.dart';

class QuranStatistic extends Equatable {
  final int totalVersesRead;
  final int totalTimeSpent; // minutes
  final int chaptersCompleted;
  final int currentStreak;
  final int longestStreak;
  final int? favoriteChapter;
  final String lastReadDate;

  const QuranStatistic({
    this.totalVersesRead = 0,
    this.totalTimeSpent = 0,
    this.chaptersCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.favoriteChapter,
    this.lastReadDate = '',
  });

  QuranStatistic copyWith({
    int? totalVersesRead,
    int? totalTimeSpent,
    int? chaptersCompleted,
    int? currentStreak,
    int? longestStreak,
    int? favoriteChapter,
    String? lastReadDate,
  }) {
    return QuranStatistic(
      totalVersesRead: totalVersesRead ?? this.totalVersesRead,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      chaptersCompleted: chaptersCompleted ?? this.chaptersCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      favoriteChapter: favoriteChapter ?? this.favoriteChapter,
      lastReadDate: lastReadDate ?? this.lastReadDate,
    );
  }

  @override
  List<Object?> get props => [
        totalVersesRead,
        totalTimeSpent,
        chaptersCompleted,
        currentStreak,
        longestStreak,
        favoriteChapter,
        lastReadDate,
      ];
}
