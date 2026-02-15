import 'package:flutter/material.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/utils/html_sanitizer.dart';
import '../../../domain/entities/verse.dart';
import '../../settings/providers/settings_provider.dart';
import 'tajweed_text.dart';
import 'word_by_word_widget.dart';

class VerseCard extends StatelessWidget {
  final Verse verse;
  final bool isHighlighted;
  final bool isBookmarked;
  final SettingsState settings;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onTafsir;
  final VoidCallback onShare;
  final VoidCallback onNote;
  final VoidCallback? onPlay;
  final bool isPlayingAudio;

  const VerseCard({
    super.key,
    required this.verse,
    required this.isHighlighted,
    required this.isBookmarked,
    required this.settings,
    required this.onBookmarkToggle,
    required this.onTafsir,
    required this.onShare,
    required this.onNote,
    this.onPlay,
    this.isPlayingAudio = false,
  });

  double get _lineHeight {
    switch (settings.lineHeight) {
      case 'compact':
        return 1.8;
      case 'loose':
        return 2.8;
      default:
        return 2.2;
    }
  }

  TextStyle _buildAyahMarkerStyle() {
    return TextStyle(
      fontFamily: settings.quranFont,
      fontSize: settings.fontSize.toDouble() * 0.62,
      height: _lineHeight,
      color: const Color(0xFFD97706),
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildArabicText(ThemeData theme, int verseNum) {
    final textColor =
        theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final marker = formatAyahMarker(
      verseNum,
      style: settings.ayahNumberStyle,
    );

    // Word-by-word mode
    if (settings.showWordByWord &&
        verse.words != null &&
        verse.words!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          WordByWordWidget(
            words: verse.words!,
            fontFamily: settings.quranFont,
            fontSize: settings.fontSize.toDouble(),
            textColor: textColor,
            translationColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              marker,
              style: _buildAyahMarkerStyle(),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      );
    }

    // Tajweed color mode
    if (settings.showTajweed &&
        verse.textUthmaniTajweed != null &&
        verse.textUthmaniTajweed!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TajweedText(
            tajweedHtml: verse.textUthmaniTajweed!,
            fontFamily: settings.quranFont,
            fontSize: settings.fontSize.toDouble(),
            lineHeight: _lineHeight,
            defaultColor: textColor,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              marker,
              style: _buildAyahMarkerStyle(),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      );
    }

    // Default plain text mode
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: verse.textUthmani,
            style: TextStyle(
              fontFamily: settings.quranFont,
              fontSize: settings.fontSize.toDouble(),
              height: _lineHeight,
              color: textColor,
            ),
          ),
          TextSpan(
            text: ' $marker',
            style: _buildAyahMarkerStyle(),
          ),
        ],
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      strutStyle: StrutStyle(
        forceStrutHeight: true,
        fontFamily: settings.quranFont,
        fontSize: settings.fontSize.toDouble(),
        height: _lineHeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verseNum = verse.verseNumber;
    final translationText = verse.translations?.firstOrNull?.text ?? '';
    final cleanTranslation = stripHtml(translationText);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.amber.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isHighlighted
            ? Border.all(color: Colors.amber.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse toolbar (top row)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ToolButton(
                icon: isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                color: isBookmarked ? const Color(0xFFD97706) : null,
                onTap: onBookmarkToggle,
                tooltip: isBookmarked ? 'إزالة الإشارة' : 'حفظ الآية',
              ),
              _ToolButton(
                  icon: Icons.menu_book_outlined,
                  onTap: onTafsir,
                  tooltip: 'تفسير'),
              _ToolButton(
                  icon: Icons.share_outlined,
                  onTap: onShare,
                  tooltip: 'مشاركة'),
              _ToolButton(
                  icon: Icons.note_alt_outlined,
                  onTap: onNote,
                  tooltip: 'ملاحظة'),
              if (onPlay != null)
                _ToolButton(
                  icon: isPlayingAudio
                      ? Icons.pause_rounded
                      : Icons.volume_up_outlined,
                  color: isPlayingAudio ? const Color(0xFFD97706) : null,
                  onTap: onPlay!,
                  tooltip: isPlayingAudio ? 'إيقاف مؤقت' : 'تشغيل الآية',
                ),
            ],
          ),

          // Arabic text - conditional rendering
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildArabicText(theme, verseNum),
          ),

          // Translation
          if (settings.showTranslation && cleanTranslation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsetsDirectional.only(start: 12),
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cleanTranslation,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onTafsir,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'قراءة التفسير',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[700],
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_left,
                            size: 14, color: Colors.amber[700]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Divider
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  final String tooltip;

  const _ToolButton({
    required this.icon,
    this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
