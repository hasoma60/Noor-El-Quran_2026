import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';

/// Theme and night mode settings section.
class AppearanceSection extends StatelessWidget {
  final SettingsState settings;
  final SettingsNotifier notifier;

  const AppearanceSection({
    super.key,
    required this.settings,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'المظهر', theme: theme),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ThemeChip(label: 'تلقائي', value: 'system', selected: settings.theme, onSelected: notifier.setTheme),
            _ThemeChip(label: 'فاتح', value: 'light', selected: settings.theme, onSelected: notifier.setTheme),
            _ThemeChip(label: 'داكن', value: 'dark', selected: settings.theme, onSelected: notifier.setTheme),
            _ThemeChip(label: 'أسود', value: 'amoled', selected: settings.theme, onSelected: notifier.setTheme),
            _ThemeChip(label: 'بني', value: 'sepia', selected: settings.theme, onSelected: notifier.setTheme),
          ],
        ),

        const SizedBox(height: 16),

        // Night mode schedule
        SwitchListTile(
          title: const Text('الوضع الليلي التلقائي'),
          subtitle: Text(
            settings.nightModeSchedule.enabled
                ? 'من ${settings.nightModeSchedule.startHour}:00 إلى ${settings.nightModeSchedule.endHour}:00'
                : 'معطل',
          ),
          value: settings.nightModeSchedule.enabled,
          onChanged: (val) {
            notifier.setNightModeSchedule(
              settings.nightModeSchedule.copyWith(enabled: val),
            );
          },
        ),

        if (settings.nightModeSchedule.enabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('بداية', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                      DropdownButton<int>(
                        value: settings.nightModeSchedule.startHour,
                        isExpanded: true,
                        items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('$i:00'))),
                        onChanged: (v) {
                          if (v != null) {
                            notifier.setNightModeSchedule(
                              settings.nightModeSchedule.copyWith(startHour: v),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('نهاية', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                      DropdownButton<int>(
                        value: settings.nightModeSchedule.endHour,
                        isExpanded: true,
                        items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('$i:00'))),
                        onChanged: (v) {
                          if (v != null) {
                            notifier.setNightModeSchedule(
                              settings.nightModeSchedule.copyWith(endHour: v),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionTitle({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ThemeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
