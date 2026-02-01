import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chapters_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/daily_verse_card.dart';
import '../widgets/continue_reading_card.dart';
import '../widgets/chapter_skeleton.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/utils/arabic_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _searchQuery = value);
    });
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
              PopupMenuItem(value: 'memorization', child: Text('المراجعة والحفظ')),
              PopupMenuItem(value: 'thematic', child: Text('الفهرس الموضوعي')),
            ],
          ),
        ],
      ),
      body: chaptersAsync.when(
        data: (chapters) {
          final filtered = _searchQuery.isEmpty
              ? chapters
              : chapters.where((c) =>
                  c.nameArabic.contains(_searchQuery) ||
                  c.nameSimple.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  c.id.toString() == _searchQuery).toList();

          return CustomScrollView(
            slivers: [
              // Daily verse + Continue reading (only when not searching)
              if (_searchQuery.isEmpty)
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

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن سورة...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),

              // Chapter count
              if (_searchQuery.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text(
                      'السور (${filtered.length})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),

              // Chapter list
              if (filtered.isEmpty && _searchQuery.isNotEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('لا توجد نتائج')),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chapter = filtered[index];
                      return _ChapterTile(chapter: chapter);
                    },
                    childCount: filtered.length,
                  ),
                ),

              // Bottom padding
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
                // Chapter number with progress ring
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
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
                                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Chapter info
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
                            chapter.revelationPlace == 'makkah' ? 'مكية' : 'مدنية',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          if (progressPercent > 0 && progressPercent < 100) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$progressPercent%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Verse count + completion badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${toArabicNumeral(chapter.versesCount)} آية',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    if (progressPercent >= 100)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green[600]),
                          const SizedBox(width: 2),
                          Text(
                            'مكتملة',
                            style: TextStyle(fontSize: 10, color: Colors.green[600], fontWeight: FontWeight.w600),
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
