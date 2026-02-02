import 'package:drift/drift.dart';

class DbChapters extends Table {
  IntColumn get id => integer()();
  TextColumn get nameArabic => text()();
  TextColumn get nameSimple => text()();
  TextColumn get nameComplex => text().withDefault(const Constant(''))();
  IntColumn get versesCount => integer()();
  TextColumn get revelationPlace => text().withDefault(const Constant(''))();
  IntColumn get revelationOrder => integer().withDefault(const Constant(0))();
  BoolColumn get bismillahPre => boolean().withDefault(const Constant(true))();
  TextColumn get translatedName => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class DbVerses extends Table {
  IntColumn get id => integer()();
  IntColumn get chapterId => integer().references(DbChapters, #id)();
  IntColumn get verseNumber => integer()();
  TextColumn get verseKey => text()();
  TextColumn get textUthmani => text()();
  TextColumn get textUthmaniTajweed => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DbTranslations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get verseId => integer()();
  IntColumn get resourceId => integer()();
  TextColumn get translationText => text()();
}
