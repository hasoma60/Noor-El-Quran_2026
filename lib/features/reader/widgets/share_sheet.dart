import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/utils/html_sanitizer.dart';
import '../../../core/widgets/base_bottom_sheet.dart';
import '../../../domain/entities/verse.dart';

class ShareSheet extends ConsumerWidget {
  final Verse verse;
  final String chapterName;

  const ShareSheet({
    super.key,
    required this.verse,
    required this.chapterName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final translationText = verse.translations?.firstOrNull?.text ?? '';
    final cleanTranslation = stripHtml(translationText);
    final reference = 'سورة $chapterName - الآية ${toArabicNumeral(verse.verseNumber)}';
    final fullText = '${verse.textUthmani}\n\n${cleanTranslation.isNotEmpty ? "$cleanTranslation\n\n" : ""}- $reference';

    return BaseBottomSheet(
      title: 'مشاركة الآية',
      maxHeightFraction: 0.6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  Text(
                    verse.textUthmani,
                    style: TextStyle(
                      fontFamily: settings.quranFont,
                      fontSize: 18,
                      height: 2.0,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reference,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Copy buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('نسخ النص'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: verse.textUthmani));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ النص العربي'), duration: Duration(seconds: 1)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy_all, size: 18),
                    label: const Text('نسخ مع التفسير'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: fullText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ الآية مع التفسير'), duration: Duration(seconds: 1)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Native share
            FilledButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('مشاركة', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Share.share(fullText, subject: reference);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
