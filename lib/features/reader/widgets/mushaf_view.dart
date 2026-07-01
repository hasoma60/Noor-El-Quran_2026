import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../domain/entities/chapter.dart';
import '../../../domain/entities/verse.dart';
import '../../settings/providers/settings_provider.dart';
import 'surah_header.dart';

/// Continuous, page-style reading view that mimics a printed Mushaf:
/// all verses of the chapter flow together as justified Arabic text, with an
/// ornate end-of-ayah marker (U+06DD) carrying the verse number after each one.
///
/// Tapping a verse highlights it and invokes [onVerseTap] so the parent can
/// surface the per-verse actions (bookmark, tafsir, share, note, play).
class MushafView extends StatefulWidget {
  final List<Verse> verses;
  final Chapter? chapter;
  final int chapterId;
  final SettingsState settings;
  final ScrollController controller;
  final String? highlightVerseKey;
  final String? playingVerseKey;
  final Future<void> Function(Verse verse) onVerseTap;

  const MushafView({
    super.key,
    required this.verses,
    required this.chapter,
    required this.chapterId,
    required this.settings,
    required this.controller,
    required this.onVerseTap,
    this.highlightVerseKey,
    this.playingVerseKey,
  });

  @override
  State<MushafView> createState() => _MushafViewState();
}

class _MushafViewState extends State<MushafView> {
  final Map<String, TapGestureRecognizer> _recognizers = {};
  String? _activeVerseKey;

  @override
  void initState() {
    super.initState();
    _buildRecognizers();
  }

  @override
  void didUpdateWidget(MushafView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verses != widget.verses) {
      _disposeRecognizers();
      _buildRecognizers();
    }
  }

  void _buildRecognizers() {
    for (final verse in widget.verses) {
      _recognizers[verse.verseKey] = TapGestureRecognizer()
        ..onTap = () => _handleTap(verse);
    }
  }

  void _disposeRecognizers() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    _recognizers.clear();
  }

  Future<void> _handleTap(Verse verse) async {
    setState(() => _activeVerseKey = verse.verseKey);
    await widget.onVerseTap(verse);
    if (mounted) setState(() => _activeVerseKey = null);
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  double get _lineHeight {
    switch (widget.settings.lineHeight) {
      case 'compact':
        return 1.9;
      case 'loose':
        return 2.9;
      default:
        return 2.3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final settings = widget.settings;

    final baseStyle = TextStyle(
      fontFamily: settings.quranFont,
      fontSize: settings.fontSize.toDouble(),
      height: _lineHeight,
      color: theme.textTheme.bodyLarge?.color,
    );

    final spans = <InlineSpan>[];
    for (final verse in widget.verses) {
      final isActive = verse.verseKey == _activeVerseKey ||
          verse.verseKey == widget.highlightVerseKey;
      final isPlaying = verse.verseKey == widget.playingVerseKey;

      final Color? background = isPlaying
          ? accent.withValues(alpha: 0.18)
          : isActive
              ? accent.withValues(alpha: 0.10)
              : null;

      spans.add(
        TextSpan(
          // U+06DD (end of ayah) renders an ornate medallion enclosing the
          // verse number in Mushaf-grade fonts (KFGQPC, Amiri, Scheherazade…).
          text: '${verse.textUthmani} ۝${toArabicNumeral(verse.verseNumber)} ',
          style: baseStyle.copyWith(backgroundColor: background),
          recognizer: _recognizers[verse.verseKey],
        ),
      );
    }

    return SingleChildScrollView(
      controller: widget.controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SurahHeader(
            chapter: widget.chapter,
            chapterId: widget.chapterId,
            settings: settings,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
            ),
            child: Text.rich(
              TextSpan(children: spans),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
