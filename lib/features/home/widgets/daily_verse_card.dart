import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/daily_verse_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/utils/html_sanitizer.dart';

class DailyVerseCard extends ConsumerWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyVerse = ref.watch(dailyVerseProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return dailyVerse.when(
      data: (data) {
        if (data == null) return const SizedBox.shrink();

        final verse = data.verse;
        final chapter = data.chapter;
        final translationText = verse.translations?.firstOrNull?.text ?? '';
        final cleanTranslation = stripHtml(translationText);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.amber.withValues(alpha: 0.08),
                Colors.amber.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 6),
                  Text(
                    'آية اليوم',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.copy, size: 16, color: Colors.amber[600]?.withValues(alpha: 0.6)),
                    onPressed: () {
                      final text = '${verse.textUthmani}\n\n- سورة ${chapter.nameArabic} (${verse.verseKey})';
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ الآية'), duration: Duration(seconds: 1)),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: Icon(Icons.share, size: 16, color: Colors.amber[600]?.withValues(alpha: 0.6)),
                    onPressed: () {
                      final text = '${verse.textUthmani}\n\n- سورة ${chapter.nameArabic} (${verse.verseKey})';
                      Share.share(text);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Verse text (tappable)
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    'reader',
                    pathParameters: {'chapterId': chapter.id.toString()},
                    queryParameters: {'verse': verse.verseKey},
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      verse.textUthmani,
                      style: TextStyle(
                        fontFamily: settings.quranFont,
                        fontSize: 22,
                        height: 2.0,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    if (cleanTranslation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        cleanTranslation,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'سورة ${chapter.nameArabic} \u2022 الآية ${toArabicNumeral(verse.verseNumber)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Shimmer.fromColors(
        baseColor: Colors.amber.withValues(alpha: 0.1),
        highlightColor: Colors.amber.withValues(alpha: 0.2),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
