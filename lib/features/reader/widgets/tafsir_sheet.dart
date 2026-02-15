import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reader_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/utils/html_sanitizer.dart';
import '../../../core/widgets/base_bottom_sheet.dart';
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
  late int _selectedTafsirId;
  final TextEditingController _searchController = TextEditingController();
  String _inSheetQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedTafsirId = ref.read(settingsProvider).defaultTafsirId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectTafsir(int id) {
    setState(() => _selectedTafsirId = id);
    ref.read(settingsProvider.notifier).setDefaultTafsirId(id);
  }

  TextSpan _highlightedTextSpan(String text, String query, TextStyle style) {
    if (query.isEmpty) return TextSpan(text: text, style: style);

    final lcText = text.toLowerCase();
    final lcQuery = query.toLowerCase();
    final spans = <InlineSpan>[];
    var start = 0;

    while (start < text.length) {
      final idx = lcText.indexOf(lcQuery, start);
      if (idx < 0) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: style));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: style.copyWith(
            backgroundColor: const Color(0xFFD97706).withValues(alpha: 0.25),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      start = idx + query.length;
    }

    return TextSpan(children: spans, style: style);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    final tafsirAsync = ref.watch(tafsirContentProvider(
      (tafsirId: _selectedTafsirId, verseKey: widget.verse.verseKey),
    ));

    return BaseBottomSheet(
      title: 'تفسير الآية',
      subtitle:
          'سورة ${widget.chapterName} • الآية ${toArabicNumeral(widget.verse.verseNumber)}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  label:
                      Text(option.name, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => _selectTafsir(option.id),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'ابحث داخل التفسير',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _inSheetQuery = '');
                        },
                      ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (v) => setState(() => _inSheetQuery = v.trim()),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.15)),
                    ),
                    child: SelectableText(
                      widget.verse.textUthmani,
                      style: TextStyle(
                        fontFamily: settings.quranFont,
                        fontSize: 20,
                        height: settings.scriptMode == 'madinah' ? 2.2 : 2.0,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(height: 14),
                  tafsirAsync.when(
                    data: (content) {
                      final plain = stripHtml(sanitizeHtml(content))
                          .replaceAll(RegExp(r'\s+'), ' ')
                          .trim();
                      if (plain.isEmpty) {
                        return const Text(
                          'لا يوجد نص تفسير متاح لهذه الآية.',
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        );
                      }

                      final baseStyle = TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        height: 2.0,
                        color: theme.textTheme.bodyMedium?.color,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: plain));
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم نسخ التفسير'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy_outlined, size: 18),
                                label: const Text('نسخ'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SelectableText.rich(
                            _highlightedTextSpan(
                                plain, _inSheetQuery, baseStyle),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      );
                    },
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
