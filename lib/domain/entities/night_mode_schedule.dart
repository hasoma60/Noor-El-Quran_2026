import 'package:equatable/equatable.dart';

class NightModeSchedule extends Equatable {
  final bool enabled;
  final int startHour;
  final int endHour;

  const NightModeSchedule({
    this.enabled = false,
    this.startHour = 19,
    this.endHour = 6,
  });

  bool get isNightTime {
    final hour = DateTime.now().hour;
    if (startHour > endHour) {
      return hour >= startHour || hour < endHour;
    }
    return hour >= startHour && hour < endHour;
  }

  NightModeSchedule copyWith({
    bool? enabled,
    int? startHour,
    int? endHour,
  }) {
    return NightModeSchedule(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'startHour': startHour,
        'endHour': endHour,
      };

  factory NightModeSchedule.fromJson(Map<String, dynamic> json) {
    return NightModeSchedule(
      enabled: json['enabled'] as bool? ?? false,
      startHour: json['startHour'] as int? ?? 19,
      endHour: json['endHour'] as int? ?? 6,
    );
  }

  @override
  List<Object?> get props => [enabled, startHour, endHour];
}
