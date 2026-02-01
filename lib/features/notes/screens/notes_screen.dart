import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home/providers/bookmark_provider.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkState = ref.watch(bookmarkProvider);
    final notifier = ref.read(bookmarkProvider.notifier);
    final notes = bookmarkState.notes;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملاحظات'),
      ),
      body: notes.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.note_alt_outlined,
              title: 'لا توجد ملاحظات',
              description: 'أضف ملاحظات على الآيات أثناء القراءة',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];

                return Dismissible(
                  key: Key(note.id),
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
                        title: const Text('حذف الملاحظة'),
                        content: const Text('هل تريد حذف هذه الملاحظة؟'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) => notifier.deleteNote(note.id),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.pushNamed(
                          'reader',
                          pathParameters: {'chapterId': note.chapterId.toString()},
                          queryParameters: {'verse': note.verseKey},
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.note_alt, size: 16, color: Colors.amber[700]),
                                const SizedBox(width: 6),
                                Text(
                                  '${note.chapterName} \u2022 ${note.verseKey}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber[700],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  relativeTimeArabic(note.updatedAt),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              note.verseText,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 15,
                                height: 1.8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                note.note,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
