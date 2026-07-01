import 'package:flutter/material.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../domain/entities/verse.dart';
import '../../settings/providers/settings_provider.dart';

/// Bottom sheet of per-verse actions surfaced when a verse is tapped in the
/// Mushaf view (which has no inline toolbar). Mirrors the actions available on
/// the verse cards: bookmark, tafsir, share, note and audio playback.
class VerseActionsSheet extends StatelessWidget {
  final Verse verse;
  final String chapterName;
  final SettingsState settings;
  final bool isBookmarked;
  final bool isPlaying;
  final VoidCallback onBookmark;
  final VoidCallback onTafsir;
  final VoidCallback onShare;
  final VoidCallback onNote;
  final VoidCallback onPlay;

  const VerseActionsSheet({
    super.key,
    required this.verse,
    required this.chapterName,
    required this.settings,
    required this.isBookmarked,
    required this.isPlaying,
    required this.onBookmark,
    required this.onTafsir,
    required this.onShare,
    required this.onNote,
    required this.onPlay,
  });

  void _run(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$chapterName • الآية ${toArabicNumeral(verse.verseNumber)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              verse.textUthmani,
              style: TextStyle(
                fontFamily: settings.quranFont,
                fontSize: 24,
                height: 2.0,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionItem(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  label: 'حفظ',
                  color: isBookmarked ? accent : null,
                  onTap: () => _run(context, onBookmark),
                ),
                _ActionItem(
                  icon: Icons.menu_book_outlined,
                  label: 'تفسير',
                  onTap: () => _run(context, onTafsir),
                ),
                _ActionItem(
                  icon: isPlaying ? Icons.pause_rounded : Icons.volume_up_outlined,
                  label: 'استماع',
                  color: isPlaying ? accent : null,
                  onTap: () => _run(context, onPlay),
                ),
                _ActionItem(
                  icon: Icons.note_alt_outlined,
                  label: 'ملاحظة',
                  onTap: () => _run(context, onNote),
                ),
                _ActionItem(
                  icon: Icons.share_outlined,
                  label: 'مشاركة',
                  onTap: () => _run(context, onShare),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.onSurface.withValues(alpha: 0.7);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: tint),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: tint),
            ),
          ],
        ),
      ),
    );
  }
}
