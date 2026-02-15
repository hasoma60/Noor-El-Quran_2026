import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import '../../../core/constants/app_constants.dart';

/// Font, size, line height, and reading toggles settings section.
class ReadingSection extends StatelessWidget {
  final SettingsState settings;
  final SettingsNotifier notifier;

  const ReadingSection({
    super.key,
    required this.settings,
    required this.notifier,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Font size
        Text(
          'حجم الخط: ${settings.fontSize}',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
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
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
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
        Text(
          'خط القرآن',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...['Hafs Smart', 'Scheherazade New', 'Amiri', 'Noto Naskh Arabic'].map(
          (font) => RadioListTile<String>(
            title: Text(font, style: TextStyle(fontFamily: font, fontSize: 18)),
            value: font,
            groupValue: settings.quranFont,
            onChanged: (v) => notifier.setQuranFont(v!),
          ),
        ),

        const SizedBox(height: 16),

        // Script mode
        Text(
          'وضع النص',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'madinah', label: Text('مصحف المدينة')),
            ButtonSegment(value: 'modern', label: Text('مرن')),
          ],
          selected: {settings.scriptMode},
          onSelectionChanged: (v) => notifier.setScriptMode(v.first),
        ),
        const SizedBox(height: 8),
        Text(
          settings.scriptMode == 'madinah'
              ? 'تهيئة صارمة للتشكيل وتباعد الأسطر (موصى به للقراءة الطويلة)'
              : 'وضع مرن للتوافق مع خطوط متعددة',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),

        const SizedBox(height: 16),

        // Line height
        Text(
          'تباعد الأسطر',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
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

        // Ayah number style
        Text(
          'ترقيم الآيات',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'native', label: Text('قرآني')),
            ButtonSegment(value: 'badge', label: Text('دائري')),
          ],
          selected: {settings.ayahNumberStyle},
          onSelectionChanged: (v) => notifier.setAyahNumberStyle(v.first),
        ),

        const SizedBox(height: 24),

        // Resume mode
        SwitchListTile(
          title: const Text('استئناف آخر موضع عند الفتح'),
          subtitle: const Text('فتح التطبيق على آخر آية/صفحة تمت قراءتها'),
          value: settings.autoResumeLastAyah,
          onChanged: notifier.setAutoResumeLastAyah,
        ),

        const SizedBox(height: 8),

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
      ],
    );
  }
}
