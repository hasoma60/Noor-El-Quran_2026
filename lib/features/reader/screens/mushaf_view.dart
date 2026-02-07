import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local/mushaf_page_datasource.dart';
import '../../../domain/entities/chapter.dart';
import '../../home/providers/chapters_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/arabic_utils.dart';
import '../widgets/mushaf_navigation_sheet.dart';
import '../providers/mushaf_provider.dart';

class MushafPageView extends ConsumerStatefulWidget {
  final int initialPage;
  final ValueChanged<int>? onPageChanged;

  const MushafPageView({
    super.key,
    this.initialPage = 1,
    this.onPageChanged,
  });

  @override
  ConsumerState<MushafPageView> createState() => MushafPageViewState();
}

class MushafPageViewState extends ConsumerState<MushafPageView> {
  late PageController _pageController;
  int _currentPage = 1;

  int get currentPage => _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    // Reversed indexing: index 0 = page 604 (leftmost), index 603 = page 1 (rightmost)
    // This lets swipe L→R advance pages naturally (Arabic reading direction)
    _pageController = PageController(initialPage: 604 - widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void jumpToPage(int page) {
    if (page < 1 || page > 604) return;
    _pageController.jumpToPage(604 - page);
    setState(() => _currentPage = page);
  }

  void _showPageJumpDialog() {
    final controller = TextEditingController(text: '$_currentPage');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الانتقال إلى صفحة', textDirection: TextDirection.rtl),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(
            hintText: '١ - ٦٠٤',
            suffixText: '/ 604',
          ),
          autofocus: true,
          onSubmitted: (val) {
            final page = int.tryParse(val);
            if (page != null && page >= 1 && page <= 604) {
              jumpToPage(page);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= 604) {
                jumpToPage(page);
                Navigator.pop(context);
              }
            },
            child: const Text('انتقال'),
          ),
        ],
      ),
    );
  }

  void _showNavigationSheet() {
    final chapters = ref.read(chaptersProvider).whenOrNull(data: (c) => c) ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MushafNavigationSheet(
        currentPage: _currentPage,
        chapters: chapters,
        onPageSelected: (page) {
          jumpToPage(page);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(mushafPagesProvider);
    final chaptersAsync = ref.watch(chaptersProvider);
    final theme = Theme.of(context);

    return pagesAsync.when(
      data: (pages) {
        if (pages.isEmpty) {
          return const Center(child: Text('لم يتم تحميل بيانات الصفحات'));
        }

        final chapters = chaptersAsync.whenOrNull(data: (c) => c) ?? <Chapter>[];

        // Determine current page surah and juz for the header
        final currentPageData = (_currentPage >= 1 && _currentPage <= pages.length)
            ? pages[_currentPage - 1]
            : null;
        final currentSurahName = currentPageData != null
            ? _getSurahNameForPage(currentPageData, chapters)
            : '';
        final currentJuz = currentPageData != null
            ? getJuzForVerse(
                currentPageData.startChapterId,
                currentPageData.startVerseNumber,
              )
            : 1;

        return Column(
          children: [
            // Page header: surah name + juz
            _MushafPageHeader(
              surahName: currentSurahName,
              juzNumber: currentJuz,
              onNavigationTap: _showNavigationSheet,
            ),

            // The mushaf page content
            Expanded(
              child: Stack(
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: PageView.builder(
                    controller: _pageController,
                    itemCount: 604,
                    // Override global RTL: index 0=page 604 (left), index 603=page 1 (right)
                    // In LTR mode, swipe L→R decreases index = higher page = next page
                    onPageChanged: (index) {
                      final page = 604 - index;
                      setState(() => _currentPage = page);
                      widget.onPageChanged?.call(page);
                    },
                    itemBuilder: (context, index) {
                      final pageNumber = 604 - index;
                      if (pageNumber < 1 || pageNumber > pages.length) {
                        return const SizedBox.shrink();
                      }
                      final page = pages[pageNumber - 1];
                      return _MushafPageContent(
                        page: page,
                        pageNumber: pageNumber,
                      );
                    },
                  ),
                  ),
                  // Page number indicator at bottom
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _showPageJumpDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            toArabicNumeral(_currentPage),
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('خطأ: $error')),
    );
  }

  String _getSurahNameForPage(MushafPage page, List<Chapter> chapters) {
    final ch = chapters.where((c) => c.id == page.startChapterId).firstOrNull;
    return ch?.nameArabic ?? '';
  }
}

/// Header bar showing surah name and juz number (like traditional mushaf)
class _MushafPageHeader extends StatelessWidget {
  final String surahName;
  final int juzNumber;
  final VoidCallback onNavigationTap;

  const _MushafPageHeader({
    required this.surahName,
    required this.juzNumber,
    required this.onNavigationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final juzName = (juzNumber >= 1 && juzNumber <= 30)
        ? juzArabicNames[juzNumber - 1]
        : 'الجزء ${toArabicNumeral(juzNumber)}';

    return GestureDetector(
      onTap: onNavigationTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            // Surah name (left side in screen = right in RTL context)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  surahName,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Juz name (right side in screen)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  juzName,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MushafPageContent extends ConsumerWidget {
  final MushafPage page;
  final int pageNumber;

  const _MushafPageContent({
    required this.page,
    required this.pageNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versesAsync = ref.watch(mushafPageVersesProvider(page));
    final settings = ref.watch(settingsProvider);
    final chaptersAsync = ref.watch(chaptersProvider);
    final theme = Theme.of(context);

    return versesAsync.when(
      data: (verses) {
        if (verses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Determine which chapters start on this page
        final chapters = chaptersAsync.whenOrNull(
              data: (chs) => chs,
            ) ??
            <Chapter>[];
        final chapterStarts = <int, Chapter>{};
        for (final v in verses) {
          if (v.verseNumber == 1) {
            final ch = chapters
                .where((c) => c.id == v.chapterId)
                .firstOrNull;
            if (ch != null) chapterStarts[v.chapterId] = ch;
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Build verse text with chapter headers inline
                ...verses.map((verse) {
                  final widgets = <Widget>[];

                  // Add chapter header if this verse starts a chapter
                  if (chapterStarts.containsKey(verse.chapterId) &&
                      verse.verseNumber == 1) {
                    final ch = chapterStarts[verse.chapterId]!;
                    widgets.add(Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Text(
                            ch.nameArabic,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (ch.bismillahPre && ch.id != 9)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                                style: TextStyle(
                                  fontFamily: settings.quranFont,
                                  fontSize: 18,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Divider(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ));
                  }

                  return Column(children: widgets);
                }),

                // All verses as continuous text (mushaf style)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text.rich(
                    TextSpan(
                      children: verses.expand((verse) {
                        return [
                          TextSpan(
                            text: verse.textUthmani,
                            style: TextStyle(
                              fontFamily: settings.quranFont,
                              fontSize: settings.fontSize.toDouble(),
                              height: 2.0,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' \uFD3F${toArabicNumeral(verse.verseNumber)}\uFD3E ',
                            style: TextStyle(
                              fontFamily: settings.quranFont,
                              fontSize: settings.fontSize.toDouble() * 0.7,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ];
                      }).toList(),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const Center(child: Text('خطأ في تحميل الصفحة')),
    );
  }
}
