import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/progress_provider.dart';
import '../../home/providers/bookmark_provider.dart';
import '../../home/providers/chapters_provider.dart';
import '../../../core/utils/arabic_utils.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressProvider);
    final bookmarkState = ref.watch(bookmarkProvider);
    final chaptersAsync = ref.watch(chaptersProvider);
    final notifier = ref.read(progressProvider.notifier);
    final stats = progressState.stats;
    final overallProgress = notifier.getOverallProgress();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress ring
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: _ProgressRingPainter(
                        progress: overallProgress,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        progressColor: const Color(0xFFD97706),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(overallProgress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                      Text(
                        'من القرآن',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats grid (2x2)
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _StatCard(
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
                label: 'أيام متتالية',
                value: toArabicNumeral(stats.currentStreak),
                theme: theme,
              ),
              _StatCard(
                icon: Icons.check_circle_outline,
                iconColor: Colors.green,
                label: 'سور مكتملة',
                value: toArabicNumeral(stats.chaptersCompleted),
                theme: theme,
              ),
              _StatCard(
                icon: Icons.bookmark,
                iconColor: Colors.amber,
                label: 'المفضلات',
                value: toArabicNumeral(bookmarkState.bookmarks.length),
                theme: theme,
              ),
              _StatCard(
                icon: Icons.note_alt,
                iconColor: Colors.blue,
                label: 'الملاحظات',
                value: toArabicNumeral(bookmarkState.notes.length),
                theme: theme,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent readings
          Text(
            'آخر القراءات',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (progressState.progress.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'لم تقرأ أي سورة بعد',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            )
          else
            ...() {
              final entries = progressState.progress.entries.toList()
                ..sort((a, b) => b.value.lastReadAt.compareTo(a.value.lastReadAt));
              final topEntries = entries.take(10);

              return topEntries.map((entry) {
                final progress = entry.value;
                final percent = (progress.versesRead / progress.totalVerses * 100).round();

                return chaptersAsync.whenOrNull(
                      data: (chapters) {
                        final ch = chapters.where((c) => c.id == progress.chapterId).firstOrNull;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ch?.nameArabic ?? 'سورة ${progress.chapterId}',
                                          style: const TextStyle(
                                            fontFamily: 'Amiri',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${toArabicNumeral(progress.versesRead)} من ${toArabicNumeral(progress.totalVerses)} آية',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: progress.versesRead / progress.totalVerses,
                                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                            valueColor: AlwaysStoppedAnimation(
                                              percent >= 100 ? Colors.green : const Color(0xFFD97706),
                                            ),
                                            minHeight: 6,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$percent%',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: percent >= 100 ? Colors.green : Colors.amber[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ) ??
                    const SizedBox.shrink();
              });
            }(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final ThemeData theme;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
