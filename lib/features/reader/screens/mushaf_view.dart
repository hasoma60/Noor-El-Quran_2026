import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local/mushaf_page_datasource.dart';
import '../../../domain/entities/verse.dart';
import '../../../domain/entities/chapter.dart';
import '../../home/providers/chapters_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/arabic_utils.dart';

final mushafPageDataSourceProvider = Provider<MushafPageDataSource>((ref) {
  return MushafPageDataSource();
});

final mushafPagesProvider = FutureProvider<List<MushafPage>>((ref) async {
  final dataSource = ref.watch(mushafPageDataSourceProvider);
  return dataSource.getAllPages();
});

/// Fetches verses for a specific mushaf page.
final mushafPageVersesProvider =
    FutureProvider.family<List<Verse>, MushafPage>((ref, page) async {
  final repository = ref.watch(quranRepositoryProvider);
  final verses = <Verse>[];

  // Collect verses across potentially multiple chapters
  for (var ch = page.startChapterId; ch <= page.endChapterId; ch++) {
    final chapterVerses = await repository.getVerses(ch);
    for (final v in chapterVerses) {
      final vCh = v.chapterId;
      final vNum = v.verseNumber;

      bool include = false;
      if (page.startChapterId == page.endChapterId) {
        include = vCh == page.startChapterId &&
            vNum >= page.startVerseNumber &&
            vNum <= page.endVerseNumber;
      } else if (vCh == page.startChapterId) {
        include = vNum >= page.startVerseNumber;
      } else if (vCh == page.endChapterId) {
        include = vNum <= page.endVerseNumber;
      } else {
        include = vCh > page.startChapterId && vCh < page.endChapterId;
      }

      if (include) verses.add(v);
    }
  }

  return verses;
});

class MushafPageView extends ConsumerStatefulWidget {
  final int initialPage;

  const MushafPageView({super.key, this.initialPage = 1});

  @override
  ConsumerState<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends ConsumerState<MushafPageView> {
  late PageController _pageController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    // Reverse index: page 1 is at index 603 (RTL reading)
    _pageController = PageController(initialPage: 604 - widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _jumpToPage(int page) {
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
          decoration: InputDecoration(
            hintText: '١ - ٦٠٤',
            suffixText: '/ 604',
          ),
          autofocus: true,
          onSubmitted: (val) {
            final page = int.tryParse(val);
            if (page != null) {
              _jumpToPage(page);
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
              if (page != null) {
                _jumpToPage(page);
                Navigator.pop(context);
              }
            },
            child: const Text('انتقال'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(mushafPagesProvider);
    final theme = Theme.of(context);

    return pagesAsync.when(
      data: (pages) {
        if (pages.isEmpty) {
          return const Center(child: Text('لم يتم تحميل بيانات الصفحات'));
        }

        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: 604,
              reverse: false, // We handle RTL via index math
              onPageChanged: (index) {
                setState(() => _currentPage = 604 - index);
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
                      'صفحة ${toArabicNumeral(_currentPage)}',
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('خطأ: $error')),
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
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD97706),
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
      error: (error, _) => Center(child: Text('خطأ في تحميل الصفحة')),
    );
  }
}
