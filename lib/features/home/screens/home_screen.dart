import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chapters_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/search_provider.dart';
import '../../../domain/entities/search_result.dart';
import '../widgets/daily_verse_card.dart';
import '../widgets/continue_reading_card.dart';
import '../widgets/chapter_skeleton.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../settings/providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _submittedQuery = '';
  static bool _startupResumeHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleStartupResume());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleStartupResume() async {
    if (!mounted || _startupResumeHandled) return;
    _startupResumeHandled = true;

    final settings = ref.read(settingsProvider);
    if (!settings.autoResumeLastAyah) return;

    final session = ref.read(progressProvider.notifier).getLastReaderSession();
    if (session == null) return;

    if (settings.readingViewMode != session.viewMode) {
      ref.read(settingsProvider.notifier).setReadingViewMode(session.viewMode);
    }

    context.pushNamed(
      'reader',
      pathParameters: {'chapterId': session.chapterId.toString()},
      queryParameters: {
        'verse': session.verseKey,
        if (session.mushafPage != null) 'page': session.mushafPage.toString(),
        'mode': session.viewMode,
      },
    );
  }

  void _submitSearch([String? query]) {
    final value = (query ?? _searchController.text).trim();
    if (value.isEmpty) {
      setState(() => _submittedQuery = '');
      return;
    }
    setState(() => _submittedQuery = value);
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('نور القرآن'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'الإحصائيات',
            onPressed: () => context.pushNamed('stats'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (route) => context.pushNamed(route),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'juz', child: Text('فهرس الأجزاء')),
              PopupMenuItem(value: 'khatmah', child: Text('خطة الختمة')),
              PopupMenuItem(value: 'notes', child: Text('الملاحظات')),
              PopupMenuItem(
                  value: 'memorization', child: Text('المراجعة والحفظ')),
              PopupMenuItem(value: 'thematic', child: Text('الفهرس الموضوعي')),
            ],
          ),
        ],
      ),
      body: chaptersAsync.when(
        data: (chapters) {
          final searchAsync = _submittedQuery.isNotEmpty
              ? ref.watch(quranSearchProvider(_submittedQuery))
              : null;

          final chapterNameById = {
            for (final c in chapters) c.id: c.nameArabic,
          };

          return CustomScrollView(
            slivers: [
              if (_submittedQuery.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      children: [
                        DailyVerseCard(),
                        SizedBox(height: 12),
                        ContinueReadingCard(),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'ابحث في القرآن (ثم اضغط Enter)...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _submittedQuery = '');
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_rounded),
                            tooltip: 'بحث',
                            onPressed: () => _submitSearch(),
                          ),
                        ],
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: _submitSearch,
                  ),
                ),
              ),
              if (_submittedQuery.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text(
                      'نتائج البحث: "$_submittedQuery"',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
              if (_submittedQuery.isNotEmpty)
                ..._buildSearchSlivers(searchAsync!, chapterNameById, context)
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chapter = chapters[index];
                      return _ChapterTile(chapter: chapter);
                    },
                    childCount: chapters.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
        loading: () => const ChapterListSkeleton(),
        error: (error, _) => AppErrorWidget(
          message: 'تعذر تحميل السور',
          onRetry: () => ref.invalidate(chaptersProvider),
        ),
      ),
    );
  }

  List<Widget> _buildSearchSlivers(
    AsyncValue<List<SearchResult>> searchAsync,
    Map<int, String> chapterNameById,
    BuildContext context,
  ) {
    return searchAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return const [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('لا توجد نتائج لهذا البحث')),
            ),
          ];
        }

        return [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final result = results[index];
                final chapterName = chapterNameById[result.chapterId] ??
                    'سورة ${toArabicNumeral(result.chapterId)}';
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.pushNamed(
                          'reader',
                          pathParameters: {
                            'chapterId': result.chapterId.toString()
                          },
                          queryParameters: {'verse': result.verseKey},
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '$chapterName - آية ${toArabicNumeral(result.verseNumber)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD97706),
                              ),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              result.text,
                              style: const TextStyle(
                                fontFamily: 'Scheherazade New',
                                fontSize: 24,
                                height: 1.9,
                              ),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: results.length,
            ),
          ),
        ];
      },
      loading: () => const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
      error: (error, _) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'تعذر تنفيذ البحث. حاول مرة أخرى.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChapterTile extends ConsumerWidget {
  final dynamic chapter;

  const _ChapterTile({required this.chapter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressState = ref.watch(progressProvider);
    final progress = progressState.progress[chapter.id];
    final progressPercent = progress != null
        ? (progress.versesRead / progress.totalVerses * 100).round()
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            context.pushNamed(
              'reader',
              pathParameters: {'chapterId': chapter.id.toString()},
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (progressPercent > 0)
                        CircularProgressIndicator(
                          value: progressPercent / 100,
                          strokeWidth: 2.5,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            progressPercent >= 100
                                ? Colors.green
                                : const Color(0xFFD97706),
                          ),
                        ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: progressPercent >= 100
                              ? Colors.green.withValues(alpha: 0.1)
                              : progressPercent > 0
                                  ? Colors.amber.withValues(alpha: 0.1)
                                  : theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          toArabicNumeral(chapter.id),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: progressPercent >= 100
                                ? Colors.green[700]
                                : progressPercent > 0
                                    ? Colors.amber[800]
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.nameArabic,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            chapter.revelationPlace == 'makkah'
                                ? 'مكية'
                                : 'مدنية',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          if (progressPercent > 0 && progressPercent < 100) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$progressPercent%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${toArabicNumeral(chapter.versesCount)} آية',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    if (progressPercent >= 100)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 14, color: Colors.green[600]),
                          const SizedBox(width: 2),
                          Text(
                            'مكتملة',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[600],
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
