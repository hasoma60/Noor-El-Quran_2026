import 'package:equatable/equatable.dart';

class ThematicTopic extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String description;
  final List<String> verses;

  const ThematicTopic({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.verses,
  });

  @override
  List<Object?> get props => [id];
}
