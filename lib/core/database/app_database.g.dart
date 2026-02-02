// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DbChaptersTable extends DbChapters
    with TableInfo<$DbChaptersTable, DbChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameArabicMeta =
      const VerificationMeta('nameArabic');
  @override
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
      'name_arabic', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameSimpleMeta =
      const VerificationMeta('nameSimple');
  @override
  late final GeneratedColumn<String> nameSimple = GeneratedColumn<String>(
      'name_simple', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameComplexMeta =
      const VerificationMeta('nameComplex');
  @override
  late final GeneratedColumn<String> nameComplex = GeneratedColumn<String>(
      'name_complex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _versesCountMeta =
      const VerificationMeta('versesCount');
  @override
  late final GeneratedColumn<int> versesCount = GeneratedColumn<int>(
      'verses_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _revelationPlaceMeta =
      const VerificationMeta('revelationPlace');
  @override
  late final GeneratedColumn<String> revelationPlace = GeneratedColumn<String>(
      'revelation_place', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _revelationOrderMeta =
      const VerificationMeta('revelationOrder');
  @override
  late final GeneratedColumn<int> revelationOrder = GeneratedColumn<int>(
      'revelation_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _bismillahPreMeta =
      const VerificationMeta('bismillahPre');
  @override
  late final GeneratedColumn<bool> bismillahPre = GeneratedColumn<bool>(
      'bismillah_pre', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("bismillah_pre" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _translatedNameMeta =
      const VerificationMeta('translatedName');
  @override
  late final GeneratedColumn<String> translatedName = GeneratedColumn<String>(
      'translated_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nameArabic,
        nameSimple,
        nameComplex,
        versesCount,
        revelationPlace,
        revelationOrder,
        bismillahPre,
        translatedName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_chapters';
  @override
  VerificationContext validateIntegrity(Insertable<DbChapter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
          _nameArabicMeta,
          nameArabic.isAcceptableOrUnknown(
              data['name_arabic']!, _nameArabicMeta));
    } else if (isInserting) {
      context.missing(_nameArabicMeta);
    }
    if (data.containsKey('name_simple')) {
      context.handle(
          _nameSimpleMeta,
          nameSimple.isAcceptableOrUnknown(
              data['name_simple']!, _nameSimpleMeta));
    } else if (isInserting) {
      context.missing(_nameSimpleMeta);
    }
    if (data.containsKey('name_complex')) {
      context.handle(
          _nameComplexMeta,
          nameComplex.isAcceptableOrUnknown(
              data['name_complex']!, _nameComplexMeta));
    }
    if (data.containsKey('verses_count')) {
      context.handle(
          _versesCountMeta,
          versesCount.isAcceptableOrUnknown(
              data['verses_count']!, _versesCountMeta));
    } else if (isInserting) {
      context.missing(_versesCountMeta);
    }
    if (data.containsKey('revelation_place')) {
      context.handle(
          _revelationPlaceMeta,
          revelationPlace.isAcceptableOrUnknown(
              data['revelation_place']!, _revelationPlaceMeta));
    }
    if (data.containsKey('revelation_order')) {
      context.handle(
          _revelationOrderMeta,
          revelationOrder.isAcceptableOrUnknown(
              data['revelation_order']!, _revelationOrderMeta));
    }
    if (data.containsKey('bismillah_pre')) {
      context.handle(
          _bismillahPreMeta,
          bismillahPre.isAcceptableOrUnknown(
              data['bismillah_pre']!, _bismillahPreMeta));
    }
    if (data.containsKey('translated_name')) {
      context.handle(
          _translatedNameMeta,
          translatedName.isAcceptableOrUnknown(
              data['translated_name']!, _translatedNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbChapter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nameArabic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_arabic'])!,
      nameSimple: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_simple'])!,
      nameComplex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_complex'])!,
      versesCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}verses_count'])!,
      revelationPlace: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}revelation_place'])!,
      revelationOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revelation_order'])!,
      bismillahPre: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}bismillah_pre'])!,
      translatedName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}translated_name'])!,
    );
  }

  @override
  $DbChaptersTable createAlias(String alias) {
    return $DbChaptersTable(attachedDatabase, alias);
  }
}

class DbChapter extends DataClass implements Insertable<DbChapter> {
  final int id;
  final String nameArabic;
  final String nameSimple;
  final String nameComplex;
  final int versesCount;
  final String revelationPlace;
  final int revelationOrder;
  final bool bismillahPre;
  final String translatedName;
  const DbChapter(
      {required this.id,
      required this.nameArabic,
      required this.nameSimple,
      required this.nameComplex,
      required this.versesCount,
      required this.revelationPlace,
      required this.revelationOrder,
      required this.bismillahPre,
      required this.translatedName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name_arabic'] = Variable<String>(nameArabic);
    map['name_simple'] = Variable<String>(nameSimple);
    map['name_complex'] = Variable<String>(nameComplex);
    map['verses_count'] = Variable<int>(versesCount);
    map['revelation_place'] = Variable<String>(revelationPlace);
    map['revelation_order'] = Variable<int>(revelationOrder);
    map['bismillah_pre'] = Variable<bool>(bismillahPre);
    map['translated_name'] = Variable<String>(translatedName);
    return map;
  }

  DbChaptersCompanion toCompanion(bool nullToAbsent) {
    return DbChaptersCompanion(
      id: Value(id),
      nameArabic: Value(nameArabic),
      nameSimple: Value(nameSimple),
      nameComplex: Value(nameComplex),
      versesCount: Value(versesCount),
      revelationPlace: Value(revelationPlace),
      revelationOrder: Value(revelationOrder),
      bismillahPre: Value(bismillahPre),
      translatedName: Value(translatedName),
    );
  }

  factory DbChapter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbChapter(
      id: serializer.fromJson<int>(json['id']),
      nameArabic: serializer.fromJson<String>(json['nameArabic']),
      nameSimple: serializer.fromJson<String>(json['nameSimple']),
      nameComplex: serializer.fromJson<String>(json['nameComplex']),
      versesCount: serializer.fromJson<int>(json['versesCount']),
      revelationPlace: serializer.fromJson<String>(json['revelationPlace']),
      revelationOrder: serializer.fromJson<int>(json['revelationOrder']),
      bismillahPre: serializer.fromJson<bool>(json['bismillahPre']),
      translatedName: serializer.fromJson<String>(json['translatedName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nameArabic': serializer.toJson<String>(nameArabic),
      'nameSimple': serializer.toJson<String>(nameSimple),
      'nameComplex': serializer.toJson<String>(nameComplex),
      'versesCount': serializer.toJson<int>(versesCount),
      'revelationPlace': serializer.toJson<String>(revelationPlace),
      'revelationOrder': serializer.toJson<int>(revelationOrder),
      'bismillahPre': serializer.toJson<bool>(bismillahPre),
      'translatedName': serializer.toJson<String>(translatedName),
    };
  }

  DbChapter copyWith(
          {int? id,
          String? nameArabic,
          String? nameSimple,
          String? nameComplex,
          int? versesCount,
          String? revelationPlace,
          int? revelationOrder,
          bool? bismillahPre,
          String? translatedName}) =>
      DbChapter(
        id: id ?? this.id,
        nameArabic: nameArabic ?? this.nameArabic,
        nameSimple: nameSimple ?? this.nameSimple,
        nameComplex: nameComplex ?? this.nameComplex,
        versesCount: versesCount ?? this.versesCount,
        revelationPlace: revelationPlace ?? this.revelationPlace,
        revelationOrder: revelationOrder ?? this.revelationOrder,
        bismillahPre: bismillahPre ?? this.bismillahPre,
        translatedName: translatedName ?? this.translatedName,
      );
  DbChapter copyWithCompanion(DbChaptersCompanion data) {
    return DbChapter(
      id: data.id.present ? data.id.value : this.id,
      nameArabic:
          data.nameArabic.present ? data.nameArabic.value : this.nameArabic,
      nameSimple:
          data.nameSimple.present ? data.nameSimple.value : this.nameSimple,
      nameComplex:
          data.nameComplex.present ? data.nameComplex.value : this.nameComplex,
      versesCount:
          data.versesCount.present ? data.versesCount.value : this.versesCount,
      revelationPlace: data.revelationPlace.present
          ? data.revelationPlace.value
          : this.revelationPlace,
      revelationOrder: data.revelationOrder.present
          ? data.revelationOrder.value
          : this.revelationOrder,
      bismillahPre: data.bismillahPre.present
          ? data.bismillahPre.value
          : this.bismillahPre,
      translatedName: data.translatedName.present
          ? data.translatedName.value
          : this.translatedName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbChapter(')
          ..write('id: $id, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameSimple: $nameSimple, ')
          ..write('nameComplex: $nameComplex, ')
          ..write('versesCount: $versesCount, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('revelationOrder: $revelationOrder, ')
          ..write('bismillahPre: $bismillahPre, ')
          ..write('translatedName: $translatedName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      nameArabic,
      nameSimple,
      nameComplex,
      versesCount,
      revelationPlace,
      revelationOrder,
      bismillahPre,
      translatedName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbChapter &&
          other.id == this.id &&
          other.nameArabic == this.nameArabic &&
          other.nameSimple == this.nameSimple &&
          other.nameComplex == this.nameComplex &&
          other.versesCount == this.versesCount &&
          other.revelationPlace == this.revelationPlace &&
          other.revelationOrder == this.revelationOrder &&
          other.bismillahPre == this.bismillahPre &&
          other.translatedName == this.translatedName);
}

class DbChaptersCompanion extends UpdateCompanion<DbChapter> {
  final Value<int> id;
  final Value<String> nameArabic;
  final Value<String> nameSimple;
  final Value<String> nameComplex;
  final Value<int> versesCount;
  final Value<String> revelationPlace;
  final Value<int> revelationOrder;
  final Value<bool> bismillahPre;
  final Value<String> translatedName;
  const DbChaptersCompanion({
    this.id = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.nameSimple = const Value.absent(),
    this.nameComplex = const Value.absent(),
    this.versesCount = const Value.absent(),
    this.revelationPlace = const Value.absent(),
    this.revelationOrder = const Value.absent(),
    this.bismillahPre = const Value.absent(),
    this.translatedName = const Value.absent(),
  });
  DbChaptersCompanion.insert({
    this.id = const Value.absent(),
    required String nameArabic,
    required String nameSimple,
    this.nameComplex = const Value.absent(),
    required int versesCount,
    this.revelationPlace = const Value.absent(),
    this.revelationOrder = const Value.absent(),
    this.bismillahPre = const Value.absent(),
    this.translatedName = const Value.absent(),
  })  : nameArabic = Value(nameArabic),
        nameSimple = Value(nameSimple),
        versesCount = Value(versesCount);
  static Insertable<DbChapter> custom({
    Expression<int>? id,
    Expression<String>? nameArabic,
    Expression<String>? nameSimple,
    Expression<String>? nameComplex,
    Expression<int>? versesCount,
    Expression<String>? revelationPlace,
    Expression<int>? revelationOrder,
    Expression<bool>? bismillahPre,
    Expression<String>? translatedName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (nameSimple != null) 'name_simple': nameSimple,
      if (nameComplex != null) 'name_complex': nameComplex,
      if (versesCount != null) 'verses_count': versesCount,
      if (revelationPlace != null) 'revelation_place': revelationPlace,
      if (revelationOrder != null) 'revelation_order': revelationOrder,
      if (bismillahPre != null) 'bismillah_pre': bismillahPre,
      if (translatedName != null) 'translated_name': translatedName,
    });
  }

  DbChaptersCompanion copyWith(
      {Value<int>? id,
      Value<String>? nameArabic,
      Value<String>? nameSimple,
      Value<String>? nameComplex,
      Value<int>? versesCount,
      Value<String>? revelationPlace,
      Value<int>? revelationOrder,
      Value<bool>? bismillahPre,
      Value<String>? translatedName}) {
    return DbChaptersCompanion(
      id: id ?? this.id,
      nameArabic: nameArabic ?? this.nameArabic,
      nameSimple: nameSimple ?? this.nameSimple,
      nameComplex: nameComplex ?? this.nameComplex,
      versesCount: versesCount ?? this.versesCount,
      revelationPlace: revelationPlace ?? this.revelationPlace,
      revelationOrder: revelationOrder ?? this.revelationOrder,
      bismillahPre: bismillahPre ?? this.bismillahPre,
      translatedName: translatedName ?? this.translatedName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (nameSimple.present) {
      map['name_simple'] = Variable<String>(nameSimple.value);
    }
    if (nameComplex.present) {
      map['name_complex'] = Variable<String>(nameComplex.value);
    }
    if (versesCount.present) {
      map['verses_count'] = Variable<int>(versesCount.value);
    }
    if (revelationPlace.present) {
      map['revelation_place'] = Variable<String>(revelationPlace.value);
    }
    if (revelationOrder.present) {
      map['revelation_order'] = Variable<int>(revelationOrder.value);
    }
    if (bismillahPre.present) {
      map['bismillah_pre'] = Variable<bool>(bismillahPre.value);
    }
    if (translatedName.present) {
      map['translated_name'] = Variable<String>(translatedName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbChaptersCompanion(')
          ..write('id: $id, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameSimple: $nameSimple, ')
          ..write('nameComplex: $nameComplex, ')
          ..write('versesCount: $versesCount, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('revelationOrder: $revelationOrder, ')
          ..write('bismillahPre: $bismillahPre, ')
          ..write('translatedName: $translatedName')
          ..write(')'))
        .toString();
  }
}

class $DbVersesTable extends DbVerses with TableInfo<$DbVersesTable, DbVerse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbVersesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES db_chapters (id)'));
  static const VerificationMeta _verseNumberMeta =
      const VerificationMeta('verseNumber');
  @override
  late final GeneratedColumn<int> verseNumber = GeneratedColumn<int>(
      'verse_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _verseKeyMeta =
      const VerificationMeta('verseKey');
  @override
  late final GeneratedColumn<String> verseKey = GeneratedColumn<String>(
      'verse_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textUthmaniMeta =
      const VerificationMeta('textUthmani');
  @override
  late final GeneratedColumn<String> textUthmani = GeneratedColumn<String>(
      'text_uthmani', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textUthmaniTajweedMeta =
      const VerificationMeta('textUthmaniTajweed');
  @override
  late final GeneratedColumn<String> textUthmaniTajweed =
      GeneratedColumn<String>('text_uthmani_tajweed', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, chapterId, verseNumber, verseKey, textUthmani, textUthmaniTajweed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_verses';
  @override
  VerificationContext validateIntegrity(Insertable<DbVerse> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('verse_number')) {
      context.handle(
          _verseNumberMeta,
          verseNumber.isAcceptableOrUnknown(
              data['verse_number']!, _verseNumberMeta));
    } else if (isInserting) {
      context.missing(_verseNumberMeta);
    }
    if (data.containsKey('verse_key')) {
      context.handle(_verseKeyMeta,
          verseKey.isAcceptableOrUnknown(data['verse_key']!, _verseKeyMeta));
    } else if (isInserting) {
      context.missing(_verseKeyMeta);
    }
    if (data.containsKey('text_uthmani')) {
      context.handle(
          _textUthmaniMeta,
          textUthmani.isAcceptableOrUnknown(
              data['text_uthmani']!, _textUthmaniMeta));
    } else if (isInserting) {
      context.missing(_textUthmaniMeta);
    }
    if (data.containsKey('text_uthmani_tajweed')) {
      context.handle(
          _textUthmaniTajweedMeta,
          textUthmaniTajweed.isAcceptableOrUnknown(
              data['text_uthmani_tajweed']!, _textUthmaniTajweedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbVerse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbVerse(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_id'])!,
      verseNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}verse_number'])!,
      verseKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verse_key'])!,
      textUthmani: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_uthmani'])!,
      textUthmaniTajweed: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}text_uthmani_tajweed']),
    );
  }

  @override
  $DbVersesTable createAlias(String alias) {
    return $DbVersesTable(attachedDatabase, alias);
  }
}

class DbVerse extends DataClass implements Insertable<DbVerse> {
  final int id;
  final int chapterId;
  final int verseNumber;
  final String verseKey;
  final String textUthmani;
  final String? textUthmaniTajweed;
  const DbVerse(
      {required this.id,
      required this.chapterId,
      required this.verseNumber,
      required this.verseKey,
      required this.textUthmani,
      this.textUthmaniTajweed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chapter_id'] = Variable<int>(chapterId);
    map['verse_number'] = Variable<int>(verseNumber);
    map['verse_key'] = Variable<String>(verseKey);
    map['text_uthmani'] = Variable<String>(textUthmani);
    if (!nullToAbsent || textUthmaniTajweed != null) {
      map['text_uthmani_tajweed'] = Variable<String>(textUthmaniTajweed);
    }
    return map;
  }

  DbVersesCompanion toCompanion(bool nullToAbsent) {
    return DbVersesCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      verseNumber: Value(verseNumber),
      verseKey: Value(verseKey),
      textUthmani: Value(textUthmani),
      textUthmaniTajweed: textUthmaniTajweed == null && nullToAbsent
          ? const Value.absent()
          : Value(textUthmaniTajweed),
    );
  }

  factory DbVerse.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbVerse(
      id: serializer.fromJson<int>(json['id']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      verseNumber: serializer.fromJson<int>(json['verseNumber']),
      verseKey: serializer.fromJson<String>(json['verseKey']),
      textUthmani: serializer.fromJson<String>(json['textUthmani']),
      textUthmaniTajweed:
          serializer.fromJson<String?>(json['textUthmaniTajweed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chapterId': serializer.toJson<int>(chapterId),
      'verseNumber': serializer.toJson<int>(verseNumber),
      'verseKey': serializer.toJson<String>(verseKey),
      'textUthmani': serializer.toJson<String>(textUthmani),
      'textUthmaniTajweed': serializer.toJson<String?>(textUthmaniTajweed),
    };
  }

  DbVerse copyWith(
          {int? id,
          int? chapterId,
          int? verseNumber,
          String? verseKey,
          String? textUthmani,
          Value<String?> textUthmaniTajweed = const Value.absent()}) =>
      DbVerse(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        verseNumber: verseNumber ?? this.verseNumber,
        verseKey: verseKey ?? this.verseKey,
        textUthmani: textUthmani ?? this.textUthmani,
        textUthmaniTajweed: textUthmaniTajweed.present
            ? textUthmaniTajweed.value
            : this.textUthmaniTajweed,
      );
  DbVerse copyWithCompanion(DbVersesCompanion data) {
    return DbVerse(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      verseNumber:
          data.verseNumber.present ? data.verseNumber.value : this.verseNumber,
      verseKey: data.verseKey.present ? data.verseKey.value : this.verseKey,
      textUthmani:
          data.textUthmani.present ? data.textUthmani.value : this.textUthmani,
      textUthmaniTajweed: data.textUthmaniTajweed.present
          ? data.textUthmaniTajweed.value
          : this.textUthmaniTajweed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbVerse(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('verseKey: $verseKey, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('textUthmaniTajweed: $textUthmaniTajweed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, chapterId, verseNumber, verseKey, textUthmani, textUthmaniTajweed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbVerse &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.verseNumber == this.verseNumber &&
          other.verseKey == this.verseKey &&
          other.textUthmani == this.textUthmani &&
          other.textUthmaniTajweed == this.textUthmaniTajweed);
}

class DbVersesCompanion extends UpdateCompanion<DbVerse> {
  final Value<int> id;
  final Value<int> chapterId;
  final Value<int> verseNumber;
  final Value<String> verseKey;
  final Value<String> textUthmani;
  final Value<String?> textUthmaniTajweed;
  const DbVersesCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.verseNumber = const Value.absent(),
    this.verseKey = const Value.absent(),
    this.textUthmani = const Value.absent(),
    this.textUthmaniTajweed = const Value.absent(),
  });
  DbVersesCompanion.insert({
    this.id = const Value.absent(),
    required int chapterId,
    required int verseNumber,
    required String verseKey,
    required String textUthmani,
    this.textUthmaniTajweed = const Value.absent(),
  })  : chapterId = Value(chapterId),
        verseNumber = Value(verseNumber),
        verseKey = Value(verseKey),
        textUthmani = Value(textUthmani);
  static Insertable<DbVerse> custom({
    Expression<int>? id,
    Expression<int>? chapterId,
    Expression<int>? verseNumber,
    Expression<String>? verseKey,
    Expression<String>? textUthmani,
    Expression<String>? textUthmaniTajweed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (verseNumber != null) 'verse_number': verseNumber,
      if (verseKey != null) 'verse_key': verseKey,
      if (textUthmani != null) 'text_uthmani': textUthmani,
      if (textUthmaniTajweed != null)
        'text_uthmani_tajweed': textUthmaniTajweed,
    });
  }

  DbVersesCompanion copyWith(
      {Value<int>? id,
      Value<int>? chapterId,
      Value<int>? verseNumber,
      Value<String>? verseKey,
      Value<String>? textUthmani,
      Value<String?>? textUthmaniTajweed}) {
    return DbVersesCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      verseNumber: verseNumber ?? this.verseNumber,
      verseKey: verseKey ?? this.verseKey,
      textUthmani: textUthmani ?? this.textUthmani,
      textUthmaniTajweed: textUthmaniTajweed ?? this.textUthmaniTajweed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (verseNumber.present) {
      map['verse_number'] = Variable<int>(verseNumber.value);
    }
    if (verseKey.present) {
      map['verse_key'] = Variable<String>(verseKey.value);
    }
    if (textUthmani.present) {
      map['text_uthmani'] = Variable<String>(textUthmani.value);
    }
    if (textUthmaniTajweed.present) {
      map['text_uthmani_tajweed'] = Variable<String>(textUthmaniTajweed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbVersesCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('verseKey: $verseKey, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('textUthmaniTajweed: $textUthmaniTajweed')
          ..write(')'))
        .toString();
  }
}

class $DbTranslationsTable extends DbTranslations
    with TableInfo<$DbTranslationsTable, DbTranslation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbTranslationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _verseIdMeta =
      const VerificationMeta('verseId');
  @override
  late final GeneratedColumn<int> verseId = GeneratedColumn<int>(
      'verse_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _resourceIdMeta =
      const VerificationMeta('resourceId');
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
      'resource_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _translationTextMeta =
      const VerificationMeta('translationText');
  @override
  late final GeneratedColumn<String> translationText = GeneratedColumn<String>(
      'translation_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, verseId, resourceId, translationText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_translations';
  @override
  VerificationContext validateIntegrity(Insertable<DbTranslation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('verse_id')) {
      context.handle(_verseIdMeta,
          verseId.isAcceptableOrUnknown(data['verse_id']!, _verseIdMeta));
    } else if (isInserting) {
      context.missing(_verseIdMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
          _resourceIdMeta,
          resourceId.isAcceptableOrUnknown(
              data['resource_id']!, _resourceIdMeta));
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('translation_text')) {
      context.handle(
          _translationTextMeta,
          translationText.isAcceptableOrUnknown(
              data['translation_text']!, _translationTextMeta));
    } else if (isInserting) {
      context.missing(_translationTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTranslation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTranslation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      verseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}verse_id'])!,
      resourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}resource_id'])!,
      translationText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}translation_text'])!,
    );
  }

  @override
  $DbTranslationsTable createAlias(String alias) {
    return $DbTranslationsTable(attachedDatabase, alias);
  }
}

class DbTranslation extends DataClass implements Insertable<DbTranslation> {
  final int id;
  final int verseId;
  final int resourceId;
  final String translationText;
  const DbTranslation(
      {required this.id,
      required this.verseId,
      required this.resourceId,
      required this.translationText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['verse_id'] = Variable<int>(verseId);
    map['resource_id'] = Variable<int>(resourceId);
    map['translation_text'] = Variable<String>(translationText);
    return map;
  }

  DbTranslationsCompanion toCompanion(bool nullToAbsent) {
    return DbTranslationsCompanion(
      id: Value(id),
      verseId: Value(verseId),
      resourceId: Value(resourceId),
      translationText: Value(translationText),
    );
  }

  factory DbTranslation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTranslation(
      id: serializer.fromJson<int>(json['id']),
      verseId: serializer.fromJson<int>(json['verseId']),
      resourceId: serializer.fromJson<int>(json['resourceId']),
      translationText: serializer.fromJson<String>(json['translationText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'verseId': serializer.toJson<int>(verseId),
      'resourceId': serializer.toJson<int>(resourceId),
      'translationText': serializer.toJson<String>(translationText),
    };
  }

  DbTranslation copyWith(
          {int? id, int? verseId, int? resourceId, String? translationText}) =>
      DbTranslation(
        id: id ?? this.id,
        verseId: verseId ?? this.verseId,
        resourceId: resourceId ?? this.resourceId,
        translationText: translationText ?? this.translationText,
      );
  DbTranslation copyWithCompanion(DbTranslationsCompanion data) {
    return DbTranslation(
      id: data.id.present ? data.id.value : this.id,
      verseId: data.verseId.present ? data.verseId.value : this.verseId,
      resourceId:
          data.resourceId.present ? data.resourceId.value : this.resourceId,
      translationText: data.translationText.present
          ? data.translationText.value
          : this.translationText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTranslation(')
          ..write('id: $id, ')
          ..write('verseId: $verseId, ')
          ..write('resourceId: $resourceId, ')
          ..write('translationText: $translationText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, verseId, resourceId, translationText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTranslation &&
          other.id == this.id &&
          other.verseId == this.verseId &&
          other.resourceId == this.resourceId &&
          other.translationText == this.translationText);
}

class DbTranslationsCompanion extends UpdateCompanion<DbTranslation> {
  final Value<int> id;
  final Value<int> verseId;
  final Value<int> resourceId;
  final Value<String> translationText;
  const DbTranslationsCompanion({
    this.id = const Value.absent(),
    this.verseId = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.translationText = const Value.absent(),
  });
  DbTranslationsCompanion.insert({
    this.id = const Value.absent(),
    required int verseId,
    required int resourceId,
    required String translationText,
  })  : verseId = Value(verseId),
        resourceId = Value(resourceId),
        translationText = Value(translationText);
  static Insertable<DbTranslation> custom({
    Expression<int>? id,
    Expression<int>? verseId,
    Expression<int>? resourceId,
    Expression<String>? translationText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (verseId != null) 'verse_id': verseId,
      if (resourceId != null) 'resource_id': resourceId,
      if (translationText != null) 'translation_text': translationText,
    });
  }

  DbTranslationsCompanion copyWith(
      {Value<int>? id,
      Value<int>? verseId,
      Value<int>? resourceId,
      Value<String>? translationText}) {
    return DbTranslationsCompanion(
      id: id ?? this.id,
      verseId: verseId ?? this.verseId,
      resourceId: resourceId ?? this.resourceId,
      translationText: translationText ?? this.translationText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (verseId.present) {
      map['verse_id'] = Variable<int>(verseId.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (translationText.present) {
      map['translation_text'] = Variable<String>(translationText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbTranslationsCompanion(')
          ..write('id: $id, ')
          ..write('verseId: $verseId, ')
          ..write('resourceId: $resourceId, ')
          ..write('translationText: $translationText')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DbChaptersTable dbChapters = $DbChaptersTable(this);
  late final $DbVersesTable dbVerses = $DbVersesTable(this);
  late final $DbTranslationsTable dbTranslations = $DbTranslationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [dbChapters, dbVerses, dbTranslations];
}

typedef $$DbChaptersTableCreateCompanionBuilder = DbChaptersCompanion Function({
  Value<int> id,
  required String nameArabic,
  required String nameSimple,
  Value<String> nameComplex,
  required int versesCount,
  Value<String> revelationPlace,
  Value<int> revelationOrder,
  Value<bool> bismillahPre,
  Value<String> translatedName,
});
typedef $$DbChaptersTableUpdateCompanionBuilder = DbChaptersCompanion Function({
  Value<int> id,
  Value<String> nameArabic,
  Value<String> nameSimple,
  Value<String> nameComplex,
  Value<int> versesCount,
  Value<String> revelationPlace,
  Value<int> revelationOrder,
  Value<bool> bismillahPre,
  Value<String> translatedName,
});

final class $$DbChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $DbChaptersTable, DbChapter> {
  $$DbChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DbVersesTable, List<DbVerse>> _dbVersesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.dbVerses,
          aliasName:
              $_aliasNameGenerator(db.dbChapters.id, db.dbVerses.chapterId));

  $$DbVersesTableProcessedTableManager get dbVersesRefs {
    final manager = $$DbVersesTableTableManager($_db, $_db.dbVerses)
        .filter((f) => f.chapterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbVersesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DbChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $DbChaptersTable> {
  $$DbChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameArabic => $composableBuilder(
      column: $table.nameArabic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameSimple => $composableBuilder(
      column: $table.nameSimple, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameComplex => $composableBuilder(
      column: $table.nameComplex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get versesCount => $composableBuilder(
      column: $table.versesCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get revelationPlace => $composableBuilder(
      column: $table.revelationPlace,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revelationOrder => $composableBuilder(
      column: $table.revelationOrder,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get bismillahPre => $composableBuilder(
      column: $table.bismillahPre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get translatedName => $composableBuilder(
      column: $table.translatedName,
      builder: (column) => ColumnFilters(column));

  Expression<bool> dbVersesRefs(
      Expression<bool> Function($$DbVersesTableFilterComposer f) f) {
    final $$DbVersesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbVerses,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbVersesTableFilterComposer(
              $db: $db,
              $table: $db.dbVerses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DbChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $DbChaptersTable> {
  $$DbChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameArabic => $composableBuilder(
      column: $table.nameArabic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameSimple => $composableBuilder(
      column: $table.nameSimple, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameComplex => $composableBuilder(
      column: $table.nameComplex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get versesCount => $composableBuilder(
      column: $table.versesCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get revelationPlace => $composableBuilder(
      column: $table.revelationPlace,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revelationOrder => $composableBuilder(
      column: $table.revelationOrder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get bismillahPre => $composableBuilder(
      column: $table.bismillahPre,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translatedName => $composableBuilder(
      column: $table.translatedName,
      builder: (column) => ColumnOrderings(column));
}

class $$DbChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbChaptersTable> {
  $$DbChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameArabic => $composableBuilder(
      column: $table.nameArabic, builder: (column) => column);

  GeneratedColumn<String> get nameSimple => $composableBuilder(
      column: $table.nameSimple, builder: (column) => column);

  GeneratedColumn<String> get nameComplex => $composableBuilder(
      column: $table.nameComplex, builder: (column) => column);

  GeneratedColumn<int> get versesCount => $composableBuilder(
      column: $table.versesCount, builder: (column) => column);

  GeneratedColumn<String> get revelationPlace => $composableBuilder(
      column: $table.revelationPlace, builder: (column) => column);

  GeneratedColumn<int> get revelationOrder => $composableBuilder(
      column: $table.revelationOrder, builder: (column) => column);

  GeneratedColumn<bool> get bismillahPre => $composableBuilder(
      column: $table.bismillahPre, builder: (column) => column);

  GeneratedColumn<String> get translatedName => $composableBuilder(
      column: $table.translatedName, builder: (column) => column);

  Expression<T> dbVersesRefs<T extends Object>(
      Expression<T> Function($$DbVersesTableAnnotationComposer a) f) {
    final $$DbVersesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbVerses,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbVersesTableAnnotationComposer(
              $db: $db,
              $table: $db.dbVerses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DbChaptersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DbChaptersTable,
    DbChapter,
    $$DbChaptersTableFilterComposer,
    $$DbChaptersTableOrderingComposer,
    $$DbChaptersTableAnnotationComposer,
    $$DbChaptersTableCreateCompanionBuilder,
    $$DbChaptersTableUpdateCompanionBuilder,
    (DbChapter, $$DbChaptersTableReferences),
    DbChapter,
    PrefetchHooks Function({bool dbVersesRefs})> {
  $$DbChaptersTableTableManager(_$AppDatabase db, $DbChaptersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nameArabic = const Value.absent(),
            Value<String> nameSimple = const Value.absent(),
            Value<String> nameComplex = const Value.absent(),
            Value<int> versesCount = const Value.absent(),
            Value<String> revelationPlace = const Value.absent(),
            Value<int> revelationOrder = const Value.absent(),
            Value<bool> bismillahPre = const Value.absent(),
            Value<String> translatedName = const Value.absent(),
          }) =>
              DbChaptersCompanion(
            id: id,
            nameArabic: nameArabic,
            nameSimple: nameSimple,
            nameComplex: nameComplex,
            versesCount: versesCount,
            revelationPlace: revelationPlace,
            revelationOrder: revelationOrder,
            bismillahPre: bismillahPre,
            translatedName: translatedName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nameArabic,
            required String nameSimple,
            Value<String> nameComplex = const Value.absent(),
            required int versesCount,
            Value<String> revelationPlace = const Value.absent(),
            Value<int> revelationOrder = const Value.absent(),
            Value<bool> bismillahPre = const Value.absent(),
            Value<String> translatedName = const Value.absent(),
          }) =>
              DbChaptersCompanion.insert(
            id: id,
            nameArabic: nameArabic,
            nameSimple: nameSimple,
            nameComplex: nameComplex,
            versesCount: versesCount,
            revelationPlace: revelationPlace,
            revelationOrder: revelationOrder,
            bismillahPre: bismillahPre,
            translatedName: translatedName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DbChaptersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({dbVersesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dbVersesRefs) db.dbVerses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dbVersesRefs)
                    await $_getPrefetchedData<DbChapter, $DbChaptersTable,
                            DbVerse>(
                        currentTable: table,
                        referencedTable:
                            $$DbChaptersTableReferences._dbVersesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DbChaptersTableReferences(db, table, p0)
                                .dbVersesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DbChaptersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DbChaptersTable,
    DbChapter,
    $$DbChaptersTableFilterComposer,
    $$DbChaptersTableOrderingComposer,
    $$DbChaptersTableAnnotationComposer,
    $$DbChaptersTableCreateCompanionBuilder,
    $$DbChaptersTableUpdateCompanionBuilder,
    (DbChapter, $$DbChaptersTableReferences),
    DbChapter,
    PrefetchHooks Function({bool dbVersesRefs})>;
typedef $$DbVersesTableCreateCompanionBuilder = DbVersesCompanion Function({
  Value<int> id,
  required int chapterId,
  required int verseNumber,
  required String verseKey,
  required String textUthmani,
  Value<String?> textUthmaniTajweed,
});
typedef $$DbVersesTableUpdateCompanionBuilder = DbVersesCompanion Function({
  Value<int> id,
  Value<int> chapterId,
  Value<int> verseNumber,
  Value<String> verseKey,
  Value<String> textUthmani,
  Value<String?> textUthmaniTajweed,
});

final class $$DbVersesTableReferences
    extends BaseReferences<_$AppDatabase, $DbVersesTable, DbVerse> {
  $$DbVersesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DbChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.dbChapters.createAlias(
          $_aliasNameGenerator(db.dbVerses.chapterId, db.dbChapters.id));

  $$DbChaptersTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<int>('chapter_id')!;

    final manager = $$DbChaptersTableTableManager($_db, $_db.dbChapters)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DbVersesTableFilterComposer
    extends Composer<_$AppDatabase, $DbVersesTable> {
  $$DbVersesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get verseNumber => $composableBuilder(
      column: $table.verseNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verseKey => $composableBuilder(
      column: $table.verseKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textUthmani => $composableBuilder(
      column: $table.textUthmani, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textUthmaniTajweed => $composableBuilder(
      column: $table.textUthmaniTajweed,
      builder: (column) => ColumnFilters(column));

  $$DbChaptersTableFilterComposer get chapterId {
    final $$DbChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.dbChapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbChaptersTableFilterComposer(
              $db: $db,
              $table: $db.dbChapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DbVersesTableOrderingComposer
    extends Composer<_$AppDatabase, $DbVersesTable> {
  $$DbVersesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get verseNumber => $composableBuilder(
      column: $table.verseNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verseKey => $composableBuilder(
      column: $table.verseKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textUthmani => $composableBuilder(
      column: $table.textUthmani, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textUthmaniTajweed => $composableBuilder(
      column: $table.textUthmaniTajweed,
      builder: (column) => ColumnOrderings(column));

  $$DbChaptersTableOrderingComposer get chapterId {
    final $$DbChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.dbChapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.dbChapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DbVersesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbVersesTable> {
  $$DbVersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get verseNumber => $composableBuilder(
      column: $table.verseNumber, builder: (column) => column);

  GeneratedColumn<String> get verseKey =>
      $composableBuilder(column: $table.verseKey, builder: (column) => column);

  GeneratedColumn<String> get textUthmani => $composableBuilder(
      column: $table.textUthmani, builder: (column) => column);

  GeneratedColumn<String> get textUthmaniTajweed => $composableBuilder(
      column: $table.textUthmaniTajweed, builder: (column) => column);

  $$DbChaptersTableAnnotationComposer get chapterId {
    final $$DbChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.dbChapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.dbChapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DbVersesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DbVersesTable,
    DbVerse,
    $$DbVersesTableFilterComposer,
    $$DbVersesTableOrderingComposer,
    $$DbVersesTableAnnotationComposer,
    $$DbVersesTableCreateCompanionBuilder,
    $$DbVersesTableUpdateCompanionBuilder,
    (DbVerse, $$DbVersesTableReferences),
    DbVerse,
    PrefetchHooks Function({bool chapterId})> {
  $$DbVersesTableTableManager(_$AppDatabase db, $DbVersesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbVersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbVersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbVersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> chapterId = const Value.absent(),
            Value<int> verseNumber = const Value.absent(),
            Value<String> verseKey = const Value.absent(),
            Value<String> textUthmani = const Value.absent(),
            Value<String?> textUthmaniTajweed = const Value.absent(),
          }) =>
              DbVersesCompanion(
            id: id,
            chapterId: chapterId,
            verseNumber: verseNumber,
            verseKey: verseKey,
            textUthmani: textUthmani,
            textUthmaniTajweed: textUthmaniTajweed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int chapterId,
            required int verseNumber,
            required String verseKey,
            required String textUthmani,
            Value<String?> textUthmaniTajweed = const Value.absent(),
          }) =>
              DbVersesCompanion.insert(
            id: id,
            chapterId: chapterId,
            verseNumber: verseNumber,
            verseKey: verseKey,
            textUthmani: textUthmani,
            textUthmaniTajweed: textUthmaniTajweed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DbVersesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$DbVersesTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$DbVersesTableReferences._chapterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DbVersesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DbVersesTable,
    DbVerse,
    $$DbVersesTableFilterComposer,
    $$DbVersesTableOrderingComposer,
    $$DbVersesTableAnnotationComposer,
    $$DbVersesTableCreateCompanionBuilder,
    $$DbVersesTableUpdateCompanionBuilder,
    (DbVerse, $$DbVersesTableReferences),
    DbVerse,
    PrefetchHooks Function({bool chapterId})>;
typedef $$DbTranslationsTableCreateCompanionBuilder = DbTranslationsCompanion
    Function({
  Value<int> id,
  required int verseId,
  required int resourceId,
  required String translationText,
});
typedef $$DbTranslationsTableUpdateCompanionBuilder = DbTranslationsCompanion
    Function({
  Value<int> id,
  Value<int> verseId,
  Value<int> resourceId,
  Value<String> translationText,
});

class $$DbTranslationsTableFilterComposer
    extends Composer<_$AppDatabase, $DbTranslationsTable> {
  $$DbTranslationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get verseId => $composableBuilder(
      column: $table.verseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get translationText => $composableBuilder(
      column: $table.translationText,
      builder: (column) => ColumnFilters(column));
}

class $$DbTranslationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbTranslationsTable> {
  $$DbTranslationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get verseId => $composableBuilder(
      column: $table.verseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translationText => $composableBuilder(
      column: $table.translationText,
      builder: (column) => ColumnOrderings(column));
}

class $$DbTranslationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbTranslationsTable> {
  $$DbTranslationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get verseId =>
      $composableBuilder(column: $table.verseId, builder: (column) => column);

  GeneratedColumn<int> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => column);

  GeneratedColumn<String> get translationText => $composableBuilder(
      column: $table.translationText, builder: (column) => column);
}

class $$DbTranslationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DbTranslationsTable,
    DbTranslation,
    $$DbTranslationsTableFilterComposer,
    $$DbTranslationsTableOrderingComposer,
    $$DbTranslationsTableAnnotationComposer,
    $$DbTranslationsTableCreateCompanionBuilder,
    $$DbTranslationsTableUpdateCompanionBuilder,
    (
      DbTranslation,
      BaseReferences<_$AppDatabase, $DbTranslationsTable, DbTranslation>
    ),
    DbTranslation,
    PrefetchHooks Function()> {
  $$DbTranslationsTableTableManager(
      _$AppDatabase db, $DbTranslationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbTranslationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbTranslationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbTranslationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> verseId = const Value.absent(),
            Value<int> resourceId = const Value.absent(),
            Value<String> translationText = const Value.absent(),
          }) =>
              DbTranslationsCompanion(
            id: id,
            verseId: verseId,
            resourceId: resourceId,
            translationText: translationText,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int verseId,
            required int resourceId,
            required String translationText,
          }) =>
              DbTranslationsCompanion.insert(
            id: id,
            verseId: verseId,
            resourceId: resourceId,
            translationText: translationText,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DbTranslationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DbTranslationsTable,
    DbTranslation,
    $$DbTranslationsTableFilterComposer,
    $$DbTranslationsTableOrderingComposer,
    $$DbTranslationsTableAnnotationComposer,
    $$DbTranslationsTableCreateCompanionBuilder,
    $$DbTranslationsTableUpdateCompanionBuilder,
    (
      DbTranslation,
      BaseReferences<_$AppDatabase, $DbTranslationsTable, DbTranslation>
    ),
    DbTranslation,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DbChaptersTableTableManager get dbChapters =>
      $$DbChaptersTableTableManager(_db, _db.dbChapters);
  $$DbVersesTableTableManager get dbVerses =>
      $$DbVersesTableTableManager(_db, _db.dbVerses);
  $$DbTranslationsTableTableManager get dbTranslations =>
      $$DbTranslationsTableTableManager(_db, _db.dbTranslations);
}
