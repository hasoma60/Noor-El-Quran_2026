import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/chapter.dart';
import '../../../domain/entities/bookmark.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../home/providers/bookmark_provider.dart';
import '../screens/mushaf_view.dart';

/// Starting page for each chapter in the standard Mushaf
const Map<int, int> chapterStartPages = {
  1: 1, 2: 2, 3: 50, 4: 77, 5: 106, 6: 128, 7: 151, 8: 177, 9: 187,
  10: 208, 11: 221, 12: 235, 13: 249, 14: 255, 15: 262, 16: 267,
  17: 282, 18: 293, 19: 305, 20: 312, 21: 322, 22: 332, 23: 342,
  24: 350, 25: 359, 26: 367, 27: 377, 28: 385, 29: 396, 30: 404,
  31: 411, 32: 415, 33: 418, 34: 428, 35: 434, 36: 440, 37: 446,
  38: 453, 39: 458, 40: 467, 41: 477, 42: 483, 43: 489, 44: 496,
  45: 499, 46: 502, 47: 507, 48: 511, 49: 515, 50: 518, 51: 520,
  52: 523, 53: 526, 54: 528, 55: 531, 56: 534, 57: 537, 58: 542,
  59: 545, 60: 549, 61: 551, 62: 553, 63: 554, 64: 556, 65: 558,
  66: 560, 67: 562, 68: 564, 69: 566, 70: 568, 71: 570, 72: 572,
  73: 574, 74: 575, 75: 577, 76: 578, 77: 580, 78: 582, 79: 583,
  80: 585, 81: 586, 82: 587, 83: 587, 84: 589, 85: 590, 86: 591,
  87: 591, 88: 592, 89: 593, 90: 594, 91: 595, 92: 595, 93: 596,
  94: 596, 95: 597, 96: 597, 97: 598, 98: 598, 99: 599, 100: 599,
  101: 600, 102: 600, 103: 601, 104: 601, 105: 601, 106: 602,
  107: 602, 108: 602, 109: 603, 110: 603, 111: 603, 112: 604,
  113: 604, 114: 604,
};

/// Starting page for each juz in the standard Mushaf
const Map<int, int> juzStartPages = {
  1: 1, 2: 22, 3: 42, 4: 62, 5: 82, 6: 102, 7: 121, 8: 142,
  9: 162, 10: 182, 11: 201, 12: 222, 13: 242, 14: 262, 15: 282,
  16: 302, 17: 322, 18: 342, 19: 362, 20: 382, 21: 402, 22: 422,
  23: 442, 24: 462, 25: 482, 26: 502, 27: 522, 28: 542, 29: 562,
  30: 582,
};

class MushafNavigationSheet extends ConsumerStatefulWidget {
  final int currentPage;
  final List<Chapter> chapters;
  final ValueChanged<int> onPageSelected;

  const MushafNavigationSheet({
    super.key,
    required this.currentPage,
    required this.chapters,
    required this.onPageSelected,
  });

  @override
  ConsumerState<MushafNavigationSheet> createState() =>
      _MushafNavigationSheetState();
}

class _MushafNavigationSheetState extends ConsumerState<MushafNavigationSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarks = ref.watch(bookmarkProvider).bookmarks;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              labelStyle: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 15,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xFFD97706).withValues(alpha: 0.15),
              ),
              labelColor: const Color(0xFFD97706),
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'فهرس السور'),
                Tab(text: 'فهرس الأجزاء'),
                Tab(text: 'العلامة المرجعية'),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SurahIndexTab(
                  chapters: widget.chapters,
                  currentPage: widget.currentPage,
                  onPageSelected: widget.onPageSelected,
                ),
                _JuzIndexTab(
                  currentPage: widget.currentPage,
                  onPageSelected: widget.onPageSelected,
                ),
                _BookmarksTab(
                  bookmarks: bookmarks,
                  onPageSelected: widget.onPageSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Surah index tab - list of all 114 surahs
class _SurahIndexTab extends StatelessWidget {
  final List<Chapter> chapters;
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  const _SurahIndexTab({
    required this.chapters,
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final startPage = chapterStartPages[chapter.id] ?? 1;
        final isCurrentSurah = _isOnChapter(chapter.id);

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onPageSelected(startPage),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // Bookmark icon for current surah
                if (isCurrentSurah)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Icon(
                      Icons.bookmark,
                      size: 20,
                      color: const Color(0xFFD97706),
                    ),
                  ),

                // Surah name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chapter.nameArabic,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isCurrentSurah
                              ? const Color(0xFFD97706)
                              : theme.colorScheme.onSurface,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'صفحة $startPage - عدد الآيات ${chapter.versesCount} - ${chapter.revelationPlace == "makkah" ? "مكية" : "مدنية"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Chapter number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrentSurah
                        ? const Color(0xFFD97706).withValues(alpha: 0.1)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    toArabicNumeral(chapter.id),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCurrentSurah
                          ? const Color(0xFFD97706)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isOnChapter(int chapterId) {
    final startPage = chapterStartPages[chapterId] ?? 1;
    final nextChapterId = chapterId + 1;
    final nextStartPage = nextChapterId <= 114
        ? (chapterStartPages[nextChapterId] ?? 605)
        : 605;
    return currentPage >= startPage && currentPage < nextStartPage;
  }
}

/// Juz index tab - list of all 30 juz
class _JuzIndexTab extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  const _JuzIndexTab({
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNum = index + 1;
        final startPage = juzStartPages[juzNum] ?? 1;
        final nextStartPage = juzNum < 30 ? (juzStartPages[juzNum + 1] ?? 605) : 605;
        final isCurrentJuz = currentPage >= startPage && currentPage < nextStartPage;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onPageSelected(startPage),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    juzArabicNames[index],
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      fontWeight: isCurrentJuz ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentJuz
                          ? const Color(0xFFD97706)
                          : theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bookmarks tab - list of saved bookmarks with navigation
class _BookmarksTab extends ConsumerWidget {
  final List<Bookmark> bookmarks;
  final ValueChanged<int> onPageSelected;

  const _BookmarksTab({
    required this.bookmarks,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mushafDs = ref.watch(mushafPageDataSourceProvider);

    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد علامات مرجعية',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'أضف آيات إلى المفضلة أثناء القراءة',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        final catColor = bookmarkCategoryColors[bookmark.category] ?? Colors.grey;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final page = await mushafDs.getPageForVerse(bookmark.verseKey);
            if (page != null) {
              onPageSelected(page);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // Bookmark icon with category color
                Icon(
                  Icons.bookmark,
                  size: 22,
                  color: catColor,
                ),
                const SizedBox(width: 10),

                // Bookmark info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${bookmark.chapterName} \u2022 ${bookmark.verseKey}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD97706),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bookmark.text,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          height: 1.6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
