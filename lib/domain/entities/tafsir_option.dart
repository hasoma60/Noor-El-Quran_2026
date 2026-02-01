import 'package:equatable/equatable.dart';

class TafsirOption extends Equatable {
  final int id;
  final String name;
  final String author;

  const TafsirOption({
    required this.id,
    required this.name,
    required this.author,
  });

  @override
  List<Object?> get props => [id];
}
