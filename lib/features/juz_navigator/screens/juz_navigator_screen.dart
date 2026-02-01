import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/utils/arabic_utils.dart';

class JuzNavigatorScreen extends StatelessWidget {
  const JuzNavigatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('فهرس الأجزاء'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: juzBoundaries.length,
        itemBuilder: (context, index) {
          final juz = juzBoundaries[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.pushNamed(
                  'reader',
                  pathParameters: {'chapterId': juz.chapterId.toString()},
                  queryParameters: {'verse': juz.verseKey},
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      toArabicNumeral(juz.juz),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      juz.name,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      juz.verseKey,
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
