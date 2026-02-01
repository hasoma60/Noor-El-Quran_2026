import '../../domain/entities/chapter.dart';

class ChapterModel extends Chapter {
  const ChapterModel({
    required super.id,
    required super.revelationPlace,
    required super.revelationOrder,
    required super.bismillahPre,
    required super.nameSimple,
    required super.nameComplex,
    required super.nameArabic,
    required super.versesCount,
    required super.translatedName,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as int,
      revelationPlace: json['revelation_place'] as String? ?? '',
      revelationOrder: json['revelation_order'] as int? ?? 0,
      bismillahPre: json['bismillah_pre'] as bool? ?? true,
      nameSimple: json['name_simple'] as String? ?? '',
      nameComplex: json['name_complex'] as String? ?? '',
      nameArabic: json['name_arabic'] as String? ?? '',
      versesCount: json['verses_count'] as int? ?? 0,
      translatedName: (json['translated_name'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'revelation_place': revelationPlace,
      'revelation_order': revelationOrder,
      'bismillah_pre': bismillahPre,
      'name_simple': nameSimple,
      'name_complex': nameComplex,
      'name_arabic': nameArabic,
      'verses_count': versesCount,
      'translated_name': {'name': translatedName},
    };
  }
}
