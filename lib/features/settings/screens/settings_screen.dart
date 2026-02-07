import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../widgets/appearance_section.dart';
import '../widgets/reading_section.dart';
import '../widgets/audio_section.dart';
import '../widgets/backup_section.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme section
          AppearanceSection(settings: settings, notifier: notifier),

          const SizedBox(height: 24),

          // Reading section
          ReadingSection(settings: settings, notifier: notifier),

          const Divider(height: 32),

          // Audio section
          AudioSection(settings: settings, notifier: notifier),

          const Divider(height: 32),

          // Reduced motion
          SwitchListTile(
            title: const Text('تقليل الحركة'),
            subtitle: const Text('إيقاف الرسوم المتحركة'),
            value: settings.reducedMotion,
            onChanged: notifier.setReducedMotion,
          ),

          const Divider(height: 32),

          // Backup section
          const BackupSection(),

          const SizedBox(height: 24),

          // App info
          Center(
            child: Text(
              'نور القرآن v$appVersion',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
