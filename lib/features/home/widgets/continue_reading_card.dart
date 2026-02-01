import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/progress_provider.dart';
import '../providers/chapters_provider.dart';
import '../../../core/utils/arabic_utils.dart';

class ContinueReadingCard extends ConsumerWidget {
  const ContinueReadingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(progressProvider);
    final chaptersAsync = ref.watch(chaptersProvider);
    final theme = Theme.of(context);

    final notifier = ref.read(progressProvider.notifier);
    final lastRead = notifier.getLastReadChapter();
    if (lastRead == null) return const SizedBox.shrink();

    return chaptersAsync.when(
      data: (chapters) {
        final chapter = chapters.where((c) => c.id == lastRead.chapterId).firstOrNull;
        if (chapter == null) return const SizedBox.shrink();

        final progressPercent = (lastRead.versesRead / lastRead.totalVerses * 100).round();

        return GestureDetector(
          onTap: () {
            context.pushNamed(
              'reader',
              pathParameters: {'chapterId': lastRead.chapterId.toString()},
              queryParameters: {'verse': lastRead.lastVerseKey},
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'متابعة القراءة',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${chapter.nameArabic} \u2022 آية ${toArabicNumeral(int.parse(lastRead.lastVerseKey.split(':')[1]))}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress bar
                SizedBox(
                  width: 48,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: lastRead.versesRead / lastRead.totalVerses,
                          backgroundColor: Colors.amber.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFFD97706)),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$progressPercent%',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.amber[600]),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
