import 'package:flutter/material.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/arabic_utils.dart';

/// Header widget shown at the top of the flowing reader view.
/// Displays chapter name, revelation info, and bismillah.
class ChapterHeader extends StatelessWidget {
  final dynamic chapter;
  final int chapterId;
  final SettingsState settings;

  const ChapterHeader({
    super.key,
    required this.chapter,
    required this.chapterId,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showBismillah = chapter?.bismillahPre ?? true;
    final isTawbah = chapterId == 9;

    return Column(
      children: [
        const SizedBox(height: 16),
        // Chapter name
        Text(
          chapter?.nameArabic ?? '',
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 42,
            color: Color(0xFFD97706),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${chapter?.revelationPlace == "makkah" ? "مكية" : "مدنية"} \u2022 ${toArabicNumeral(chapter?.versesCount ?? 0)} آية',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Bismillah
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
