import 'package:flutter/material.dart';
import '../../../core/constants/quran_constants.dart';

/// Bottom sheet for selecting a Quran reciter
class ReciterSelectorSheet extends StatelessWidget {
  final int selectedReciterId;
  final ValueChanged<int> onReciterSelected;

  const ReciterSelectorSheet({
    super.key,
    required this.selectedReciterId,
    required this.onReciterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'اختر القارئ',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Reciter list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: reciters.length,
              itemBuilder: (context, index) {
                final reciter = reciters[index];
                final isSelected = reciter.id == selectedReciterId;

                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  selected: isSelected,
                  selectedTileColor: const Color(0xFFD97706).withValues(alpha: 0.08),
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? const Color(0xFFD97706).withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.person,
                      color: isSelected ? const Color(0xFFD97706) : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    reciter.nameArabic,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFFD97706) : null,
                    ),
                  ),
                  subtitle: Text(
                    '${reciter.name} - ${reciter.style}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFFD97706), size: 22)
                      : null,
                  onTap: () {
                    onReciterSelected(reciter.id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
