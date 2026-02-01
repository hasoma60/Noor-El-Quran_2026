import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/chapters_provider.dart';
import '../../reader/providers/reader_provider.dart';
import '../../reader/providers/audio_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/arabic_utils.dart';

class MemorizationScreen extends ConsumerStatefulWidget {
  const MemorizationScreen({super.key});

  @override
  ConsumerState<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends ConsumerState<MemorizationScreen> {
  int? _selectedChapterId;
  int _fromVerse = 1;
  int _toVerse = 7;
  bool _started = false;
  final Set<int> _hiddenWordIndices = {};
  bool _showAll = false;
  int _score = 0;
  int _total = 0;

  void _startMemorization() {
    setState(() {
      _started = true;
      _hiddenWordIndices.clear();
      _showAll = false;
      _score = 0;
      _total = 0;
    });
  }

  void _hideRandomWords(List<String> words) {
    final rng = Random();
    final count = (words.length * 0.4).ceil(); // Hide 40% of words
    _hiddenWordIndices.clear();
    while (_hiddenWordIndices.length < count && _hiddenWordIndices.length < words.length) {
      _hiddenWordIndices.add(rng.nextInt(words.length));
    }
    _total = _hiddenWordIndices.length;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المراجعة والحفظ'),
      ),
      body: !_started
          ? _buildSetup(chaptersAsync, theme)
          : _buildMemorizationView(settings, theme),
    );
  }

  Widget _buildSetup(AsyncValue chaptersAsync, ThemeData theme) {
    return chaptersAsync.when(
      data: (chapters) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('اختر السورة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedChapterId,
              hint: const Text('اختر سورة'),
              isExpanded: true,
              items: chapters.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text('${c.nameArabic} (${toArabicNumeral(c.versesCount)} آية)'),
              )).toList(),
              onChanged: (id) {
                final ch = chapters.firstWhere((c) => c.id == id);
                setState(() {
                  _selectedChapterId = id;
                  _fromVerse = 1;
                  _toVerse = ch.versesCount.clamp(1, 10);
                });
              },
            ),

            if (_selectedChapterId != null) ...[
              const SizedBox(height: 16),
              Text('نطاق الآيات', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'من الآية'),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: '$_fromVerse'),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n > 0) setState(() => _fromVerse = n);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'إلى الآية'),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: '$_toVerse'),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n > 0) setState(() => _toVerse = n);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('بدء المراجعة'),
                onPressed: _startMemorization,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('تعذر تحميل السور')),
    );
  }

  Widget _buildMemorizationView(SettingsState settings, ThemeData theme) {
    if (_selectedChapterId == null) return const SizedBox.shrink();

    final versesAsync = ref.watch(versesProvider(_selectedChapterId!));
    final audioState = ref.watch(audioProvider);

    return versesAsync.when(
      data: (allVerses) {
        final verses = allVerses.where((v) {
          final num = v.verseNumber;
          return num >= _fromVerse && num <= _toVerse;
        }).toList();

        if (verses.isEmpty) {
          return const Center(child: Text('لا توجد آيات في هذا النطاق'));
        }

        return Column(
          children: [
            // Controls bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('رجوع'),
                    onPressed: () {
                      ref.read(audioProvider.notifier).stop();
                      setState(() => _started = false);
                    },
                  ),
                  const Spacer(),
                  if (_hiddenWordIndices.isNotEmpty)
                    FilledButton.tonal(
                      onPressed: () => setState(() => _showAll = !_showAll),
                      child: Text(_showAll ? 'إخفاء' : 'كشف الكل'),
                    ),
                ],
              ),
            ),

            // Verses
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: verses.length,
                itemBuilder: (context, index) {
                  final verse = verses[index];
                  final words = verse.textUthmani.split(' ');
                  final isCurrentVerse = audioState.currentVerseKey == verse.verseKey;

                  if (_hiddenWordIndices.isEmpty && index == 0) {
                    // Auto-hide words on first build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _hideRandomWords(words);
                    });
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Verse number badge + audio button
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'الآية ${toArabicNumeral(verse.verseNumber)}',
                                style: TextStyle(fontSize: 12, color: Colors.amber[700], fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Verse audio button
                            InkWell(
                              onTap: () {
                                ref.read(audioProvider.notifier).playVerse(
                                  _selectedChapterId!,
                                  verse.verseKey,
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isCurrentVerse && audioState.isPlaying
                                      ? const Color(0xFFD97706).withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCurrentVerse && audioState.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.volume_up_outlined,
                                  size: 18,
                                  color: isCurrentVerse && audioState.isPlaying
                                      ? const Color(0xFFD97706)
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Words with hiding
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          textDirection: TextDirection.rtl,
                          children: List.generate(words.length, (wi) {
                            final isHidden = _hiddenWordIndices.contains(wi) && !_showAll;
                            return GestureDetector(
                              onTap: isHidden
                                  ? () {
                                      setState(() {
                                        _hiddenWordIndices.remove(wi);
                                        _score++;
                                      });
                                    }
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isHidden
                                      ? Colors.amber.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: isHidden
                                      ? Border.all(color: Colors.amber.withValues(alpha: 0.3), style: BorderStyle.solid)
                                      : null,
                                ),
                                child: Text(
                                  isHidden ? '••••' : words[wi],
                                  style: TextStyle(
                                    fontFamily: settings.quranFont,
                                    fontSize: settings.fontSize.toDouble() * 0.8,
                                    height: 1.8,
                                    color: isHidden
                                        ? Colors.amber[700]
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Score bar
            if (_total > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'النتيجة: ${toArabicNumeral(_score)} / ${toArabicNumeral(_total)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                    if (_score == _total && _total > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ممتاز!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('تعذر تحميل الآيات')),
    );
  }
}
