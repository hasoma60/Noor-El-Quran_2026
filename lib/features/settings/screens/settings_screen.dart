import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/settings_provider.dart';
import '../widgets/reciter_selector_sheet.dart';
import '../../home/providers/bookmark_provider.dart';
import '../../home/providers/progress_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/quran_constants.dart';

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
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme section
          _SectionTitle(title: 'المظهر', theme: theme),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ThemeChip(label: 'تلقائي', value: 'system', selected: settings.theme, onSelected: notifier.setTheme),
              _ThemeChip(label: 'فاتح', value: 'light', selected: settings.theme, onSelected: notifier.setTheme),
              _ThemeChip(label: 'داكن', value: 'dark', selected: settings.theme, onSelected: notifier.setTheme),
              _ThemeChip(label: 'أسود', value: 'amoled', selected: settings.theme, onSelected: notifier.setTheme),
              _ThemeChip(label: 'بني', value: 'sepia', selected: settings.theme, onSelected: notifier.setTheme),
            ],
          ),

          const SizedBox(height: 16),

          // Night mode schedule
          SwitchListTile(
            title: const Text('الوضع الليلي التلقائي'),
            subtitle: Text(
              settings.nightModeSchedule.enabled
                  ? 'من ${settings.nightModeSchedule.startHour}:00 إلى ${settings.nightModeSchedule.endHour}:00'
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
                          items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('$i:00'))),
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
                          items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('$i:00'))),
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
          _SectionTitle(title: 'حجم الخط: ${settings.fontSize}', theme: theme),
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
          ...['Amiri', 'Scheherazade New', 'Noto Naskh Arabic'].map(
            (font) => RadioListTile<String>(
              title: Text(font, style: TextStyle(fontFamily: font, fontSize: 18)),
              value: font,
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

          // Word by word
          SwitchListTile(
            title: const Text('عرض كلمة بكلمة'),
            subtitle: const Text('ترجمة كل كلمة على حدة'),
            value: settings.showWordByWord,
            onChanged: notifier.setShowWordByWord,
          ),

          // Tajweed colors
          SwitchListTile(
            title: const Text('ألوان التجويد'),
            subtitle: const Text('تلوين أحكام التجويد في النص القرآني'),
            value: settings.showTajweed,
            onChanged: notifier.setShowTajweed,
          ),

          const Divider(height: 32),

          // Reciter selection
          _SectionTitle(title: 'القارئ', theme: theme),
          const SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            leading: const Icon(Icons.person, color: Color(0xFFD97706)),
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

class _ThemeChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ThemeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
