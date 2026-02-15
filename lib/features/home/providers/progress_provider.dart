import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local/progress_local_datasource.dart';
import '../../../domain/entities/reading_progress.dart';
import '../../../domain/entities/quran_statistic.dart';
import '../../../domain/entities/khatmah_plan.dart';
import '../../../domain/entities/reader_session.dart';
import '../../settings/providers/settings_provider.dart';

final progressLocalDataSourceProvider =
    Provider<ProgressLocalDataSource>((ref) {
  return ProgressLocalDataSource(ref.watch(sharedPreferencesProvider));
});

class ProgressState {
  final Map<int, ReadingProgress> progress;
  final QuranStatistic stats;
  final List<KhatmahPlan> khatmahPlans;
  final ReaderSession? readerSession;

  const ProgressState({
    this.progress = const {},
    this.stats = const QuranStatistic(),
    this.khatmahPlans = const [],
    this.readerSession,
  });

  ProgressState copyWith({
    Map<int, ReadingProgress>? progress,
    QuranStatistic? stats,
    List<KhatmahPlan>? khatmahPlans,
    ReaderSession? readerSession,
    bool clearReaderSession = false,
  }) {
    return ProgressState(
      progress: progress ?? this.progress,
      stats: stats ?? this.stats,
      khatmahPlans: khatmahPlans ?? this.khatmahPlans,
      readerSession:
          clearReaderSession ? null : (readerSession ?? this.readerSession),
    );
  }
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  final ProgressLocalDataSource _dataSource;

  ProgressNotifier(this._dataSource)
      : super(ProgressState(
          progress: _dataSource.getProgress(),
          stats: _dataSource.getStats(),
          khatmahPlans: _dataSource.getKhatmahPlans(),
          readerSession: _dataSource.getReaderSession(),
        ));

  void updateProgress(int chapterId, String verseKey, int totalVerses) {
    final existing = state.progress[chapterId];
    final verseNum = int.tryParse(verseKey.split(':').last) ?? 0;
    final currentRead = existing?.versesRead ?? 0;
    final newRead = verseNum > currentRead ? verseNum : currentRead;

    final updated = ReadingProgress(
      chapterId: chapterId,
      lastVerseKey: verseKey,
      lastReadAt: DateTime.now().millisecondsSinceEpoch,
      versesRead: newRead,
      totalVerses: totalVerses,
    );

    final newProgress = Map<int, ReadingProgress>.from(state.progress);
    newProgress[chapterId] = updated;

    // Update stats
    var newStats = state.stats;
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (newStats.lastReadDate != today) {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .split('T')[0];
      final newStreak =
          newStats.lastReadDate == yesterday ? newStats.currentStreak + 1 : 1;
      newStats = newStats.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > newStats.longestStreak ? newStreak : null,
        lastReadDate: today,
      );
    }

    // Count completed chapters
    final completed =
        newProgress.values.where((p) => p.versesRead >= p.totalVerses).length;
    final totalRead =
        newProgress.values.fold<int>(0, (sum, p) => sum + p.versesRead);
    newStats = newStats.copyWith(
      chaptersCompleted: completed,
      totalVersesRead: totalRead,
    );

    state = state.copyWith(progress: newProgress, stats: newStats);
    _dataSource.saveProgress(newProgress);
    _dataSource.saveStats(newStats);
  }

  ReadingProgress? getChapterProgress(int chapterId) =>
      state.progress[chapterId];

  ReadingProgress? getLastReadChapter() {
    if (state.progress.isEmpty) return null;
    return state.progress.values
        .reduce((a, b) => a.lastReadAt > b.lastReadAt ? a : b);
  }

  ReaderSession? getLastReaderSession() {
    final session = state.readerSession;
    if (session != null) return session;
    final lastProgress = getLastReadChapter();
    if (lastProgress == null) return null;
    return ReaderSession(
      chapterId: lastProgress.chapterId,
      verseKey: lastProgress.lastVerseKey,
      mushafPage: null,
      viewMode: 'flowing',
      timestamp: lastProgress.lastReadAt,
    );
  }

  void updateReaderSession({
    required int chapterId,
    required String verseKey,
    required String viewMode,
    int? mushafPage,
  }) {
    final session = ReaderSession(
      chapterId: chapterId,
      verseKey: verseKey,
      mushafPage: mushafPage,
      viewMode: viewMode,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    state = state.copyWith(readerSession: session);
    _dataSource.saveReaderSession(session);
  }

  double getOverallProgress() {
    if (state.progress.isEmpty) return 0;
    final total =
        state.progress.values.fold<int>(0, (s, p) => s + p.versesRead);
    return (total / 6236).clamp(0.0, 1.0);
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  return ProgressNotifier(ref.watch(progressLocalDataSourceProvider));
});
