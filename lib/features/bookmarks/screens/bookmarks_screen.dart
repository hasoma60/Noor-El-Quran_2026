import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home/providers/bookmark_provider.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final bookmarkState = ref.watch(bookmarkProvider);
    final notifier = ref.read(bookmarkProvider.notifier);
    final theme = Theme.of(context);

    final allBookmarks = _selectedCategory == 'all'
        ? bookmarkState.bookmarks
        : notifier.getBookmarksByCategory(_selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'الكل',
                  selected: _selectedCategory == 'all',
                  count: bookmarkState.bookmarks.length,
                  onTap: () => setState(() => _selectedCategory = 'all'),
                ),
                const SizedBox(width: 8),
                ...bookmarkCategories.map((cat) {
                  final count = notifier.getBookmarksByCategory(cat.id).length;
                  final color = bookmarkCategoryColors[cat.id] ?? Colors.grey;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: _FilterChip(
                      label: cat.label,
                      selected: _selectedCategory == cat.id,
                      count: count,
                      color: color,
                      onTap: () => setState(() => _selectedCategory = cat.id),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Bookmarks list
          Expanded(
            child: allBookmarks.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.bookmark_outline,
                    title: 'لا توجد مفضلات',
                    description: 'أضف آيات إلى المفضلة أثناء القراءة',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: allBookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = allBookmarks[index];
                      final catColor = bookmarkCategoryColors[bookmark.category] ?? Colors.grey;

                      return Dismissible(
                        key: Key(bookmark.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 24),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('حذف الإشارة'),
                              content: const Text('هل تريد حذف هذه الإشارة المرجعية؟'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
                              ],
                            ),
                          ) ?? false;
                        },
                        onDismissed: (_) => notifier.deleteBookmark(bookmark.id),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              context.pushNamed(
                                'reader',
                                pathParameters: {'chapterId': bookmark.chapterId.toString()},
                                queryParameters: {'verse': bookmark.verseKey},
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: catColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${bookmark.chapterName} \u2022 ${bookmark.verseKey}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber[700],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        relativeTimeArabic(bookmark.timestamp),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    bookmark.text,
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 16,
                                      height: 1.8,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final int count;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.count,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (color ?? const Color(0xFFD97706)).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? (color ?? const Color(0xFFD97706)).withValues(alpha: 0.4)
                : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? (color ?? const Color(0xFFD97706)) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
