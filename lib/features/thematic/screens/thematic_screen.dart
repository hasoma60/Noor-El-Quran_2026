import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/utils/arabic_utils.dart';

class ThematicScreen extends StatelessWidget {
  const ThematicScreen({super.key});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'park':
        return Icons.park;
      case 'menu_book':
        return Icons.menu_book;
      case 'front_hand':
        return Icons.front_hand;
      case 'balance':
        return Icons.balance;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'hourglass_bottom':
        return Icons.hourglass_bottom;
      case 'science':
        return Icons.science;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفهرس الموضوعي'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: thematicTopics.length,
        itemBuilder: (context, index) {
          final topic = thematicTopics[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _ThematicVersesScreen(
                      topicName: topic.name,
                      topicDescription: topic.description,
                      icon: _getIcon(topic.icon),
                      verses: topic.verses,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIcon(topic.icon),
                      size: 36,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${toArabicNumeral(topic.verses.length)} آية',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Screen showing verses for a specific thematic topic
class _ThematicVersesScreen extends StatelessWidget {
  final String topicName;
  final String topicDescription;
  final IconData icon;
  final List<String> verses;

  const _ThematicVersesScreen({
    required this.topicName,
    required this.topicDescription,
    required this.icon,
    required this.verses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(topicName),
      ),
      body: Column(
        children: [
          // Topic header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            ),
            child: Column(
              children: [
                Icon(icon, size: 40, color: theme.colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  topicDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  '${toArabicNumeral(verses.length)} آية',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ),

          // Verse list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: verses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final verseKey = verses[index];
                final parts = verseKey.split(':');
                final chapterId = int.tryParse(parts[0]) ?? 1;
                final verseNum = parts.length > 1 ? parts[1] : '1';

                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      toArabicNumeral(index + 1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                  ),
                  title: Text(
                    'سورة ${toArabicNumeral(chapterId)} - الآية ${toArabicNumeral(int.tryParse(verseNum) ?? 1)}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  subtitle: Text(
                    verseKey,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_left,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  onTap: () {
                    context.pushNamed(
                      'reader',
                      pathParameters: {'chapterId': chapterId.toString()},
                      queryParameters: {'verse': verseKey},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
