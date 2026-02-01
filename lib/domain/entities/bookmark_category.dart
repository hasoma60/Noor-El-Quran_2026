import 'package:equatable/equatable.dart';

class BookmarkCategoryInfo extends Equatable {
  final String id;
  final String label;
  final String colorHex;

  const BookmarkCategoryInfo({
    required this.id,
    required this.label,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [id];
}
