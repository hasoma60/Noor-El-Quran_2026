import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../home/providers/progress_provider.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../domain/entities/khatmah_plan.dart';

class KhatmahScreen extends ConsumerStatefulWidget {
  const KhatmahScreen({super.key});

  @override
  ConsumerState<KhatmahScreen> createState() => _KhatmahScreenState();
}

class _KhatmahScreenState extends ConsumerState<KhatmahScreen> {
  void _showCreateDialog() {
    final nameController = TextEditingController();
    int selectedDays = 30;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('خطة ختمة جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'اسم الخطة',
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              Text('مدة الختمة', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [7, 14, 30, 60].map((days) {
                  final selected = selectedDays == days;
                  return ChoiceChip(
                    label: Text('$days يوم'),
                    selected: selected,
                    onSelected: (_) => setDialogState(() => selectedDays = days),
                    selectedColor: const Color(0xFFD97706),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: selected ? FontWeight.bold : null,
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                'حوالي ${(6236 / selectedDays).ceil()} آية يوميًا',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                _createPlan(name, selectedDays);
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
  }

  void _createPlan(String name, int totalDays) {
    const totalVerses = 6236;
    final dailyTarget = <DailyTarget>[];
    final versesPerDay = (totalVerses / totalDays).ceil();

    var currentVerse = 1;
    for (var day = 0; day < totalDays; day++) {
      final from = currentVerse;
      final to = (currentVerse + versesPerDay - 1).clamp(1, totalVerses);
      dailyTarget.add(DailyTarget(fromVerse: '$from', toVerse: '$to'));
      currentVerse = to + 1;
      if (currentVerse > totalVerses) break;
    }

    final plan = KhatmahPlan(
      id: const Uuid().v4(),
      name: name,
      totalDays: totalDays,
      startDate: DateTime.now().millisecondsSinceEpoch,
      completedDays: const {},
      currentDay: 0,
      dailyTarget: dailyTarget,
    );

    final current = ref.read(progressProvider);
    final updated = [...current.khatmahPlans, plan];
    ref.read(progressLocalDataSourceProvider).saveKhatmahPlans(updated);
    ref.invalidate(progressProvider);
  }

  void _toggleDayCompletion(KhatmahPlan plan, int dayIndex) {
    final dayKey = dayIndex.toString();
    final updatedCompletedDays = Map<String, bool>.from(plan.completedDays);

    if (updatedCompletedDays[dayKey] == true) {
      updatedCompletedDays.remove(dayKey);
    } else {
      updatedCompletedDays[dayKey] = true;
    }

    // Calculate new currentDay based on completed days
    final newCurrentDay = updatedCompletedDays.values.where((v) => v).length;

    final updatedPlan = plan.copyWith(
      completedDays: updatedCompletedDays,
      currentDay: newCurrentDay,
    );

    final current = ref.read(progressProvider);
    final updatedPlans = current.khatmahPlans.map((p) {
      if (p.id == plan.id) return updatedPlan;
      return p;
    }).toList();

    ref.read(progressLocalDataSourceProvider).saveKhatmahPlans(updatedPlans);
    ref.invalidate(progressProvider);
  }

  void _deletePlan(String planId) {
    final current = ref.read(progressProvider);
    final updated = current.khatmahPlans.where((p) => p.id != planId).toList();
    ref.read(progressLocalDataSourceProvider).saveKhatmahPlans(updated);
    ref.invalidate(progressProvider);
  }

  void _showDeleteConfirmation(KhatmahPlan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الخطة'),
        content: Text('هل تريد حذف خطة "${plan.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _deletePlan(plan.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(progressProvider);
    final plans = progressState.khatmahPlans;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('خطة الختمة'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFFD97706),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('خطة جديدة'),
      ),
      body: plans.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.calendar_month_outlined,
              title: 'لا توجد خطط ختمة',
              description: 'أنشئ خطة لختم القرآن الكريم',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return _KhatmahPlanCard(
                  plan: plan,
                  theme: theme,
                  onToggleDay: (dayIndex) => _toggleDayCompletion(plan, dayIndex),
                  onDelete: () => _showDeleteConfirmation(plan),
                );
              },
            ),
    );
  }
}

class _KhatmahPlanCard extends StatefulWidget {
  final KhatmahPlan plan;
  final ThemeData theme;
  final ValueChanged<int> onToggleDay;
  final VoidCallback onDelete;

  const _KhatmahPlanCard({
    required this.plan,
    required this.theme,
    required this.onToggleDay,
    required this.onDelete,
  });

  @override
  State<_KhatmahPlanCard> createState() => _KhatmahPlanCardState();
}

class _KhatmahPlanCardState extends State<_KhatmahPlanCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final theme = widget.theme;
    final progress = plan.currentDay / plan.totalDays;

    // Calculate days since start
    final startDate = DateTime.fromMillisecondsSinceEpoch(plan.startDate);
    final daysSinceStart = DateTime.now().difference(startDate).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Delete button
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                      onPressed: widget.onDelete,
                      tooltip: 'حذف الخطة',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${toArabicNumeral(plan.currentDay)} / ${toArabicNumeral(plan.totalDays)} يوم',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[700],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'اليوم ${toArabicNumeral(daysSinceStart + 1)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      progress >= 1.0 ? Colors.green : const Color(0xFFD97706),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      progress >= 1.0
                          ? 'مكتملة! ✓'
                          : '${(progress * 100).round()}% مكتمل',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: progress >= 1.0 ? FontWeight.bold : null,
                        color: progress >= 1.0
                            ? Colors.green
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                      ),
                      label: Text(_expanded ? 'إخفاء الأيام' : 'عرض الأيام'),
                      onPressed: () => setState(() => _expanded = !_expanded),
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable day list
          if (_expanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: List.generate(
                  plan.dailyTarget.length.clamp(0, plan.totalDays),
                  (dayIndex) {
                    final isDone = plan.completedDays[dayIndex.toString()] == true;
                    return InkWell(
                      onTap: () => widget.onToggleDay(dayIndex),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDone
                              ? Colors.green.withValues(alpha: 0.15)
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: isDone
                              ? Border.all(color: Colors.green.withValues(alpha: 0.4))
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: isDone
                            ? const Icon(Icons.check, size: 18, color: Colors.green)
                            : Text(
                                toArabicNumeral(dayIndex + 1),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ] else
            const SizedBox(height: 12),
        ],
      ),
    );
  }
}
