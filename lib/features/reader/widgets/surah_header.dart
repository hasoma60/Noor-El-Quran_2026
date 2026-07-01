import 'package:flutter/material.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../domain/entities/chapter.dart';
import '../../settings/providers/settings_provider.dart';

/// Surah heading shown at the top of a chapter in the reader:
/// the chapter name, revelation place / verse count, and the Bismillah.
///
/// Shared by both the flowing (verse-card) view and the Mushaf view so the
/// chapter intro looks identical regardless of reading mode.
class SurahHeader extends StatelessWidget {
  final Chapter? chapter;
  final int chapterId;
  final SettingsState settings;

  const SurahHeader({
    super.key,
    required this.chapter,
    required this.chapterId,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showBismillah = chapter?.bismillahPre ?? true;
    // Surah At-Tawbah (9) has no Bismillah.
    final isTawbah = chapterId == 9;

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          chapter?.nameArabic ?? '',
          style: TextStyle(
            fontFamily: settings.quranFont,
            fontSize: 42,
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${chapter?.revelationPlace == "makkah" ? "مكية" : "مدنية"} • ${toArabicNumeral(chapter?.versesCount ?? 0)} آية',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (showBismillah && !isTawbah) ...[
          Text(
            'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
            style: TextStyle(
              fontFamily: settings.quranFont,
              fontSize: 28,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 8),
      ],
    );
  }
}
