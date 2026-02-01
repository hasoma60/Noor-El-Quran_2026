import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import '../providers/reader_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/utils/html_sanitizer.dart';
import '../../../domain/entities/verse.dart';

class TafsirSheet extends ConsumerStatefulWidget {
  final Verse verse;
  final String chapterName;

  const TafsirSheet({
    super.key,
    required this.verse,
    required this.chapterName,
  });

  @override
  ConsumerState<TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends ConsumerState<TafsirSheet> {
  int _selectedTafsirId = 16; // Default: Al-Muyassar

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    final tafsirAsync = ref.watch(tafsirContentProvider(
      (tafsirId: _selectedTafsirId, verseKey: widget.verse.verseKey),
    ));

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تفسير الآية',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'سورة ${widget.chapterName} \u2022 الآية ${toArabicNumeral(widget.verse.verseNumber)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tafsir source tabs
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: tafsirOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = tafsirOptions[index];
                final selected = option.id == _selectedTafsirId;
                return FilterChip(
                  label: Text(option.name, style: TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedTafsirId = option.id),
                  selectedColor: const Color(0xFFD97706),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),

          const SizedBox(height: 8),
          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Verse preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      widget.verse.textUthmani,
                      style: TextStyle(
                        fontFamily: settings.quranFont,
                        fontSize: 20,
                        height: 2.0,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tafsir content
                  tafsirAsync.when(
                    data: (content) => Html(
                      data: sanitizeHtml(content),
                      style: {
                        'body': Style(
                          fontFamily: 'Amiri',
                          fontSize: FontSize(16),
                          lineHeight: const LineHeight(2.0),
                          textAlign: TextAlign.justify,
                          direction: TextDirection.rtl,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      },
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, __) => const Center(
                      child: Text('تعذر تحميل التفسير'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
