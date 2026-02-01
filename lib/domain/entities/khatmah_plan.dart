import 'package:equatable/equatable.dart';

class KhatmahPlan extends Equatable {
  final String id;
  final String name;
  final int totalDays;
  final int startDate;
  final Map<String, bool> completedDays;
  final int currentDay;
  final List<DailyTarget> dailyTarget;

  const KhatmahPlan({
    required this.id,
    required this.name,
    required this.totalDays,
    required this.startDate,
    required this.completedDays,
    required this.currentDay,
    required this.dailyTarget,
  });

  double get progressPercent =>
      totalDays > 0 ? (currentDay / totalDays).clamp(0.0, 1.0) : 0.0;

  int get completedDaysCount =>
      completedDays.values.where((v) => v).length;

  KhatmahPlan copyWith({
    Map<String, bool>? completedDays,
    int? currentDay,
  }) {
    return KhatmahPlan(
      id: id,
      name: name,
      totalDays: totalDays,
      startDate: startDate,
      completedDays: completedDays ?? this.completedDays,
      currentDay: currentDay ?? this.currentDay,
      dailyTarget: dailyTarget,
    );
  }

  @override
  List<Object?> get props => [id];
}

class DailyTarget extends Equatable {
  final String fromVerse;
  final String toVerse;

  const DailyTarget({
    required this.fromVerse,
    required this.toVerse,
  });

  @override
  List<Object?> get props => [fromVerse, toVerse];
}
