import 'package:flutter/material.dart';
import '../../../core/constants/theme_constants.dart';

/// Bottom sheet showing the 7 tajweed rule colors with Arabic labels.
class TajweedLegend extends StatelessWidget {
  const TajweedLegend({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const TajweedLegend(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final entries = TajweedColors.arabicLabels.entries.where((e) {
      // Only show the 7 main rules, not the API alias keys
      return TajweedColors.colorMap.containsKey(e.key);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'دليل ألوان التجويد',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...entries.map((entry) {
            final color = TajweedColors.colorMap[entry.key]!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
