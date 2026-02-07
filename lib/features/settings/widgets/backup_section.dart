import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../home/providers/bookmark_provider.dart';
import '../../home/providers/progress_provider.dart';
import '../../../core/constants/app_constants.dart';

/// Export/import backup section for settings screen.
class BackupSection extends ConsumerWidget {
  const BackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'النسخ الاحتياطي',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.upload_outlined),
                label: const Text('تصدير'),
                onPressed: () => _exportData(context, ref),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download_outlined),
                label: const Text('استيراد'),
                onPressed: () => _importData(context, ref),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final bookmarkState = ref.read(bookmarkProvider);
      final progressState = ref.read(progressProvider);

      final exportData = {
        'version': appVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'bookmarks': bookmarkState.bookmarks.map((b) => {
          'id': b.id,
          'verseKey': b.verseKey,
          'chapterId': b.chapterId,
          'chapterName': b.chapterName,
          'verseText': b.text,
          'category': b.category,
          'createdAt': b.timestamp,
        }).toList(),
        'notes': bookmarkState.notes.map((n) => {
          'id': n.id,
          'verseKey': n.verseKey,
          'chapterId': n.chapterId,
          'chapterName': n.chapterName,
          'verseText': n.verseText,
          'note': n.note,
          'createdAt': n.createdAt,
          'updatedAt': n.updatedAt,
        }).toList(),
        'khatmahPlans': progressState.khatmahPlans.map((p) => {
          'id': p.id,
          'name': p.name,
          'totalDays': p.totalDays,
          'startDate': p.startDate,
          'completedDays': p.completedDays,
          'currentDay': p.currentDay,
        }).toList(),
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(exportData);
      await Share.share(jsonStr, subject: 'نور القرآن - نسخة احتياطية');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تصدير البيانات بنجاح')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التصدير: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Validate
      if (!data.containsKey('version') || !data.containsKey('bookmarks')) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ملف غير صالح')),
          );
        }
        return;
      }

      // Import bookmarks
      final bookmarkNotifier = ref.read(bookmarkProvider.notifier);
      final bookmarks = data['bookmarks'] as List<dynamic>? ?? [];
      for (final b in bookmarks) {
        final bm = b as Map<String, dynamic>;
        bookmarkNotifier.importBookmark(bm);
      }

      // Import notes
      final notes = data['notes'] as List<dynamic>? ?? [];
      for (final n in notes) {
        final nm = n as Map<String, dynamic>;
        bookmarkNotifier.importNote(nm);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم استيراد ${bookmarks.length} إشارة و ${notes.length} ملاحظة'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الاستيراد: $e')),
        );
      }
    }
  }
}
