import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/services/app_logger.dart';

class MushafPage {
  final int page;
  final String startVerseKey;
  final String endVerseKey;

  const MushafPage({
    required this.page,
    required this.startVerseKey,
    required this.endVerseKey,
  });

  int get startChapterId => int.parse(startVerseKey.split(':')[0]);
  int get startVerseNumber => int.parse(startVerseKey.split(':')[1]);
  int get endChapterId => int.parse(endVerseKey.split(':')[0]);
  int get endVerseNumber => int.parse(endVerseKey.split(':')[1]);
}

/// Loads mushaf page mapping data from bundled JSON.
class MushafPageDataSource {
  static const _log = AppLogger('MushafPageDS');
  List<MushafPage>? _pages;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  int get totalPages => _pages?.length ?? 604;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/quran_pages.json');
      final data = jsonDecode(jsonString) as List<dynamic>;
      _pages = data.map((p) {
        final page = p as Map<String, dynamic>;
        return MushafPage(
          page: page['page'] as int,
          startVerseKey: page['start'] as String,
          endVerseKey: page['end'] as String,
        );
      }).toList();
      _initialized = true;
    } catch (e, st) {
      _log.error('Failed to initialize mushaf page data', e, st);
      _initialized = false;
    }
  }

  /// Get page mapping by page number (1-604).
  Future<MushafPage?> getPage(int pageNumber) async {
    if (!_initialized) await initialize();
    if (_pages == null || pageNumber < 1 || pageNumber > _pages!.length) {
      return null;
    }
    return _pages![pageNumber - 1];
  }

  /// Get all pages.
  Future<List<MushafPage>> getAllPages() async {
    if (!_initialized) await initialize();
    return _pages ?? [];
  }

  /// Find which page a verse belongs to.
  Future<int?> getPageForVerse(String verseKey) async {
    if (!_initialized) await initialize();
    if (_pages == null) return null;

    final parts = verseKey.split(':');
    if (parts.length != 2) return null;
    final chapterId = int.tryParse(parts[0]);
    final verseNum = int.tryParse(parts[1]);
    if (chapterId == null || verseNum == null) return null;

    for (final page in _pages!) {
      final startCh = page.startChapterId;
      final startV = page.startVerseNumber;
      final endCh = page.endChapterId;
      final endV = page.endVerseNumber;

      // Check if verse falls within this page's range
      if (startCh == endCh) {
        // Page stays within one chapter
        if (chapterId == startCh && verseNum >= startV && verseNum <= endV) {
          return page.page;
        }
      } else {
        // Page spans multiple chapters
        if (chapterId == startCh && verseNum >= startV) return page.page;
        if (chapterId == endCh && verseNum <= endV) return page.page;
        if (chapterId > startCh && chapterId < endCh) return page.page;
      }
    }
    return null;
  }
}
