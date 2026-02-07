import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import '../widgets/reciter_selector_sheet.dart';
import '../../../core/constants/quran_constants.dart';

/// Reciter selection and playback settings section.
class AudioSection extends StatelessWidget {
  final SettingsState settings;
  final SettingsNotifier notifier;

  const AudioSection({
    super.key,
    required this.settings,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedReciter = reciters.where((r) => r.id == settings.selectedReciterId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'القارئ',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
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
      ],
    );
  }
}
