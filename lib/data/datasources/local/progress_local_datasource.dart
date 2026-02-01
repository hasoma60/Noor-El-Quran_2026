import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/reading_progress.dart';
import '../../../domain/entities/quran_statistic.dart';
import '../../../domain/entities/khatmah_plan.dart';

class ProgressLocalDataSource {
  final SharedPreferences _prefs;

  ProgressLocalDataSource(this._prefs);

  // ── Reading Progress ──

  Map<int, ReadingProgress> getProgress() {
    final json = _prefs.getString('readingProgress');
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((key, value) {
        final data = value as Map<String, dynamic>;
        return MapEntry(
          int.parse(key),
          ReadingProgress(
            chapterId: data['chapterId'] as int,
            lastVerseKey: data['lastVerseKey'] as String,
            lastReadAt: data['lastReadAt'] as int,
            versesRead: data['versesRead'] as int,
            totalVerses: data['totalVerses'] as int,
          ),
        );
      });
    } catch (_) {
      return {};
    }
  }

  Future<void> saveProgress(Map<int, ReadingProgress> progress) {
    final map = progress.map((key, value) => MapEntry(
          key.toString(),
          {
            'chapterId': value.chapterId,
            'lastVerseKey': value.lastVerseKey,
            'lastReadAt': value.lastReadAt,
            'versesRead': value.versesRead,
            'totalVerses': value.totalVerses,
          },
        ));
    return _prefs.setString('readingProgress', jsonEncode(map));
  }

  // ── Statistics ──

  QuranStatistic getStats() {
    final json = _prefs.getString('quranStats');
    if (json == null) return const QuranStatistic();
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return QuranStatistic(
        totalVersesRead: data['totalVersesRead'] as int? ?? 0,
        totalTimeSpent: data['totalTimeSpent'] as int? ?? 0,
        chaptersCompleted: data['chaptersCompleted'] as int? ?? 0,
        currentStreak: data['currentStreak'] as int? ?? 0,
        longestStreak: data['longestStreak'] as int? ?? 0,
        favoriteChapter: data['favoriteChapter'] as int?,
        lastReadDate: data['lastReadDate'] as String? ?? '',
      );
    } catch (_) {
      return const QuranStatistic();
    }
  }

  Future<void> saveStats(QuranStatistic stats) {
    return _prefs.setString(
        'quranStats',
        jsonEncode({
          'totalVersesRead': stats.totalVersesRead,
          'totalTimeSpent': stats.totalTimeSpent,
          'chaptersCompleted': stats.chaptersCompleted,
          'currentStreak': stats.currentStreak,
          'longestStreak': stats.longestStreak,
          'favoriteChapter': stats.favoriteChapter,
          'lastReadDate': stats.lastReadDate,
        }));
  }

  // ── Khatmah Plans ──

  List<KhatmahPlan> getKhatmahPlans() {
    final json = _prefs.getString('khatmahPlans');
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((p) {
        final data = p as Map<String, dynamic>;
        return KhatmahPlan(
          id: data['id'] as String,
          name: data['name'] as String,
          totalDays: data['totalDays'] as int,
          startDate: data['startDate'] as int,
          completedDays: (data['completedDays'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v as bool)),
          currentDay: data['currentDay'] as int,
          dailyTarget: (data['dailyTarget'] as List<dynamic>)
              .map((t) => DailyTarget(
                    fromVerse: (t as Map<String, dynamic>)['fromVerse'] as String,
                    toVerse: t['toVerse'] as String,
                  ))
              .toList(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveKhatmahPlans(List<KhatmahPlan> plans) {
    final list = plans
        .map((p) => {
              'id': p.id,
              'name': p.name,
              'totalDays': p.totalDays,
              'startDate': p.startDate,
              'completedDays': p.completedDays,
              'currentDay': p.currentDay,
              'dailyTarget': p.dailyTarget
                  .map((t) => {
                        'fromVerse': t.fromVerse,
                        'toVerse': t.toVerse,
                      })
                  .toList(),
            })
        .toList();
    return _prefs.setString('khatmahPlans', jsonEncode(list));
  }
}
