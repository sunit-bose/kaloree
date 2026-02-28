// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service.dart';

// ignore_for_file: type=lint
class $MealsTable extends Meals with TableInfo<$MealsTable, Meal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mealNumberMeta =
      const VerificationMeta('mealNumber');
  @override
  late final GeneratedColumn<int> mealNumber = GeneratedColumn<int>(
      'meal_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mealTypeMeta =
      const VerificationMeta('mealType');
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
      'meal_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalCaloriesMeta =
      const VerificationMeta('totalCalories');
  @override
  late final GeneratedColumn<int> totalCalories = GeneratedColumn<int>(
      'total_calories', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalProteinMeta =
      const VerificationMeta('totalProtein');
  @override
  late final GeneratedColumn<double> totalProtein = GeneratedColumn<double>(
      'total_protein', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalCarbsMeta =
      const VerificationMeta('totalCarbs');
  @override
  late final GeneratedColumn<double> totalCarbs = GeneratedColumn<double>(
      'total_carbs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalFatMeta =
      const VerificationMeta('totalFat');
  @override
  late final GeneratedColumn<double> totalFat = GeneratedColumn<double>(
      'total_fat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalFiberMeta =
      const VerificationMeta('totalFiber');
  @override
  late final GeneratedColumn<double> totalFiber = GeneratedColumn<double>(
      'total_fiber', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        timestamp,
        mealNumber,
        mealType,
        source,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        totalFiber
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meals';
  @override
  VerificationContext validateIntegrity(Insertable<Meal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('meal_number')) {
      context.handle(
          _mealNumberMeta,
          mealNumber.isAcceptableOrUnknown(
              data['meal_number']!, _mealNumberMeta));
    } else if (isInserting) {
      context.missing(_mealNumberMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(_mealTypeMeta,
          mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('total_calories')) {
      context.handle(
          _totalCaloriesMeta,
          totalCalories.isAcceptableOrUnknown(
              data['total_calories']!, _totalCaloriesMeta));
    } else if (isInserting) {
      context.missing(_totalCaloriesMeta);
    }
    if (data.containsKey('total_protein')) {
      context.handle(
          _totalProteinMeta,
          totalProtein.isAcceptableOrUnknown(
              data['total_protein']!, _totalProteinMeta));
    } else if (isInserting) {
      context.missing(_totalProteinMeta);
    }
    if (data.containsKey('total_carbs')) {
      context.handle(
          _totalCarbsMeta,
          totalCarbs.isAcceptableOrUnknown(
              data['total_carbs']!, _totalCarbsMeta));
    } else if (isInserting) {
      context.missing(_totalCarbsMeta);
    }
    if (data.containsKey('total_fat')) {
      context.handle(_totalFatMeta,
          totalFat.isAcceptableOrUnknown(data['total_fat']!, _totalFatMeta));
    } else if (isInserting) {
      context.missing(_totalFatMeta);
    }
    if (data.containsKey('total_fiber')) {
      context.handle(
          _totalFiberMeta,
          totalFiber.isAcceptableOrUnknown(
              data['total_fiber']!, _totalFiberMeta));
    } else if (isInserting) {
      context.missing(_totalFiberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      mealNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meal_number'])!,
      mealType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_type']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      totalCalories: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_calories'])!,
      totalProtein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_protein'])!,
      totalCarbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_carbs'])!,
      totalFat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_fat'])!,
      totalFiber: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_fiber'])!,
    );
  }

  @override
  $MealsTable createAlias(String alias) {
    return $MealsTable(attachedDatabase, alias);
  }
}

class Meal extends DataClass implements Insertable<Meal> {
  final String id;
  final String date;
  final int timestamp;
  final int mealNumber;
  final String? mealType;
  final String source;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  const Meal(
      {required this.id,
      required this.date,
      required this.timestamp,
      required this.mealNumber,
      this.mealType,
      required this.source,
      required this.totalCalories,
      required this.totalProtein,
      required this.totalCarbs,
      required this.totalFat,
      required this.totalFiber});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<String>(date);
    map['timestamp'] = Variable<int>(timestamp);
    map['meal_number'] = Variable<int>(mealNumber);
    if (!nullToAbsent || mealType != null) {
      map['meal_type'] = Variable<String>(mealType);
    }
    map['source'] = Variable<String>(source);
    map['total_calories'] = Variable<int>(totalCalories);
    map['total_protein'] = Variable<double>(totalProtein);
    map['total_carbs'] = Variable<double>(totalCarbs);
    map['total_fat'] = Variable<double>(totalFat);
    map['total_fiber'] = Variable<double>(totalFiber);
    return map;
  }

  MealsCompanion toCompanion(bool nullToAbsent) {
    return MealsCompanion(
      id: Value(id),
      date: Value(date),
      timestamp: Value(timestamp),
      mealNumber: Value(mealNumber),
      mealType: mealType == null && nullToAbsent
          ? const Value.absent()
          : Value(mealType),
      source: Value(source),
      totalCalories: Value(totalCalories),
      totalProtein: Value(totalProtein),
      totalCarbs: Value(totalCarbs),
      totalFat: Value(totalFat),
      totalFiber: Value(totalFiber),
    );
  }

  factory Meal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meal(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      mealNumber: serializer.fromJson<int>(json['mealNumber']),
      mealType: serializer.fromJson<String?>(json['mealType']),
      source: serializer.fromJson<String>(json['source']),
      totalCalories: serializer.fromJson<int>(json['totalCalories']),
      totalProtein: serializer.fromJson<double>(json['totalProtein']),
      totalCarbs: serializer.fromJson<double>(json['totalCarbs']),
      totalFat: serializer.fromJson<double>(json['totalFat']),
      totalFiber: serializer.fromJson<double>(json['totalFiber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(date),
      'timestamp': serializer.toJson<int>(timestamp),
      'mealNumber': serializer.toJson<int>(mealNumber),
      'mealType': serializer.toJson<String?>(mealType),
      'source': serializer.toJson<String>(source),
      'totalCalories': serializer.toJson<int>(totalCalories),
      'totalProtein': serializer.toJson<double>(totalProtein),
      'totalCarbs': serializer.toJson<double>(totalCarbs),
      'totalFat': serializer.toJson<double>(totalFat),
      'totalFiber': serializer.toJson<double>(totalFiber),
    };
  }

  Meal copyWith(
          {String? id,
          String? date,
          int? timestamp,
          int? mealNumber,
          Value<String?> mealType = const Value.absent(),
          String? source,
          int? totalCalories,
          double? totalProtein,
          double? totalCarbs,
          double? totalFat,
          double? totalFiber}) =>
      Meal(
        id: id ?? this.id,
        date: date ?? this.date,
        timestamp: timestamp ?? this.timestamp,
        mealNumber: mealNumber ?? this.mealNumber,
        mealType: mealType.present ? mealType.value : this.mealType,
        source: source ?? this.source,
        totalCalories: totalCalories ?? this.totalCalories,
        totalProtein: totalProtein ?? this.totalProtein,
        totalCarbs: totalCarbs ?? this.totalCarbs,
        totalFat: totalFat ?? this.totalFat,
        totalFiber: totalFiber ?? this.totalFiber,
      );
  Meal copyWithCompanion(MealsCompanion data) {
    return Meal(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      mealNumber:
          data.mealNumber.present ? data.mealNumber.value : this.mealNumber,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      source: data.source.present ? data.source.value : this.source,
      totalCalories: data.totalCalories.present
          ? data.totalCalories.value
          : this.totalCalories,
      totalProtein: data.totalProtein.present
          ? data.totalProtein.value
          : this.totalProtein,
      totalCarbs:
          data.totalCarbs.present ? data.totalCarbs.value : this.totalCarbs,
      totalFat: data.totalFat.present ? data.totalFat.value : this.totalFat,
      totalFiber:
          data.totalFiber.present ? data.totalFiber.value : this.totalFiber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meal(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('timestamp: $timestamp, ')
          ..write('mealNumber: $mealNumber, ')
          ..write('mealType: $mealType, ')
          ..write('source: $source, ')
          ..write('totalCalories: $totalCalories, ')
          ..write('totalProtein: $totalProtein, ')
          ..write('totalCarbs: $totalCarbs, ')
          ..write('totalFat: $totalFat, ')
          ..write('totalFiber: $totalFiber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, timestamp, mealNumber, mealType,
      source, totalCalories, totalProtein, totalCarbs, totalFat, totalFiber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meal &&
          other.id == this.id &&
          other.date == this.date &&
          other.timestamp == this.timestamp &&
          other.mealNumber == this.mealNumber &&
          other.mealType == this.mealType &&
          other.source == this.source &&
          other.totalCalories == this.totalCalories &&
          other.totalProtein == this.totalProtein &&
          other.totalCarbs == this.totalCarbs &&
          other.totalFat == this.totalFat &&
          other.totalFiber == this.totalFiber);
}

class MealsCompanion extends UpdateCompanion<Meal> {
  final Value<String> id;
  final Value<String> date;
  final Value<int> timestamp;
  final Value<int> mealNumber;
  final Value<String?> mealType;
  final Value<String> source;
  final Value<int> totalCalories;
  final Value<double> totalProtein;
  final Value<double> totalCarbs;
  final Value<double> totalFat;
  final Value<double> totalFiber;
  final Value<int> rowid;
  const MealsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.mealNumber = const Value.absent(),
    this.mealType = const Value.absent(),
    this.source = const Value.absent(),
    this.totalCalories = const Value.absent(),
    this.totalProtein = const Value.absent(),
    this.totalCarbs = const Value.absent(),
    this.totalFat = const Value.absent(),
    this.totalFiber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealsCompanion.insert({
    required String id,
    required String date,
    required int timestamp,
    required int mealNumber,
    this.mealType = const Value.absent(),
    required String source,
    required int totalCalories,
    required double totalProtein,
    required double totalCarbs,
    required double totalFat,
    required double totalFiber,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        timestamp = Value(timestamp),
        mealNumber = Value(mealNumber),
        source = Value(source),
        totalCalories = Value(totalCalories),
        totalProtein = Value(totalProtein),
        totalCarbs = Value(totalCarbs),
        totalFat = Value(totalFat),
        totalFiber = Value(totalFiber);
  static Insertable<Meal> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<int>? timestamp,
    Expression<int>? mealNumber,
    Expression<String>? mealType,
    Expression<String>? source,
    Expression<int>? totalCalories,
    Expression<double>? totalProtein,
    Expression<double>? totalCarbs,
    Expression<double>? totalFat,
    Expression<double>? totalFiber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (timestamp != null) 'timestamp': timestamp,
      if (mealNumber != null) 'meal_number': mealNumber,
      if (mealType != null) 'meal_type': mealType,
      if (source != null) 'source': source,
      if (totalCalories != null) 'total_calories': totalCalories,
      if (totalProtein != null) 'total_protein': totalProtein,
      if (totalCarbs != null) 'total_carbs': totalCarbs,
      if (totalFat != null) 'total_fat': totalFat,
      if (totalFiber != null) 'total_fiber': totalFiber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealsCompanion copyWith(
      {Value<String>? id,
      Value<String>? date,
      Value<int>? timestamp,
      Value<int>? mealNumber,
      Value<String?>? mealType,
      Value<String>? source,
      Value<int>? totalCalories,
      Value<double>? totalProtein,
      Value<double>? totalCarbs,
      Value<double>? totalFat,
      Value<double>? totalFiber,
      Value<int>? rowid}) {
    return MealsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
      mealNumber: mealNumber ?? this.mealNumber,
      mealType: mealType ?? this.mealType,
      source: source ?? this.source,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (mealNumber.present) {
      map['meal_number'] = Variable<int>(mealNumber.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (totalCalories.present) {
      map['total_calories'] = Variable<int>(totalCalories.value);
    }
    if (totalProtein.present) {
      map['total_protein'] = Variable<double>(totalProtein.value);
    }
    if (totalCarbs.present) {
      map['total_carbs'] = Variable<double>(totalCarbs.value);
    }
    if (totalFat.present) {
      map['total_fat'] = Variable<double>(totalFat.value);
    }
    if (totalFiber.present) {
      map['total_fiber'] = Variable<double>(totalFiber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('timestamp: $timestamp, ')
          ..write('mealNumber: $mealNumber, ')
          ..write('mealType: $mealType, ')
          ..write('source: $source, ')
          ..write('totalCalories: $totalCalories, ')
          ..write('totalProtein: $totalProtein, ')
          ..write('totalCarbs: $totalCarbs, ')
          ..write('totalFat: $totalFat, ')
          ..write('totalFiber: $totalFiber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealItemsTable extends MealItems
    with TableInfo<$MealItemsTable, MealItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<String> mealId = GeneratedColumn<String>(
      'meal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES meals (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portionMeta =
      const VerificationMeta('portion');
  @override
  late final GeneratedColumn<String> portion = GeneratedColumn<String>(
      'portion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portionGramsMeta =
      const VerificationMeta('portionGrams');
  @override
  late final GeneratedColumn<int> portionGrams = GeneratedColumn<int>(
      'portion_grams', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _caloriesMeta =
      const VerificationMeta('calories');
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
      'calories', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _proteinMeta =
      const VerificationMeta('protein');
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
      'protein', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
      'fat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
      'fiber', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isEditedMeta =
      const VerificationMeta('isEdited');
  @override
  late final GeneratedColumn<bool> isEdited = GeneratedColumn<bool>(
      'is_edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_edited" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        mealId,
        name,
        portion,
        portionGrams,
        calories,
        protein,
        carbs,
        fat,
        fiber,
        isEdited
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_items';
  @override
  VerificationContext validateIntegrity(Insertable<MealItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('meal_id')) {
      context.handle(_mealIdMeta,
          mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta));
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('portion')) {
      context.handle(_portionMeta,
          portion.isAcceptableOrUnknown(data['portion']!, _portionMeta));
    } else if (isInserting) {
      context.missing(_portionMeta);
    }
    if (data.containsKey('portion_grams')) {
      context.handle(
          _portionGramsMeta,
          portionGrams.isAcceptableOrUnknown(
              data['portion_grams']!, _portionGramsMeta));
    } else if (isInserting) {
      context.missing(_portionGramsMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(_caloriesMeta,
          calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta));
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta,
          protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
          _fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('fiber')) {
      context.handle(
          _fiberMeta, fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta));
    } else if (isInserting) {
      context.missing(_fiberMeta);
    }
    if (data.containsKey('is_edited')) {
      context.handle(_isEditedMeta,
          isEdited.isAcceptableOrUnknown(data['is_edited']!, _isEditedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mealId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      portion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}portion'])!,
      portionGrams: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}portion_grams'])!,
      calories: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}calories'])!,
      protein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
      fat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat'])!,
      fiber: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fiber'])!,
      isEdited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_edited'])!,
    );
  }

  @override
  $MealItemsTable createAlias(String alias) {
    return $MealItemsTable(attachedDatabase, alias);
  }
}

class MealItem extends DataClass implements Insertable<MealItem> {
  final String id;
  final String mealId;
  final String name;
  final String portion;
  final int portionGrams;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final bool isEdited;
  const MealItem(
      {required this.id,
      required this.mealId,
      required this.name,
      required this.portion,
      required this.portionGrams,
      required this.calories,
      required this.protein,
      required this.carbs,
      required this.fat,
      required this.fiber,
      required this.isEdited});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['meal_id'] = Variable<String>(mealId);
    map['name'] = Variable<String>(name);
    map['portion'] = Variable<String>(portion);
    map['portion_grams'] = Variable<int>(portionGrams);
    map['calories'] = Variable<int>(calories);
    map['protein'] = Variable<double>(protein);
    map['carbs'] = Variable<double>(carbs);
    map['fat'] = Variable<double>(fat);
    map['fiber'] = Variable<double>(fiber);
    map['is_edited'] = Variable<bool>(isEdited);
    return map;
  }

  MealItemsCompanion toCompanion(bool nullToAbsent) {
    return MealItemsCompanion(
      id: Value(id),
      mealId: Value(mealId),
      name: Value(name),
      portion: Value(portion),
      portionGrams: Value(portionGrams),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      fiber: Value(fiber),
      isEdited: Value(isEdited),
    );
  }

  factory MealItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealItem(
      id: serializer.fromJson<String>(json['id']),
      mealId: serializer.fromJson<String>(json['mealId']),
      name: serializer.fromJson<String>(json['name']),
      portion: serializer.fromJson<String>(json['portion']),
      portionGrams: serializer.fromJson<int>(json['portionGrams']),
      calories: serializer.fromJson<int>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fat: serializer.fromJson<double>(json['fat']),
      fiber: serializer.fromJson<double>(json['fiber']),
      isEdited: serializer.fromJson<bool>(json['isEdited']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mealId': serializer.toJson<String>(mealId),
      'name': serializer.toJson<String>(name),
      'portion': serializer.toJson<String>(portion),
      'portionGrams': serializer.toJson<int>(portionGrams),
      'calories': serializer.toJson<int>(calories),
      'protein': serializer.toJson<double>(protein),
      'carbs': serializer.toJson<double>(carbs),
      'fat': serializer.toJson<double>(fat),
      'fiber': serializer.toJson<double>(fiber),
      'isEdited': serializer.toJson<bool>(isEdited),
    };
  }

  MealItem copyWith(
          {String? id,
          String? mealId,
          String? name,
          String? portion,
          int? portionGrams,
          int? calories,
          double? protein,
          double? carbs,
          double? fat,
          double? fiber,
          bool? isEdited}) =>
      MealItem(
        id: id ?? this.id,
        mealId: mealId ?? this.mealId,
        name: name ?? this.name,
        portion: portion ?? this.portion,
        portionGrams: portionGrams ?? this.portionGrams,
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
        carbs: carbs ?? this.carbs,
        fat: fat ?? this.fat,
        fiber: fiber ?? this.fiber,
        isEdited: isEdited ?? this.isEdited,
      );
  MealItem copyWithCompanion(MealItemsCompanion data) {
    return MealItem(
      id: data.id.present ? data.id.value : this.id,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      name: data.name.present ? data.name.value : this.name,
      portion: data.portion.present ? data.portion.value : this.portion,
      portionGrams: data.portionGrams.present
          ? data.portionGrams.value
          : this.portionGrams,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      isEdited: data.isEdited.present ? data.isEdited.value : this.isEdited,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealItem(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('name: $name, ')
          ..write('portion: $portion, ')
          ..write('portionGrams: $portionGrams, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('isEdited: $isEdited')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mealId, name, portion, portionGrams,
      calories, protein, carbs, fat, fiber, isEdited);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealItem &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.name == this.name &&
          other.portion == this.portion &&
          other.portionGrams == this.portionGrams &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.fiber == this.fiber &&
          other.isEdited == this.isEdited);
}

class MealItemsCompanion extends UpdateCompanion<MealItem> {
  final Value<String> id;
  final Value<String> mealId;
  final Value<String> name;
  final Value<String> portion;
  final Value<int> portionGrams;
  final Value<int> calories;
  final Value<double> protein;
  final Value<double> carbs;
  final Value<double> fat;
  final Value<double> fiber;
  final Value<bool> isEdited;
  final Value<int> rowid;
  const MealItemsCompanion({
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.name = const Value.absent(),
    this.portion = const Value.absent(),
    this.portionGrams = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealItemsCompanion.insert({
    required String id,
    required String mealId,
    required String name,
    required String portion,
    required int portionGrams,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
    this.isEdited = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mealId = Value(mealId),
        name = Value(name),
        portion = Value(portion),
        portionGrams = Value(portionGrams),
        calories = Value(calories),
        protein = Value(protein),
        carbs = Value(carbs),
        fat = Value(fat),
        fiber = Value(fiber);
  static Insertable<MealItem> custom({
    Expression<String>? id,
    Expression<String>? mealId,
    Expression<String>? name,
    Expression<String>? portion,
    Expression<int>? portionGrams,
    Expression<int>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<double>? fiber,
    Expression<bool>? isEdited,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealId != null) 'meal_id': mealId,
      if (name != null) 'name': name,
      if (portion != null) 'portion': portion,
      if (portionGrams != null) 'portion_grams': portionGrams,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (isEdited != null) 'is_edited': isEdited,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? mealId,
      Value<String>? name,
      Value<String>? portion,
      Value<int>? portionGrams,
      Value<int>? calories,
      Value<double>? protein,
      Value<double>? carbs,
      Value<double>? fat,
      Value<double>? fiber,
      Value<bool>? isEdited,
      Value<int>? rowid}) {
    return MealItemsCompanion(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      name: name ?? this.name,
      portion: portion ?? this.portion,
      portionGrams: portionGrams ?? this.portionGrams,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      isEdited: isEdited ?? this.isEdited,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<String>(mealId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (portion.present) {
      map['portion'] = Variable<String>(portion.value);
    }
    if (portionGrams.present) {
      map['portion_grams'] = Variable<int>(portionGrams.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (isEdited.present) {
      map['is_edited'] = Variable<bool>(isEdited.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealItemsCompanion(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('name: $name, ')
          ..write('portion: $portion, ')
          ..write('portionGrams: $portionGrams, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('isEdited: $isEdited, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _calorieGoalMeta =
      const VerificationMeta('calorieGoal');
  @override
  late final GeneratedColumn<int> calorieGoal = GeneratedColumn<int>(
      'calorie_goal', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2000));
  static const VerificationMeta _proteinGoalMeta =
      const VerificationMeta('proteinGoal');
  @override
  late final GeneratedColumn<double> proteinGoal = GeneratedColumn<double>(
      'protein_goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(60));
  static const VerificationMeta _carbsGoalMeta =
      const VerificationMeta('carbsGoal');
  @override
  late final GeneratedColumn<double> carbsGoal = GeneratedColumn<double>(
      'carbs_goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(250));
  static const VerificationMeta _fatGoalMeta =
      const VerificationMeta('fatGoal');
  @override
  late final GeneratedColumn<double> fatGoal = GeneratedColumn<double>(
      'fat_goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(65));
  static const VerificationMeta _fiberGoalMeta =
      const VerificationMeta('fiberGoal');
  @override
  late final GeneratedColumn<double> fiberGoal = GeneratedColumn<double>(
      'fiber_goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(25));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _heightCmMeta =
      const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
      'height_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _activityLevelMeta =
      const VerificationMeta('activityLevel');
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
      'activity_level', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fitnessGoalMeta =
      const VerificationMeta('fitnessGoal');
  @override
  late final GeneratedColumn<String> fitnessGoal = GeneratedColumn<String>(
      'fitness_goal', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _targetWeightKgMeta =
      const VerificationMeta('targetWeightKg');
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
      'target_weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _calculatedBmrMeta =
      const VerificationMeta('calculatedBmr');
  @override
  late final GeneratedColumn<int> calculatedBmr = GeneratedColumn<int>(
      'calculated_bmr', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _calculatedTdeeMeta =
      const VerificationMeta('calculatedTdee');
  @override
  late final GeneratedColumn<int> calculatedTdee = GeneratedColumn<int>(
      'calculated_tdee', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        calorieGoal,
        proteinGoal,
        carbsGoal,
        fatGoal,
        fiberGoal,
        createdAt,
        age,
        weightKg,
        heightCm,
        gender,
        activityLevel,
        fitnessGoal,
        targetWeightKg,
        calculatedBmr,
        calculatedTdee
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('calorie_goal')) {
      context.handle(
          _calorieGoalMeta,
          calorieGoal.isAcceptableOrUnknown(
              data['calorie_goal']!, _calorieGoalMeta));
    }
    if (data.containsKey('protein_goal')) {
      context.handle(
          _proteinGoalMeta,
          proteinGoal.isAcceptableOrUnknown(
              data['protein_goal']!, _proteinGoalMeta));
    }
    if (data.containsKey('carbs_goal')) {
      context.handle(_carbsGoalMeta,
          carbsGoal.isAcceptableOrUnknown(data['carbs_goal']!, _carbsGoalMeta));
    }
    if (data.containsKey('fat_goal')) {
      context.handle(_fatGoalMeta,
          fatGoal.isAcceptableOrUnknown(data['fat_goal']!, _fatGoalMeta));
    }
    if (data.containsKey('fiber_goal')) {
      context.handle(_fiberGoalMeta,
          fiberGoal.isAcceptableOrUnknown(data['fiber_goal']!, _fiberGoalMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta,
          heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('activity_level')) {
      context.handle(
          _activityLevelMeta,
          activityLevel.isAcceptableOrUnknown(
              data['activity_level']!, _activityLevelMeta));
    }
    if (data.containsKey('fitness_goal')) {
      context.handle(
          _fitnessGoalMeta,
          fitnessGoal.isAcceptableOrUnknown(
              data['fitness_goal']!, _fitnessGoalMeta));
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
          _targetWeightKgMeta,
          targetWeightKg.isAcceptableOrUnknown(
              data['target_weight_kg']!, _targetWeightKgMeta));
    }
    if (data.containsKey('calculated_bmr')) {
      context.handle(
          _calculatedBmrMeta,
          calculatedBmr.isAcceptableOrUnknown(
              data['calculated_bmr']!, _calculatedBmrMeta));
    }
    if (data.containsKey('calculated_tdee')) {
      context.handle(
          _calculatedTdeeMeta,
          calculatedTdee.isAcceptableOrUnknown(
              data['calculated_tdee']!, _calculatedTdeeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      calorieGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}calorie_goal'])!,
      proteinGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein_goal'])!,
      carbsGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs_goal'])!,
      fatGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat_goal'])!,
      fiberGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fiber_goal'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      heightCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_cm']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      activityLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_level']),
      fitnessGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fitness_goal']),
      targetWeightKg: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}target_weight_kg']),
      calculatedBmr: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}calculated_bmr']),
      calculatedTdee: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}calculated_tdee']),
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final int id;
  final int calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final double fiberGoal;
  final int createdAt;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final String? gender;
  final String? activityLevel;
  final String? fitnessGoal;
  final double? targetWeightKg;
  final int? calculatedBmr;
  final int? calculatedTdee;
  const UserSetting(
      {required this.id,
      required this.calorieGoal,
      required this.proteinGoal,
      required this.carbsGoal,
      required this.fatGoal,
      required this.fiberGoal,
      required this.createdAt,
      this.age,
      this.weightKg,
      this.heightCm,
      this.gender,
      this.activityLevel,
      this.fitnessGoal,
      this.targetWeightKg,
      this.calculatedBmr,
      this.calculatedTdee});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['calorie_goal'] = Variable<int>(calorieGoal);
    map['protein_goal'] = Variable<double>(proteinGoal);
    map['carbs_goal'] = Variable<double>(carbsGoal);
    map['fat_goal'] = Variable<double>(fatGoal);
    map['fiber_goal'] = Variable<double>(fiberGoal);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    if (!nullToAbsent || fitnessGoal != null) {
      map['fitness_goal'] = Variable<String>(fitnessGoal);
    }
    if (!nullToAbsent || targetWeightKg != null) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg);
    }
    if (!nullToAbsent || calculatedBmr != null) {
      map['calculated_bmr'] = Variable<int>(calculatedBmr);
    }
    if (!nullToAbsent || calculatedTdee != null) {
      map['calculated_tdee'] = Variable<int>(calculatedTdee);
    }
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      calorieGoal: Value(calorieGoal),
      proteinGoal: Value(proteinGoal),
      carbsGoal: Value(carbsGoal),
      fatGoal: Value(fatGoal),
      fiberGoal: Value(fiberGoal),
      createdAt: Value(createdAt),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      fitnessGoal: fitnessGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(fitnessGoal),
      targetWeightKg: targetWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeightKg),
      calculatedBmr: calculatedBmr == null && nullToAbsent
          ? const Value.absent()
          : Value(calculatedBmr),
      calculatedTdee: calculatedTdee == null && nullToAbsent
          ? const Value.absent()
          : Value(calculatedTdee),
    );
  }

  factory UserSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      id: serializer.fromJson<int>(json['id']),
      calorieGoal: serializer.fromJson<int>(json['calorieGoal']),
      proteinGoal: serializer.fromJson<double>(json['proteinGoal']),
      carbsGoal: serializer.fromJson<double>(json['carbsGoal']),
      fatGoal: serializer.fromJson<double>(json['fatGoal']),
      fiberGoal: serializer.fromJson<double>(json['fiberGoal']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      age: serializer.fromJson<int?>(json['age']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      gender: serializer.fromJson<String?>(json['gender']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
      fitnessGoal: serializer.fromJson<String?>(json['fitnessGoal']),
      targetWeightKg: serializer.fromJson<double?>(json['targetWeightKg']),
      calculatedBmr: serializer.fromJson<int?>(json['calculatedBmr']),
      calculatedTdee: serializer.fromJson<int?>(json['calculatedTdee']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'calorieGoal': serializer.toJson<int>(calorieGoal),
      'proteinGoal': serializer.toJson<double>(proteinGoal),
      'carbsGoal': serializer.toJson<double>(carbsGoal),
      'fatGoal': serializer.toJson<double>(fatGoal),
      'fiberGoal': serializer.toJson<double>(fiberGoal),
      'createdAt': serializer.toJson<int>(createdAt),
      'age': serializer.toJson<int?>(age),
      'weightKg': serializer.toJson<double?>(weightKg),
      'heightCm': serializer.toJson<double?>(heightCm),
      'gender': serializer.toJson<String?>(gender),
      'activityLevel': serializer.toJson<String?>(activityLevel),
      'fitnessGoal': serializer.toJson<String?>(fitnessGoal),
      'targetWeightKg': serializer.toJson<double?>(targetWeightKg),
      'calculatedBmr': serializer.toJson<int?>(calculatedBmr),
      'calculatedTdee': serializer.toJson<int?>(calculatedTdee),
    };
  }

  UserSetting copyWith(
          {int? id,
          int? calorieGoal,
          double? proteinGoal,
          double? carbsGoal,
          double? fatGoal,
          double? fiberGoal,
          int? createdAt,
          Value<int?> age = const Value.absent(),
          Value<double?> weightKg = const Value.absent(),
          Value<double?> heightCm = const Value.absent(),
          Value<String?> gender = const Value.absent(),
          Value<String?> activityLevel = const Value.absent(),
          Value<String?> fitnessGoal = const Value.absent(),
          Value<double?> targetWeightKg = const Value.absent(),
          Value<int?> calculatedBmr = const Value.absent(),
          Value<int?> calculatedTdee = const Value.absent()}) =>
      UserSetting(
        id: id ?? this.id,
        calorieGoal: calorieGoal ?? this.calorieGoal,
        proteinGoal: proteinGoal ?? this.proteinGoal,
        carbsGoal: carbsGoal ?? this.carbsGoal,
        fatGoal: fatGoal ?? this.fatGoal,
        fiberGoal: fiberGoal ?? this.fiberGoal,
        createdAt: createdAt ?? this.createdAt,
        age: age.present ? age.value : this.age,
        weightKg: weightKg.present ? weightKg.value : this.weightKg,
        heightCm: heightCm.present ? heightCm.value : this.heightCm,
        gender: gender.present ? gender.value : this.gender,
        activityLevel:
            activityLevel.present ? activityLevel.value : this.activityLevel,
        fitnessGoal: fitnessGoal.present ? fitnessGoal.value : this.fitnessGoal,
        targetWeightKg:
            targetWeightKg.present ? targetWeightKg.value : this.targetWeightKg,
        calculatedBmr:
            calculatedBmr.present ? calculatedBmr.value : this.calculatedBmr,
        calculatedTdee:
            calculatedTdee.present ? calculatedTdee.value : this.calculatedTdee,
      );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      id: data.id.present ? data.id.value : this.id,
      calorieGoal:
          data.calorieGoal.present ? data.calorieGoal.value : this.calorieGoal,
      proteinGoal:
          data.proteinGoal.present ? data.proteinGoal.value : this.proteinGoal,
      carbsGoal: data.carbsGoal.present ? data.carbsGoal.value : this.carbsGoal,
      fatGoal: data.fatGoal.present ? data.fatGoal.value : this.fatGoal,
      fiberGoal: data.fiberGoal.present ? data.fiberGoal.value : this.fiberGoal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      age: data.age.present ? data.age.value : this.age,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      gender: data.gender.present ? data.gender.value : this.gender,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      fitnessGoal:
          data.fitnessGoal.present ? data.fitnessGoal.value : this.fitnessGoal,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      calculatedBmr: data.calculatedBmr.present
          ? data.calculatedBmr.value
          : this.calculatedBmr,
      calculatedTdee: data.calculatedTdee.present
          ? data.calculatedTdee.value
          : this.calculatedTdee,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('id: $id, ')
          ..write('calorieGoal: $calorieGoal, ')
          ..write('proteinGoal: $proteinGoal, ')
          ..write('carbsGoal: $carbsGoal, ')
          ..write('fatGoal: $fatGoal, ')
          ..write('fiberGoal: $fiberGoal, ')
          ..write('createdAt: $createdAt, ')
          ..write('age: $age, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('gender: $gender, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('fitnessGoal: $fitnessGoal, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('calculatedBmr: $calculatedBmr, ')
          ..write('calculatedTdee: $calculatedTdee')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      calorieGoal,
      proteinGoal,
      carbsGoal,
      fatGoal,
      fiberGoal,
      createdAt,
      age,
      weightKg,
      heightCm,
      gender,
      activityLevel,
      fitnessGoal,
      targetWeightKg,
      calculatedBmr,
      calculatedTdee);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.id == this.id &&
          other.calorieGoal == this.calorieGoal &&
          other.proteinGoal == this.proteinGoal &&
          other.carbsGoal == this.carbsGoal &&
          other.fatGoal == this.fatGoal &&
          other.fiberGoal == this.fiberGoal &&
          other.createdAt == this.createdAt &&
          other.age == this.age &&
          other.weightKg == this.weightKg &&
          other.heightCm == this.heightCm &&
          other.gender == this.gender &&
          other.activityLevel == this.activityLevel &&
          other.fitnessGoal == this.fitnessGoal &&
          other.targetWeightKg == this.targetWeightKg &&
          other.calculatedBmr == this.calculatedBmr &&
          other.calculatedTdee == this.calculatedTdee);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<int> id;
  final Value<int> calorieGoal;
  final Value<double> proteinGoal;
  final Value<double> carbsGoal;
  final Value<double> fatGoal;
  final Value<double> fiberGoal;
  final Value<int> createdAt;
  final Value<int?> age;
  final Value<double?> weightKg;
  final Value<double?> heightCm;
  final Value<String?> gender;
  final Value<String?> activityLevel;
  final Value<String?> fitnessGoal;
  final Value<double?> targetWeightKg;
  final Value<int?> calculatedBmr;
  final Value<int?> calculatedTdee;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.calorieGoal = const Value.absent(),
    this.proteinGoal = const Value.absent(),
    this.carbsGoal = const Value.absent(),
    this.fatGoal = const Value.absent(),
    this.fiberGoal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.age = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.gender = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.fitnessGoal = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.calculatedBmr = const Value.absent(),
    this.calculatedTdee = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.calorieGoal = const Value.absent(),
    this.proteinGoal = const Value.absent(),
    this.carbsGoal = const Value.absent(),
    this.fatGoal = const Value.absent(),
    this.fiberGoal = const Value.absent(),
    required int createdAt,
    this.age = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.gender = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.fitnessGoal = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.calculatedBmr = const Value.absent(),
    this.calculatedTdee = const Value.absent(),
  }) : createdAt = Value(createdAt);
  static Insertable<UserSetting> custom({
    Expression<int>? id,
    Expression<int>? calorieGoal,
    Expression<double>? proteinGoal,
    Expression<double>? carbsGoal,
    Expression<double>? fatGoal,
    Expression<double>? fiberGoal,
    Expression<int>? createdAt,
    Expression<int>? age,
    Expression<double>? weightKg,
    Expression<double>? heightCm,
    Expression<String>? gender,
    Expression<String>? activityLevel,
    Expression<String>? fitnessGoal,
    Expression<double>? targetWeightKg,
    Expression<int>? calculatedBmr,
    Expression<int>? calculatedTdee,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (calorieGoal != null) 'calorie_goal': calorieGoal,
      if (proteinGoal != null) 'protein_goal': proteinGoal,
      if (carbsGoal != null) 'carbs_goal': carbsGoal,
      if (fatGoal != null) 'fat_goal': fatGoal,
      if (fiberGoal != null) 'fiber_goal': fiberGoal,
      if (createdAt != null) 'created_at': createdAt,
      if (age != null) 'age': age,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (gender != null) 'gender': gender,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (fitnessGoal != null) 'fitness_goal': fitnessGoal,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (calculatedBmr != null) 'calculated_bmr': calculatedBmr,
      if (calculatedTdee != null) 'calculated_tdee': calculatedTdee,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? calorieGoal,
      Value<double>? proteinGoal,
      Value<double>? carbsGoal,
      Value<double>? fatGoal,
      Value<double>? fiberGoal,
      Value<int>? createdAt,
      Value<int?>? age,
      Value<double?>? weightKg,
      Value<double?>? heightCm,
      Value<String?>? gender,
      Value<String?>? activityLevel,
      Value<String?>? fitnessGoal,
      Value<double?>? targetWeightKg,
      Value<int?>? calculatedBmr,
      Value<int?>? calculatedTdee}) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      fiberGoal: fiberGoal ?? this.fiberGoal,
      createdAt: createdAt ?? this.createdAt,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      calculatedBmr: calculatedBmr ?? this.calculatedBmr,
      calculatedTdee: calculatedTdee ?? this.calculatedTdee,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (calorieGoal.present) {
      map['calorie_goal'] = Variable<int>(calorieGoal.value);
    }
    if (proteinGoal.present) {
      map['protein_goal'] = Variable<double>(proteinGoal.value);
    }
    if (carbsGoal.present) {
      map['carbs_goal'] = Variable<double>(carbsGoal.value);
    }
    if (fatGoal.present) {
      map['fat_goal'] = Variable<double>(fatGoal.value);
    }
    if (fiberGoal.present) {
      map['fiber_goal'] = Variable<double>(fiberGoal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (fitnessGoal.present) {
      map['fitness_goal'] = Variable<String>(fitnessGoal.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (calculatedBmr.present) {
      map['calculated_bmr'] = Variable<int>(calculatedBmr.value);
    }
    if (calculatedTdee.present) {
      map['calculated_tdee'] = Variable<int>(calculatedTdee.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('calorieGoal: $calorieGoal, ')
          ..write('proteinGoal: $proteinGoal, ')
          ..write('carbsGoal: $carbsGoal, ')
          ..write('fatGoal: $fatGoal, ')
          ..write('fiberGoal: $fiberGoal, ')
          ..write('createdAt: $createdAt, ')
          ..write('age: $age, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('gender: $gender, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('fitnessGoal: $fitnessGoal, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('calculatedBmr: $calculatedBmr, ')
          ..write('calculatedTdee: $calculatedTdee')
          ..write(')'))
        .toString();
  }
}

class $IndianFoodsTable extends IndianFoods
    with TableInfo<$IndianFoodsTable, IndianFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IndianFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aliasesMeta =
      const VerificationMeta('aliases');
  @override
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
      'aliases', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
      'region', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _servingSizeMeta =
      const VerificationMeta('servingSize');
  @override
  late final GeneratedColumn<String> servingSize = GeneratedColumn<String>(
      'serving_size', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _servingGramsMeta =
      const VerificationMeta('servingGrams');
  @override
  late final GeneratedColumn<int> servingGrams = GeneratedColumn<int>(
      'serving_grams', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _caloriesMeta =
      const VerificationMeta('calories');
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
      'calories', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _proteinMeta =
      const VerificationMeta('protein');
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
      'protein', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
      'fat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
      'fiber', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        aliases,
        category,
        region,
        servingSize,
        servingGrams,
        calories,
        protein,
        carbs,
        fat,
        fiber
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'indian_foods';
  @override
  VerificationContext validateIntegrity(Insertable<IndianFood> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('aliases')) {
      context.handle(_aliasesMeta,
          aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('region')) {
      context.handle(_regionMeta,
          region.isAcceptableOrUnknown(data['region']!, _regionMeta));
    } else if (isInserting) {
      context.missing(_regionMeta);
    }
    if (data.containsKey('serving_size')) {
      context.handle(
          _servingSizeMeta,
          servingSize.isAcceptableOrUnknown(
              data['serving_size']!, _servingSizeMeta));
    } else if (isInserting) {
      context.missing(_servingSizeMeta);
    }
    if (data.containsKey('serving_grams')) {
      context.handle(
          _servingGramsMeta,
          servingGrams.isAcceptableOrUnknown(
              data['serving_grams']!, _servingGramsMeta));
    } else if (isInserting) {
      context.missing(_servingGramsMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(_caloriesMeta,
          calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta));
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta,
          protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
          _fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('fiber')) {
      context.handle(
          _fiberMeta, fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta));
    } else if (isInserting) {
      context.missing(_fiberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IndianFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IndianFood(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      aliases: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aliases']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      region: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}region'])!,
      servingSize: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serving_size'])!,
      servingGrams: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}serving_grams'])!,
      calories: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}calories'])!,
      protein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
      fat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat'])!,
      fiber: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fiber'])!,
    );
  }

  @override
  $IndianFoodsTable createAlias(String alias) {
    return $IndianFoodsTable(attachedDatabase, alias);
  }
}

class IndianFood extends DataClass implements Insertable<IndianFood> {
  final int id;
  final String name;
  final String? aliases;
  final String category;
  final String region;
  final String servingSize;
  final int servingGrams;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  const IndianFood(
      {required this.id,
      required this.name,
      this.aliases,
      required this.category,
      required this.region,
      required this.servingSize,
      required this.servingGrams,
      required this.calories,
      required this.protein,
      required this.carbs,
      required this.fat,
      required this.fiber});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || aliases != null) {
      map['aliases'] = Variable<String>(aliases);
    }
    map['category'] = Variable<String>(category);
    map['region'] = Variable<String>(region);
    map['serving_size'] = Variable<String>(servingSize);
    map['serving_grams'] = Variable<int>(servingGrams);
    map['calories'] = Variable<int>(calories);
    map['protein'] = Variable<double>(protein);
    map['carbs'] = Variable<double>(carbs);
    map['fat'] = Variable<double>(fat);
    map['fiber'] = Variable<double>(fiber);
    return map;
  }

  IndianFoodsCompanion toCompanion(bool nullToAbsent) {
    return IndianFoodsCompanion(
      id: Value(id),
      name: Value(name),
      aliases: aliases == null && nullToAbsent
          ? const Value.absent()
          : Value(aliases),
      category: Value(category),
      region: Value(region),
      servingSize: Value(servingSize),
      servingGrams: Value(servingGrams),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      fiber: Value(fiber),
    );
  }

  factory IndianFood.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IndianFood(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      aliases: serializer.fromJson<String?>(json['aliases']),
      category: serializer.fromJson<String>(json['category']),
      region: serializer.fromJson<String>(json['region']),
      servingSize: serializer.fromJson<String>(json['servingSize']),
      servingGrams: serializer.fromJson<int>(json['servingGrams']),
      calories: serializer.fromJson<int>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fat: serializer.fromJson<double>(json['fat']),
      fiber: serializer.fromJson<double>(json['fiber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'aliases': serializer.toJson<String?>(aliases),
      'category': serializer.toJson<String>(category),
      'region': serializer.toJson<String>(region),
      'servingSize': serializer.toJson<String>(servingSize),
      'servingGrams': serializer.toJson<int>(servingGrams),
      'calories': serializer.toJson<int>(calories),
      'protein': serializer.toJson<double>(protein),
      'carbs': serializer.toJson<double>(carbs),
      'fat': serializer.toJson<double>(fat),
      'fiber': serializer.toJson<double>(fiber),
    };
  }

  IndianFood copyWith(
          {int? id,
          String? name,
          Value<String?> aliases = const Value.absent(),
          String? category,
          String? region,
          String? servingSize,
          int? servingGrams,
          int? calories,
          double? protein,
          double? carbs,
          double? fat,
          double? fiber}) =>
      IndianFood(
        id: id ?? this.id,
        name: name ?? this.name,
        aliases: aliases.present ? aliases.value : this.aliases,
        category: category ?? this.category,
        region: region ?? this.region,
        servingSize: servingSize ?? this.servingSize,
        servingGrams: servingGrams ?? this.servingGrams,
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
        carbs: carbs ?? this.carbs,
        fat: fat ?? this.fat,
        fiber: fiber ?? this.fiber,
      );
  IndianFood copyWithCompanion(IndianFoodsCompanion data) {
    return IndianFood(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      category: data.category.present ? data.category.value : this.category,
      region: data.region.present ? data.region.value : this.region,
      servingSize:
          data.servingSize.present ? data.servingSize.value : this.servingSize,
      servingGrams: data.servingGrams.present
          ? data.servingGrams.value
          : this.servingGrams,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IndianFood(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('category: $category, ')
          ..write('region: $region, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingGrams: $servingGrams, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, aliases, category, region,
      servingSize, servingGrams, calories, protein, carbs, fat, fiber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IndianFood &&
          other.id == this.id &&
          other.name == this.name &&
          other.aliases == this.aliases &&
          other.category == this.category &&
          other.region == this.region &&
          other.servingSize == this.servingSize &&
          other.servingGrams == this.servingGrams &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.fiber == this.fiber);
}

class IndianFoodsCompanion extends UpdateCompanion<IndianFood> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> aliases;
  final Value<String> category;
  final Value<String> region;
  final Value<String> servingSize;
  final Value<int> servingGrams;
  final Value<int> calories;
  final Value<double> protein;
  final Value<double> carbs;
  final Value<double> fat;
  final Value<double> fiber;
  const IndianFoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.aliases = const Value.absent(),
    this.category = const Value.absent(),
    this.region = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.servingGrams = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
  });
  IndianFoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.aliases = const Value.absent(),
    required String category,
    required String region,
    required String servingSize,
    required int servingGrams,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
  })  : name = Value(name),
        category = Value(category),
        region = Value(region),
        servingSize = Value(servingSize),
        servingGrams = Value(servingGrams),
        calories = Value(calories),
        protein = Value(protein),
        carbs = Value(carbs),
        fat = Value(fat),
        fiber = Value(fiber);
  static Insertable<IndianFood> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? aliases,
    Expression<String>? category,
    Expression<String>? region,
    Expression<String>? servingSize,
    Expression<int>? servingGrams,
    Expression<int>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<double>? fiber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (aliases != null) 'aliases': aliases,
      if (category != null) 'category': category,
      if (region != null) 'region': region,
      if (servingSize != null) 'serving_size': servingSize,
      if (servingGrams != null) 'serving_grams': servingGrams,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
    });
  }

  IndianFoodsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? aliases,
      Value<String>? category,
      Value<String>? region,
      Value<String>? servingSize,
      Value<int>? servingGrams,
      Value<int>? calories,
      Value<double>? protein,
      Value<double>? carbs,
      Value<double>? fat,
      Value<double>? fiber}) {
    return IndianFoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      aliases: aliases ?? this.aliases,
      category: category ?? this.category,
      region: region ?? this.region,
      servingSize: servingSize ?? this.servingSize,
      servingGrams: servingGrams ?? this.servingGrams,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (servingSize.present) {
      map['serving_size'] = Variable<String>(servingSize.value);
    }
    if (servingGrams.present) {
      map['serving_grams'] = Variable<int>(servingGrams.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IndianFoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('category: $category, ')
          ..write('region: $region, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingGrams: $servingGrams, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber')
          ..write(')'))
        .toString();
  }
}

class $FavoriteFoodsTable extends FavoriteFoods
    with TableInfo<$FavoriteFoodsTable, FavoriteFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portionMeta =
      const VerificationMeta('portion');
  @override
  late final GeneratedColumn<String> portion = GeneratedColumn<String>(
      'portion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portionGramsMeta =
      const VerificationMeta('portionGrams');
  @override
  late final GeneratedColumn<int> portionGrams = GeneratedColumn<int>(
      'portion_grams', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _caloriesMeta =
      const VerificationMeta('calories');
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
      'calories', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _proteinMeta =
      const VerificationMeta('protein');
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
      'protein', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
      'fat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
      'fiber', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        portion,
        portionGrams,
        calories,
        protein,
        carbs,
        fat,
        fiber,
        isCustom,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_foods';
  @override
  VerificationContext validateIntegrity(Insertable<FavoriteFood> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('portion')) {
      context.handle(_portionMeta,
          portion.isAcceptableOrUnknown(data['portion']!, _portionMeta));
    } else if (isInserting) {
      context.missing(_portionMeta);
    }
    if (data.containsKey('portion_grams')) {
      context.handle(
          _portionGramsMeta,
          portionGrams.isAcceptableOrUnknown(
              data['portion_grams']!, _portionGramsMeta));
    } else if (isInserting) {
      context.missing(_portionGramsMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(_caloriesMeta,
          calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta));
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta,
          protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
          _fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('fiber')) {
      context.handle(
          _fiberMeta, fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta));
    } else if (isInserting) {
      context.missing(_fiberMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteFood(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      portion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}portion'])!,
      portionGrams: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}portion_grams'])!,
      calories: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}calories'])!,
      protein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
      fat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat'])!,
      fiber: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fiber'])!,
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FavoriteFoodsTable createAlias(String alias) {
    return $FavoriteFoodsTable(attachedDatabase, alias);
  }
}

class FavoriteFood extends DataClass implements Insertable<FavoriteFood> {
  final int id;
  final String name;
  final String portion;
  final int portionGrams;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final bool isCustom;
  final int createdAt;
  const FavoriteFood(
      {required this.id,
      required this.name,
      required this.portion,
      required this.portionGrams,
      required this.calories,
      required this.protein,
      required this.carbs,
      required this.fat,
      required this.fiber,
      required this.isCustom,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['portion'] = Variable<String>(portion);
    map['portion_grams'] = Variable<int>(portionGrams);
    map['calories'] = Variable<int>(calories);
    map['protein'] = Variable<double>(protein);
    map['carbs'] = Variable<double>(carbs);
    map['fat'] = Variable<double>(fat);
    map['fiber'] = Variable<double>(fiber);
    map['is_custom'] = Variable<bool>(isCustom);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  FavoriteFoodsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteFoodsCompanion(
      id: Value(id),
      name: Value(name),
      portion: Value(portion),
      portionGrams: Value(portionGrams),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      fiber: Value(fiber),
      isCustom: Value(isCustom),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteFood.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteFood(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      portion: serializer.fromJson<String>(json['portion']),
      portionGrams: serializer.fromJson<int>(json['portionGrams']),
      calories: serializer.fromJson<int>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fat: serializer.fromJson<double>(json['fat']),
      fiber: serializer.fromJson<double>(json['fiber']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'portion': serializer.toJson<String>(portion),
      'portionGrams': serializer.toJson<int>(portionGrams),
      'calories': serializer.toJson<int>(calories),
      'protein': serializer.toJson<double>(protein),
      'carbs': serializer.toJson<double>(carbs),
      'fat': serializer.toJson<double>(fat),
      'fiber': serializer.toJson<double>(fiber),
      'isCustom': serializer.toJson<bool>(isCustom),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  FavoriteFood copyWith(
          {int? id,
          String? name,
          String? portion,
          int? portionGrams,
          int? calories,
          double? protein,
          double? carbs,
          double? fat,
          double? fiber,
          bool? isCustom,
          int? createdAt}) =>
      FavoriteFood(
        id: id ?? this.id,
        name: name ?? this.name,
        portion: portion ?? this.portion,
        portionGrams: portionGrams ?? this.portionGrams,
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
        carbs: carbs ?? this.carbs,
        fat: fat ?? this.fat,
        fiber: fiber ?? this.fiber,
        isCustom: isCustom ?? this.isCustom,
        createdAt: createdAt ?? this.createdAt,
      );
  FavoriteFood copyWithCompanion(FavoriteFoodsCompanion data) {
    return FavoriteFood(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      portion: data.portion.present ? data.portion.value : this.portion,
      portionGrams: data.portionGrams.present
          ? data.portionGrams.value
          : this.portionGrams,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFood(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('portion: $portion, ')
          ..write('portionGrams: $portionGrams, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, portion, portionGrams, calories,
      protein, carbs, fat, fiber, isCustom, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteFood &&
          other.id == this.id &&
          other.name == this.name &&
          other.portion == this.portion &&
          other.portionGrams == this.portionGrams &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.fiber == this.fiber &&
          other.isCustom == this.isCustom &&
          other.createdAt == this.createdAt);
}

class FavoriteFoodsCompanion extends UpdateCompanion<FavoriteFood> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> portion;
  final Value<int> portionGrams;
  final Value<int> calories;
  final Value<double> protein;
  final Value<double> carbs;
  final Value<double> fat;
  final Value<double> fiber;
  final Value<bool> isCustom;
  final Value<int> createdAt;
  const FavoriteFoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.portion = const Value.absent(),
    this.portionGrams = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FavoriteFoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String portion,
    required int portionGrams,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
    this.isCustom = const Value.absent(),
    required int createdAt,
  })  : name = Value(name),
        portion = Value(portion),
        portionGrams = Value(portionGrams),
        calories = Value(calories),
        protein = Value(protein),
        carbs = Value(carbs),
        fat = Value(fat),
        fiber = Value(fiber),
        createdAt = Value(createdAt);
  static Insertable<FavoriteFood> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? portion,
    Expression<int>? portionGrams,
    Expression<int>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<double>? fiber,
    Expression<bool>? isCustom,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (portion != null) 'portion': portion,
      if (portionGrams != null) 'portion_grams': portionGrams,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (isCustom != null) 'is_custom': isCustom,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FavoriteFoodsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? portion,
      Value<int>? portionGrams,
      Value<int>? calories,
      Value<double>? protein,
      Value<double>? carbs,
      Value<double>? fat,
      Value<double>? fiber,
      Value<bool>? isCustom,
      Value<int>? createdAt}) {
    return FavoriteFoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      portion: portion ?? this.portion,
      portionGrams: portionGrams ?? this.portionGrams,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (portion.present) {
      map['portion'] = Variable<String>(portion.value);
    }
    if (portionGrams.present) {
      map['portion_grams'] = Variable<int>(portionGrams.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('portion: $portion, ')
          ..write('portionGrams: $portionGrams, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MealsTable meals = $MealsTable(this);
  late final $MealItemsTable mealItems = $MealItemsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $IndianFoodsTable indianFoods = $IndianFoodsTable(this);
  late final $FavoriteFoodsTable favoriteFoods = $FavoriteFoodsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [meals, mealItems, userSettings, indianFoods, favoriteFoods];
}

typedef $$MealsTableCreateCompanionBuilder = MealsCompanion Function({
  required String id,
  required String date,
  required int timestamp,
  required int mealNumber,
  Value<String?> mealType,
  required String source,
  required int totalCalories,
  required double totalProtein,
  required double totalCarbs,
  required double totalFat,
  required double totalFiber,
  Value<int> rowid,
});
typedef $$MealsTableUpdateCompanionBuilder = MealsCompanion Function({
  Value<String> id,
  Value<String> date,
  Value<int> timestamp,
  Value<int> mealNumber,
  Value<String?> mealType,
  Value<String> source,
  Value<int> totalCalories,
  Value<double> totalProtein,
  Value<double> totalCarbs,
  Value<double> totalFat,
  Value<double> totalFiber,
  Value<int> rowid,
});

final class $$MealsTableReferences
    extends BaseReferences<_$AppDatabase, $MealsTable, Meal> {
  $$MealsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MealItemsTable, List<MealItem>>
      _mealItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.mealItems,
          aliasName: $_aliasNameGenerator(db.meals.id, db.mealItems.mealId));

  $$MealItemsTableProcessedTableManager get mealItemsRefs {
    final manager = $$MealItemsTableTableManager($_db, $_db.mealItems)
        .filter((f) => f.mealId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mealItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MealsTableFilterComposer extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mealNumber => $composableBuilder(
      column: $table.mealNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalCalories => $composableBuilder(
      column: $table.totalCalories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalProtein => $composableBuilder(
      column: $table.totalProtein, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalCarbs => $composableBuilder(
      column: $table.totalCarbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalFat => $composableBuilder(
      column: $table.totalFat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalFiber => $composableBuilder(
      column: $table.totalFiber, builder: (column) => ColumnFilters(column));

  Expression<bool> mealItemsRefs(
      Expression<bool> Function($$MealItemsTableFilterComposer f) f) {
    final $$MealItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mealItems,
        getReferencedColumn: (t) => t.mealId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealItemsTableFilterComposer(
              $db: $db,
              $table: $db.mealItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MealsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mealNumber => $composableBuilder(
      column: $table.mealNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalCalories => $composableBuilder(
      column: $table.totalCalories,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalProtein => $composableBuilder(
      column: $table.totalProtein,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalCarbs => $composableBuilder(
      column: $table.totalCarbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalFat => $composableBuilder(
      column: $table.totalFat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalFiber => $composableBuilder(
      column: $table.totalFiber, builder: (column) => ColumnOrderings(column));
}

class $$MealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get mealNumber => $composableBuilder(
      column: $table.mealNumber, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get totalCalories => $composableBuilder(
      column: $table.totalCalories, builder: (column) => column);

  GeneratedColumn<double> get totalProtein => $composableBuilder(
      column: $table.totalProtein, builder: (column) => column);

  GeneratedColumn<double> get totalCarbs => $composableBuilder(
      column: $table.totalCarbs, builder: (column) => column);

  GeneratedColumn<double> get totalFat =>
      $composableBuilder(column: $table.totalFat, builder: (column) => column);

  GeneratedColumn<double> get totalFiber => $composableBuilder(
      column: $table.totalFiber, builder: (column) => column);

  Expression<T> mealItemsRefs<T extends Object>(
      Expression<T> Function($$MealItemsTableAnnotationComposer a) f) {
    final $$MealItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mealItems,
        getReferencedColumn: (t) => t.mealId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.mealItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MealsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealsTable,
    Meal,
    $$MealsTableFilterComposer,
    $$MealsTableOrderingComposer,
    $$MealsTableAnnotationComposer,
    $$MealsTableCreateCompanionBuilder,
    $$MealsTableUpdateCompanionBuilder,
    (Meal, $$MealsTableReferences),
    Meal,
    PrefetchHooks Function({bool mealItemsRefs})> {
  $$MealsTableTableManager(_$AppDatabase db, $MealsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<int> mealNumber = const Value.absent(),
            Value<String?> mealType = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int> totalCalories = const Value.absent(),
            Value<double> totalProtein = const Value.absent(),
            Value<double> totalCarbs = const Value.absent(),
            Value<double> totalFat = const Value.absent(),
            Value<double> totalFiber = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MealsCompanion(
            id: id,
            date: date,
            timestamp: timestamp,
            mealNumber: mealNumber,
            mealType: mealType,
            source: source,
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            totalFiber: totalFiber,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String date,
            required int timestamp,
            required int mealNumber,
            Value<String?> mealType = const Value.absent(),
            required String source,
            required int totalCalories,
            required double totalProtein,
            required double totalCarbs,
            required double totalFat,
            required double totalFiber,
            Value<int> rowid = const Value.absent(),
          }) =>
              MealsCompanion.insert(
            id: id,
            date: date,
            timestamp: timestamp,
            mealNumber: mealNumber,
            mealType: mealType,
            source: source,
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            totalFiber: totalFiber,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MealsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({mealItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (mealItemsRefs) db.mealItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mealItemsRefs)
                    await $_getPrefetchedData<Meal, $MealsTable, MealItem>(
                        currentTable: table,
                        referencedTable:
                            $$MealsTableReferences._mealItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MealsTableReferences(db, table, p0).mealItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.mealId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MealsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealsTable,
    Meal,
    $$MealsTableFilterComposer,
    $$MealsTableOrderingComposer,
    $$MealsTableAnnotationComposer,
    $$MealsTableCreateCompanionBuilder,
    $$MealsTableUpdateCompanionBuilder,
    (Meal, $$MealsTableReferences),
    Meal,
    PrefetchHooks Function({bool mealItemsRefs})>;
typedef $$MealItemsTableCreateCompanionBuilder = MealItemsCompanion Function({
  required String id,
  required String mealId,
  required String name,
  required String portion,
  required int portionGrams,
  required int calories,
  required double protein,
  required double carbs,
  required double fat,
  required double fiber,
  Value<bool> isEdited,
  Value<int> rowid,
});
typedef $$MealItemsTableUpdateCompanionBuilder = MealItemsCompanion Function({
  Value<String> id,
  Value<String> mealId,
  Value<String> name,
  Value<String> portion,
  Value<int> portionGrams,
  Value<int> calories,
  Value<double> protein,
  Value<double> carbs,
  Value<double> fat,
  Value<double> fiber,
  Value<bool> isEdited,
  Value<int> rowid,
});

final class $$MealItemsTableReferences
    extends BaseReferences<_$AppDatabase, $MealItemsTable, MealItem> {
  $$MealItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MealsTable _mealIdTable(_$AppDatabase db) => db.meals
      .createAlias($_aliasNameGenerator(db.mealItems.mealId, db.meals.id));

  $$MealsTableProcessedTableManager get mealId {
    final $_column = $_itemColumn<String>('meal_id')!;

    final manager = $$MealsTableTableManager($_db, $_db.meals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mealIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MealItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get portion => $composableBuilder(
      column: $table.portion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get portionGrams => $composableBuilder(
      column: $table.portionGrams, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEdited => $composableBuilder(
      column: $table.isEdited, builder: (column) => ColumnFilters(column));

  $$MealsTableFilterComposer get mealId {
    final $$MealsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mealId,
        referencedTable: $db.meals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealsTableFilterComposer(
              $db: $db,
              $table: $db.meals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MealItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get portion => $composableBuilder(
      column: $table.portion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get portionGrams => $composableBuilder(
      column: $table.portionGrams,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEdited => $composableBuilder(
      column: $table.isEdited, builder: (column) => ColumnOrderings(column));

  $$MealsTableOrderingComposer get mealId {
    final $$MealsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mealId,
        referencedTable: $db.meals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealsTableOrderingComposer(
              $db: $db,
              $table: $db.meals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MealItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get portion =>
      $composableBuilder(column: $table.portion, builder: (column) => column);

  GeneratedColumn<int> get portionGrams => $composableBuilder(
      column: $table.portionGrams, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<bool> get isEdited =>
      $composableBuilder(column: $table.isEdited, builder: (column) => column);

  $$MealsTableAnnotationComposer get mealId {
    final $$MealsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mealId,
        referencedTable: $db.meals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealsTableAnnotationComposer(
              $db: $db,
              $table: $db.meals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MealItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealItemsTable,
    MealItem,
    $$MealItemsTableFilterComposer,
    $$MealItemsTableOrderingComposer,
    $$MealItemsTableAnnotationComposer,
    $$MealItemsTableCreateCompanionBuilder,
    $$MealItemsTableUpdateCompanionBuilder,
    (MealItem, $$MealItemsTableReferences),
    MealItem,
    PrefetchHooks Function({bool mealId})> {
  $$MealItemsTableTableManager(_$AppDatabase db, $MealItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> mealId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> portion = const Value.absent(),
            Value<int> portionGrams = const Value.absent(),
            Value<int> calories = const Value.absent(),
            Value<double> protein = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double> fat = const Value.absent(),
            Value<double> fiber = const Value.absent(),
            Value<bool> isEdited = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MealItemsCompanion(
            id: id,
            mealId: mealId,
            name: name,
            portion: portion,
            portionGrams: portionGrams,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            isEdited: isEdited,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String mealId,
            required String name,
            required String portion,
            required int portionGrams,
            required int calories,
            required double protein,
            required double carbs,
            required double fat,
            required double fiber,
            Value<bool> isEdited = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MealItemsCompanion.insert(
            id: id,
            mealId: mealId,
            name: name,
            portion: portion,
            portionGrams: portionGrams,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            isEdited: isEdited,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MealItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mealId = false}) {
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
                if (mealId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mealId,
                    referencedTable:
                        $$MealItemsTableReferences._mealIdTable(db),
                    referencedColumn:
                        $$MealItemsTableReferences._mealIdTable(db).id,
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

typedef $$MealItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealItemsTable,
    MealItem,
    $$MealItemsTableFilterComposer,
    $$MealItemsTableOrderingComposer,
    $$MealItemsTableAnnotationComposer,
    $$MealItemsTableCreateCompanionBuilder,
    $$MealItemsTableUpdateCompanionBuilder,
    (MealItem, $$MealItemsTableReferences),
    MealItem,
    PrefetchHooks Function({bool mealId})>;
typedef $$UserSettingsTableCreateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<int> id,
  Value<int> calorieGoal,
  Value<double> proteinGoal,
  Value<double> carbsGoal,
  Value<double> fatGoal,
  Value<double> fiberGoal,
  required int createdAt,
  Value<int?> age,
  Value<double?> weightKg,
  Value<double?> heightCm,
  Value<String?> gender,
  Value<String?> activityLevel,
  Value<String?> fitnessGoal,
  Value<double?> targetWeightKg,
  Value<int?> calculatedBmr,
  Value<int?> calculatedTdee,
});
typedef $$UserSettingsTableUpdateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<int> id,
  Value<int> calorieGoal,
  Value<double> proteinGoal,
  Value<double> carbsGoal,
  Value<double> fatGoal,
  Value<double> fiberGoal,
  Value<int> createdAt,
  Value<int?> age,
  Value<double?> weightKg,
  Value<double?> heightCm,
  Value<String?> gender,
  Value<String?> activityLevel,
  Value<String?> fitnessGoal,
  Value<double?> targetWeightKg,
  Value<int?> calculatedBmr,
  Value<int?> calculatedTdee,
});

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinGoal => $composableBuilder(
      column: $table.proteinGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbsGoal => $composableBuilder(
      column: $table.carbsGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatGoal => $composableBuilder(
      column: $table.fatGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fiberGoal => $composableBuilder(
      column: $table.fiberGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fitnessGoal => $composableBuilder(
      column: $table.fitnessGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
      column: $table.targetWeightKg,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get calculatedBmr => $composableBuilder(
      column: $table.calculatedBmr, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get calculatedTdee => $composableBuilder(
      column: $table.calculatedTdee,
      builder: (column) => ColumnFilters(column));
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinGoal => $composableBuilder(
      column: $table.proteinGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbsGoal => $composableBuilder(
      column: $table.carbsGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatGoal => $composableBuilder(
      column: $table.fatGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fiberGoal => $composableBuilder(
      column: $table.fiberGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fitnessGoal => $composableBuilder(
      column: $table.fitnessGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
      column: $table.targetWeightKg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get calculatedBmr => $composableBuilder(
      column: $table.calculatedBmr,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get calculatedTdee => $composableBuilder(
      column: $table.calculatedTdee,
      builder: (column) => ColumnOrderings(column));
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => column);

  GeneratedColumn<double> get proteinGoal => $composableBuilder(
      column: $table.proteinGoal, builder: (column) => column);

  GeneratedColumn<double> get carbsGoal =>
      $composableBuilder(column: $table.carbsGoal, builder: (column) => column);

  GeneratedColumn<double> get fatGoal =>
      $composableBuilder(column: $table.fatGoal, builder: (column) => column);

  GeneratedColumn<double> get fiberGoal =>
      $composableBuilder(column: $table.fiberGoal, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel, builder: (column) => column);

  GeneratedColumn<String> get fitnessGoal => $composableBuilder(
      column: $table.fitnessGoal, builder: (column) => column);

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
      column: $table.targetWeightKg, builder: (column) => column);

  GeneratedColumn<int> get calculatedBmr => $composableBuilder(
      column: $table.calculatedBmr, builder: (column) => column);

  GeneratedColumn<int> get calculatedTdee => $composableBuilder(
      column: $table.calculatedTdee, builder: (column) => column);
}

class $$UserSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()> {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> calorieGoal = const Value.absent(),
            Value<double> proteinGoal = const Value.absent(),
            Value<double> carbsGoal = const Value.absent(),
            Value<double> fatGoal = const Value.absent(),
            Value<double> fiberGoal = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> activityLevel = const Value.absent(),
            Value<String?> fitnessGoal = const Value.absent(),
            Value<double?> targetWeightKg = const Value.absent(),
            Value<int?> calculatedBmr = const Value.absent(),
            Value<int?> calculatedTdee = const Value.absent(),
          }) =>
              UserSettingsCompanion(
            id: id,
            calorieGoal: calorieGoal,
            proteinGoal: proteinGoal,
            carbsGoal: carbsGoal,
            fatGoal: fatGoal,
            fiberGoal: fiberGoal,
            createdAt: createdAt,
            age: age,
            weightKg: weightKg,
            heightCm: heightCm,
            gender: gender,
            activityLevel: activityLevel,
            fitnessGoal: fitnessGoal,
            targetWeightKg: targetWeightKg,
            calculatedBmr: calculatedBmr,
            calculatedTdee: calculatedTdee,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> calorieGoal = const Value.absent(),
            Value<double> proteinGoal = const Value.absent(),
            Value<double> carbsGoal = const Value.absent(),
            Value<double> fatGoal = const Value.absent(),
            Value<double> fiberGoal = const Value.absent(),
            required int createdAt,
            Value<int?> age = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> activityLevel = const Value.absent(),
            Value<String?> fitnessGoal = const Value.absent(),
            Value<double?> targetWeightKg = const Value.absent(),
            Value<int?> calculatedBmr = const Value.absent(),
            Value<int?> calculatedTdee = const Value.absent(),
          }) =>
              UserSettingsCompanion.insert(
            id: id,
            calorieGoal: calorieGoal,
            proteinGoal: proteinGoal,
            carbsGoal: carbsGoal,
            fatGoal: fatGoal,
            fiberGoal: fiberGoal,
            createdAt: createdAt,
            age: age,
            weightKg: weightKg,
            heightCm: heightCm,
            gender: gender,
            activityLevel: activityLevel,
            fitnessGoal: fitnessGoal,
            targetWeightKg: targetWeightKg,
            calculatedBmr: calculatedBmr,
            calculatedTdee: calculatedTdee,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()>;
typedef $$IndianFoodsTableCreateCompanionBuilder = IndianFoodsCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String?> aliases,
  required String category,
  required String region,
  required String servingSize,
  required int servingGrams,
  required int calories,
  required double protein,
  required double carbs,
  required double fat,
  required double fiber,
});
typedef $$IndianFoodsTableUpdateCompanionBuilder = IndianFoodsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String?> aliases,
  Value<String> category,
  Value<String> region,
  Value<String> servingSize,
  Value<int> servingGrams,
  Value<int> calories,
  Value<double> protein,
  Value<double> carbs,
  Value<double> fat,
  Value<double> fiber,
});

class $$IndianFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $IndianFoodsTable> {
  $$IndianFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aliases => $composableBuilder(
      column: $table.aliases, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get servingSize => $composableBuilder(
      column: $table.servingSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get servingGrams => $composableBuilder(
      column: $table.servingGrams, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnFilters(column));
}

class $$IndianFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $IndianFoodsTable> {
  $$IndianFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aliases => $composableBuilder(
      column: $table.aliases, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get servingSize => $composableBuilder(
      column: $table.servingSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get servingGrams => $composableBuilder(
      column: $table.servingGrams,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnOrderings(column));
}

class $$IndianFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IndianFoodsTable> {
  $$IndianFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get servingSize => $composableBuilder(
      column: $table.servingSize, builder: (column) => column);

  GeneratedColumn<int> get servingGrams => $composableBuilder(
      column: $table.servingGrams, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);
}

class $$IndianFoodsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IndianFoodsTable,
    IndianFood,
    $$IndianFoodsTableFilterComposer,
    $$IndianFoodsTableOrderingComposer,
    $$IndianFoodsTableAnnotationComposer,
    $$IndianFoodsTableCreateCompanionBuilder,
    $$IndianFoodsTableUpdateCompanionBuilder,
    (IndianFood, BaseReferences<_$AppDatabase, $IndianFoodsTable, IndianFood>),
    IndianFood,
    PrefetchHooks Function()> {
  $$IndianFoodsTableTableManager(_$AppDatabase db, $IndianFoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IndianFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IndianFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IndianFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> aliases = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> region = const Value.absent(),
            Value<String> servingSize = const Value.absent(),
            Value<int> servingGrams = const Value.absent(),
            Value<int> calories = const Value.absent(),
            Value<double> protein = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double> fat = const Value.absent(),
            Value<double> fiber = const Value.absent(),
          }) =>
              IndianFoodsCompanion(
            id: id,
            name: name,
            aliases: aliases,
            category: category,
            region: region,
            servingSize: servingSize,
            servingGrams: servingGrams,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> aliases = const Value.absent(),
            required String category,
            required String region,
            required String servingSize,
            required int servingGrams,
            required int calories,
            required double protein,
            required double carbs,
            required double fat,
            required double fiber,
          }) =>
              IndianFoodsCompanion.insert(
            id: id,
            name: name,
            aliases: aliases,
            category: category,
            region: region,
            servingSize: servingSize,
            servingGrams: servingGrams,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$IndianFoodsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IndianFoodsTable,
    IndianFood,
    $$IndianFoodsTableFilterComposer,
    $$IndianFoodsTableOrderingComposer,
    $$IndianFoodsTableAnnotationComposer,
    $$IndianFoodsTableCreateCompanionBuilder,
    $$IndianFoodsTableUpdateCompanionBuilder,
    (IndianFood, BaseReferences<_$AppDatabase, $IndianFoodsTable, IndianFood>),
    IndianFood,
    PrefetchHooks Function()>;
typedef $$FavoriteFoodsTableCreateCompanionBuilder = FavoriteFoodsCompanion
    Function({
  Value<int> id,
  required String name,
  required String portion,
  required int portionGrams,
  required int calories,
  required double protein,
  required double carbs,
  required double fat,
  required double fiber,
  Value<bool> isCustom,
  required int createdAt,
});
typedef $$FavoriteFoodsTableUpdateCompanionBuilder = FavoriteFoodsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> portion,
  Value<int> portionGrams,
  Value<int> calories,
  Value<double> protein,
  Value<double> carbs,
  Value<double> fat,
  Value<double> fiber,
  Value<bool> isCustom,
  Value<int> createdAt,
});

class $$FavoriteFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get portion => $composableBuilder(
      column: $table.portion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get portionGrams => $composableBuilder(
      column: $table.portionGrams, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FavoriteFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get portion => $composableBuilder(
      column: $table.portion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get portionGrams => $composableBuilder(
      column: $table.portionGrams,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FavoriteFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get portion =>
      $composableBuilder(column: $table.portion, builder: (column) => column);

  GeneratedColumn<int> get portionGrams => $composableBuilder(
      column: $table.portionGrams, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoriteFoodsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FavoriteFoodsTable,
    FavoriteFood,
    $$FavoriteFoodsTableFilterComposer,
    $$FavoriteFoodsTableOrderingComposer,
    $$FavoriteFoodsTableAnnotationComposer,
    $$FavoriteFoodsTableCreateCompanionBuilder,
    $$FavoriteFoodsTableUpdateCompanionBuilder,
    (
      FavoriteFood,
      BaseReferences<_$AppDatabase, $FavoriteFoodsTable, FavoriteFood>
    ),
    FavoriteFood,
    PrefetchHooks Function()> {
  $$FavoriteFoodsTableTableManager(_$AppDatabase db, $FavoriteFoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> portion = const Value.absent(),
            Value<int> portionGrams = const Value.absent(),
            Value<int> calories = const Value.absent(),
            Value<double> protein = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double> fat = const Value.absent(),
            Value<double> fiber = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              FavoriteFoodsCompanion(
            id: id,
            name: name,
            portion: portion,
            portionGrams: portionGrams,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            isCustom: isCustom,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String portion,
            required int portionGrams,
            required int calories,
            required double protein,
            required double carbs,
            required double fat,
            required double fiber,
            Value<bool> isCustom = const Value.absent(),
            required int createdAt,
          }) =>
              FavoriteFoodsCompanion.insert(
            id: id,
            name: name,
            portion: portion,
            portionGrams: portionGrams,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            isCustom: isCustom,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavoriteFoodsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FavoriteFoodsTable,
    FavoriteFood,
    $$FavoriteFoodsTableFilterComposer,
    $$FavoriteFoodsTableOrderingComposer,
    $$FavoriteFoodsTableAnnotationComposer,
    $$FavoriteFoodsTableCreateCompanionBuilder,
    $$FavoriteFoodsTableUpdateCompanionBuilder,
    (
      FavoriteFood,
      BaseReferences<_$AppDatabase, $FavoriteFoodsTable, FavoriteFood>
    ),
    FavoriteFood,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db, _db.meals);
  $$MealItemsTableTableManager get mealItems =>
      $$MealItemsTableTableManager(_db, _db.mealItems);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$IndianFoodsTableTableManager get indianFoods =>
      $$IndianFoodsTableTableManager(_db, _db.indianFoods);
  $$FavoriteFoodsTableTableManager get favoriteFoods =>
      $$FavoriteFoodsTableTableManager(_db, _db.favoriteFoods);
}
