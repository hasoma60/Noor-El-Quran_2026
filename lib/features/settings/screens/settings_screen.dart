import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/settings_provider.dart';
import '../widgets/reciter_selector_sheet.dart';
import '../../home/providers/bookmark_provider.dart';
import '../../home/providers/progress_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../domain/entities/khatmah_plan.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    // Find selected reciter name
    final selectedReciter = reciters.where((r) => r.id == settings.selectedReciterId).firstOrNull;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme section
          _SectionTitle(title: 'المظهر', theme: theme),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'system', label: Text('تلقائي')),
              ButtonSegment(value: 'light', label: Text('فاتح')),
              ButtonSegment(value: 'dark', label: Text('داكن')),
              ButtonSegment(value: 'sepia', label: Text('بني')),
            ],
            selected: {settings.theme},
            onSelectionChanged: (v) => notifier.setTheme(v.first),
          ),

          const SizedBox(height: 16),

          // Night mode schedule
          SwitchListTile(
            title: const Text('الوضع الليلي التلقائي'),
            subtitle: Text(
              settings.nightModeSchedule.enabled
                  ? 'من ${toArabicNumeral(settings.nightModeSchedule.startHour)}:٠٠ إلى ${toArabicNumeral(settings.nightModeSchedule.endHour)}:٠٠'
                  : 'معطل',
            ),
            value: settings.nightModeSchedule.enabled,
            onChanged: (val) {
              notifier.setNightModeSchedule(
                settings.nightModeSchedule.copyWith(enabled: val),
              );
            },
          ),

          if (settings.nightModeSchedule.enabled) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('بداية', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        DropdownButton<int>(
                          value: settings.nightModeSchedule.startHour,
                          isExpanded: true,
                          items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('${toArabicNumeral(i)}:٠٠'))),
                          onChanged: (v) {
                            if (v != null) {
                              notifier.setNightModeSchedule(
                                settings.nightModeSchedule.copyWith(startHour: v),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('نهاية', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        DropdownButton<int>(
                          value: settings.nightModeSchedule.endHour,
                          isExpanded: true,
                          items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('${toArabicNumeral(i)}:٠٠'))),
                          onChanged: (v) {
                            if (v != null) {
                              notifier.setNightModeSchedule(
                                settings.nightModeSchedule.copyWith(endHour: v),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Font size
          _SectionTitle(title: 'حجم الخط: ${toArabicNumeral(settings.fontSize)}', theme: theme),
          Slider(
            value: settings.fontSize.toDouble(),
            min: fontSizeMin.toDouble(),
            max: fontSizeMax.toDouble(),
            divisions: fontSizeMax - fontSizeMin,
            onChanged: (v) => notifier.setFontSize(v.round()),
          ),

          // Font preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
              style: TextStyle(
                fontFamily: settings.quranFont,
                fontSize: settings.fontSize.toDouble(),
                height: _getLineHeight(settings.lineHeight),
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),

          const SizedBox(height: 24),

          // Quran font
          _SectionTitle(title: 'خط القرآن', theme: theme),
          const SizedBox(height: 8),
          ...quranFontOptions.map(
            (option) => RadioListTile<String>(
              title: Text(option.label),
              subtitle: Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                style: TextStyle(fontFamily: option.family, fontSize: 20),
                textDirection: TextDirection.rtl,
              ),
              value: option.family,
              groupValue: settings.quranFont,
              onChanged: (v) => notifier.setQuranFont(v!),
            ),
          ),

          const SizedBox(height: 16),

          // Line height
          _SectionTitle(title: 'تباعد الأسطر', theme: theme),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'compact', label: Text('مضغوط')),
              ButtonSegment(value: 'normal', label: Text('عادي')),
              ButtonSegment(value: 'loose', label: Text('واسع')),
            ],
            selected: {settings.lineHeight},
            onSelectionChanged: (v) => notifier.setLineHeight(v.first),
          ),

          const SizedBox(height: 24),

          // Show translation
          SwitchListTile(
            title: const Text('عرض الترجمة'),
            subtitle: const Text('إظهار التفسير الميسر أسفل كل آية'),
            value: settings.showTranslation,
            onChanged: notifier.setShowTranslation,
          ),

          const Divider(height: 32),

          // Reciter selection
          _SectionTitle(title: 'القارئ', theme: theme),
          const SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            leading: Icon(Icons.person, color: theme.colorScheme.primary),
            title: Text(selectedReciter?.nameArabic ?? 'مشاري راشد العفاسي'),
            subtitle: Text(
              selectedReciter != null ? '${selectedReciter.name} - ${selectedReciter.style}' : '',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ReciterSelectorSheet(
                  selectedReciterId: settings.selectedReciterId,
                  onReciterSelected: (id) => notifier.setSelectedReciterId(id),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Reduced motion
          SwitchListTile(
            title: const Text('تقليل الحركة'),
            subtitle: const Text('إيقاف الرسوم المتحركة'),
            value: settings.reducedMotion,
            onChanged: notifier.setReducedMotion,
          ),

          const Divider(height: 32),

          // Export/Import
          _SectionTitle(title: 'النسخ الاحتياطي', theme: theme),
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

          const SizedBox(height: 24),

          // App info
          Center(
            child: Text(
              'نور القرآن v$appVersion',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  double _getLineHeight(String lineHeight) {
    switch (lineHeight) {
      case 'compact':
        return 1.8;
      case 'loose':
        return 2.8;
      default:
        return 2.2;
    }
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
          'dailyTarget': p.dailyTarget
              .map((t) => {'fromVerse': t.fromVerse, 'toVerse': t.toVerse})
              .toList(),
        }).toList(),
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(exportData);

      // Write to a real .json file and share that, so the backup can be
      // re-imported via the file picker (sharing plain text could not be).
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/noor_quran_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonStr);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'نور القرآن - نسخة احتياطية',
      );

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

      // Import khatmah plans (merge new ones by id)
      final plansJson = data['khatmahPlans'] as List<dynamic>? ?? [];
      var importedPlans = 0;
      if (plansJson.isNotEmpty) {
        final dataSource = ref.read(progressLocalDataSourceProvider);
        final existing = ref.read(progressProvider).khatmahPlans;
        final existingIds = existing.map((p) => p.id).toSet();
        final toAdd = <KhatmahPlan>[];
        for (final p in plansJson) {
          final pm = p as Map<String, dynamic>;
          final id = pm['id'] as String?;
          if (id == null || existingIds.contains(id)) continue;
          toAdd.add(KhatmahPlan(
            id: id,
            name: pm['name'] as String? ?? 'خطة',
            totalDays: pm['totalDays'] as int? ?? 30,
            startDate: pm['startDate'] as int? ?? DateTime.now().millisecondsSinceEpoch,
            completedDays: (pm['completedDays'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, v as bool)),
            currentDay: pm['currentDay'] as int? ?? 0,
            dailyTarget: ((pm['dailyTarget'] as List<dynamic>?) ?? [])
                .map((t) => DailyTarget(
                      fromVerse: (t as Map<String, dynamic>)['fromVerse']?.toString() ?? '1',
                      toVerse: t['toVerse']?.toString() ?? '1',
                    ))
                .toList(),
          ));
        }
        if (toAdd.isNotEmpty) {
          await dataSource.saveKhatmahPlans([...existing, ...toAdd]);
          ref.invalidate(progressProvider);
          importedPlans = toAdd.length;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم استيراد ${toArabicNumeral(bookmarks.length)} إشارة و ${toArabicNumeral(notes.length)} ملاحظة'
              '${importedPlans > 0 ? ' و ${toArabicNumeral(importedPlans)} خطة' : ''}',
            ),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionTitle({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
