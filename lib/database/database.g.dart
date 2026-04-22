// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recipePkMeta = const VerificationMeta(
    'recipePk',
  );
  @override
  late final GeneratedColumn<String> recipePk = GeneratedColumn<String>(
    'recipe_pk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultYieldMeta = const VerificationMeta(
    'defaultYield',
  );
  @override
  late final GeneratedColumn<double> defaultYield = GeneratedColumn<double>(
    'default_yield',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yieldNameMeta = const VerificationMeta(
    'yieldName',
  );
  @override
  late final GeneratedColumn<String> yieldName = GeneratedColumn<String>(
    'yield_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetProfitMarginMeta =
      const VerificationMeta('targetProfitMargin');
  @override
  late final GeneratedColumn<double> targetProfitMargin =
      GeneratedColumn<double>(
        'target_profit_margin',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _targetPricePerPortionMeta =
      const VerificationMeta('targetPricePerPortion');
  @override
  late final GeneratedColumn<double> targetPricePerPortion =
      GeneratedColumn<double>(
        'target_price_per_portion',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _fixedOverheadCostMeta = const VerificationMeta(
    'fixedOverheadCost',
  );
  @override
  late final GeneratedColumn<double> fixedOverheadCost =
      GeneratedColumn<double>(
        'fixed_overhead_cost',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
    'colour',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _dateTimeModifiedMeta = const VerificationMeta(
    'dateTimeModified',
  );
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>(
        'date_time_modified',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: Constant(DateTime.now()),
      );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    recipePk,
    name,
    description,
    defaultYield,
    yieldName,
    targetProfitMargin,
    targetPricePerPortion,
    fixedOverheadCost,
    colour,
    dateCreated,
    dateTimeModified,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recipe_pk')) {
      context.handle(
        _recipePkMeta,
        recipePk.isAcceptableOrUnknown(data['recipe_pk']!, _recipePkMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('default_yield')) {
      context.handle(
        _defaultYieldMeta,
        defaultYield.isAcceptableOrUnknown(
          data['default_yield']!,
          _defaultYieldMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultYieldMeta);
    }
    if (data.containsKey('yield_name')) {
      context.handle(
        _yieldNameMeta,
        yieldName.isAcceptableOrUnknown(data['yield_name']!, _yieldNameMeta),
      );
    } else if (isInserting) {
      context.missing(_yieldNameMeta);
    }
    if (data.containsKey('target_profit_margin')) {
      context.handle(
        _targetProfitMarginMeta,
        targetProfitMargin.isAcceptableOrUnknown(
          data['target_profit_margin']!,
          _targetProfitMarginMeta,
        ),
      );
    }
    if (data.containsKey('target_price_per_portion')) {
      context.handle(
        _targetPricePerPortionMeta,
        targetPricePerPortion.isAcceptableOrUnknown(
          data['target_price_per_portion']!,
          _targetPricePerPortionMeta,
        ),
      );
    }
    if (data.containsKey('fixed_overhead_cost')) {
      context.handle(
        _fixedOverheadCostMeta,
        fixedOverheadCost.isAcceptableOrUnknown(
          data['fixed_overhead_cost']!,
          _fixedOverheadCostMeta,
        ),
      );
    }
    if (data.containsKey('colour')) {
      context.handle(
        _colourMeta,
        colour.isAcceptableOrUnknown(data['colour']!, _colourMeta),
      );
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
        _dateTimeModifiedMeta,
        dateTimeModified.isAcceptableOrUnknown(
          data['date_time_modified']!,
          _dateTimeModifiedMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recipePk};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      recipePk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_pk'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      defaultYield: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_yield'],
      )!,
      yieldName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yield_name'],
      )!,
      targetProfitMargin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_profit_margin'],
      )!,
      targetPricePerPortion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_price_per_portion'],
      )!,
      fixedOverheadCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fixed_overhead_cost'],
      )!,
      colour: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colour'],
      ),
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateTimeModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_time_modified'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final String recipePk;
  final String name;
  final String? description;
  final double defaultYield;
  final String yieldName;
  final double targetProfitMargin;
  final double targetPricePerPortion;
  final double fixedOverheadCost;
  final String? colour;
  final DateTime dateCreated;
  final DateTime? dateTimeModified;
  final bool archived;
  const Recipe({
    required this.recipePk,
    required this.name,
    this.description,
    required this.defaultYield,
    required this.yieldName,
    required this.targetProfitMargin,
    required this.targetPricePerPortion,
    required this.fixedOverheadCost,
    this.colour,
    required this.dateCreated,
    this.dateTimeModified,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recipe_pk'] = Variable<String>(recipePk);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['default_yield'] = Variable<double>(defaultYield);
    map['yield_name'] = Variable<String>(yieldName);
    map['target_profit_margin'] = Variable<double>(targetProfitMargin);
    map['target_price_per_portion'] = Variable<double>(targetPricePerPortion);
    map['fixed_overhead_cost'] = Variable<double>(fixedOverheadCost);
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String>(colour);
    }
    map['date_created'] = Variable<DateTime>(dateCreated);
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      recipePk: Value(recipePk),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      defaultYield: Value(defaultYield),
      yieldName: Value(yieldName),
      targetProfitMargin: Value(targetProfitMargin),
      targetPricePerPortion: Value(targetPricePerPortion),
      fixedOverheadCost: Value(fixedOverheadCost),
      colour: colour == null && nullToAbsent
          ? const Value.absent()
          : Value(colour),
      dateCreated: Value(dateCreated),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
      archived: Value(archived),
    );
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      recipePk: serializer.fromJson<String>(json['recipePk']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      defaultYield: serializer.fromJson<double>(json['defaultYield']),
      yieldName: serializer.fromJson<String>(json['yieldName']),
      targetProfitMargin: serializer.fromJson<double>(
        json['targetProfitMargin'],
      ),
      targetPricePerPortion: serializer.fromJson<double>(
        json['targetPricePerPortion'],
      ),
      fixedOverheadCost: serializer.fromJson<double>(json['fixedOverheadCost']),
      colour: serializer.fromJson<String?>(json['colour']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateTimeModified: serializer.fromJson<DateTime?>(
        json['dateTimeModified'],
      ),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recipePk': serializer.toJson<String>(recipePk),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'defaultYield': serializer.toJson<double>(defaultYield),
      'yieldName': serializer.toJson<String>(yieldName),
      'targetProfitMargin': serializer.toJson<double>(targetProfitMargin),
      'targetPricePerPortion': serializer.toJson<double>(targetPricePerPortion),
      'fixedOverheadCost': serializer.toJson<double>(fixedOverheadCost),
      'colour': serializer.toJson<String?>(colour),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Recipe copyWith({
    String? recipePk,
    String? name,
    Value<String?> description = const Value.absent(),
    double? defaultYield,
    String? yieldName,
    double? targetProfitMargin,
    double? targetPricePerPortion,
    double? fixedOverheadCost,
    Value<String?> colour = const Value.absent(),
    DateTime? dateCreated,
    Value<DateTime?> dateTimeModified = const Value.absent(),
    bool? archived,
  }) => Recipe(
    recipePk: recipePk ?? this.recipePk,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    defaultYield: defaultYield ?? this.defaultYield,
    yieldName: yieldName ?? this.yieldName,
    targetProfitMargin: targetProfitMargin ?? this.targetProfitMargin,
    targetPricePerPortion: targetPricePerPortion ?? this.targetPricePerPortion,
    fixedOverheadCost: fixedOverheadCost ?? this.fixedOverheadCost,
    colour: colour.present ? colour.value : this.colour,
    dateCreated: dateCreated ?? this.dateCreated,
    dateTimeModified: dateTimeModified.present
        ? dateTimeModified.value
        : this.dateTimeModified,
    archived: archived ?? this.archived,
  );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      recipePk: data.recipePk.present ? data.recipePk.value : this.recipePk,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      defaultYield: data.defaultYield.present
          ? data.defaultYield.value
          : this.defaultYield,
      yieldName: data.yieldName.present ? data.yieldName.value : this.yieldName,
      targetProfitMargin: data.targetProfitMargin.present
          ? data.targetProfitMargin.value
          : this.targetProfitMargin,
      targetPricePerPortion: data.targetPricePerPortion.present
          ? data.targetPricePerPortion.value
          : this.targetPricePerPortion,
      fixedOverheadCost: data.fixedOverheadCost.present
          ? data.fixedOverheadCost.value
          : this.fixedOverheadCost,
      colour: data.colour.present ? data.colour.value : this.colour,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateTimeModified: data.dateTimeModified.present
          ? data.dateTimeModified.value
          : this.dateTimeModified,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('recipePk: $recipePk, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('defaultYield: $defaultYield, ')
          ..write('yieldName: $yieldName, ')
          ..write('targetProfitMargin: $targetProfitMargin, ')
          ..write('targetPricePerPortion: $targetPricePerPortion, ')
          ..write('fixedOverheadCost: $fixedOverheadCost, ')
          ..write('colour: $colour, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    recipePk,
    name,
    description,
    defaultYield,
    yieldName,
    targetProfitMargin,
    targetPricePerPortion,
    fixedOverheadCost,
    colour,
    dateCreated,
    dateTimeModified,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.recipePk == this.recipePk &&
          other.name == this.name &&
          other.description == this.description &&
          other.defaultYield == this.defaultYield &&
          other.yieldName == this.yieldName &&
          other.targetProfitMargin == this.targetProfitMargin &&
          other.targetPricePerPortion == this.targetPricePerPortion &&
          other.fixedOverheadCost == this.fixedOverheadCost &&
          other.colour == this.colour &&
          other.dateCreated == this.dateCreated &&
          other.dateTimeModified == this.dateTimeModified &&
          other.archived == this.archived);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<String> recipePk;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> defaultYield;
  final Value<String> yieldName;
  final Value<double> targetProfitMargin;
  final Value<double> targetPricePerPortion;
  final Value<double> fixedOverheadCost;
  final Value<String?> colour;
  final Value<DateTime> dateCreated;
  final Value<DateTime?> dateTimeModified;
  final Value<bool> archived;
  final Value<int> rowid;
  const RecipesCompanion({
    this.recipePk = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.defaultYield = const Value.absent(),
    this.yieldName = const Value.absent(),
    this.targetProfitMargin = const Value.absent(),
    this.targetPricePerPortion = const Value.absent(),
    this.fixedOverheadCost = const Value.absent(),
    this.colour = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    this.recipePk = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required double defaultYield,
    required String yieldName,
    this.targetProfitMargin = const Value.absent(),
    this.targetPricePerPortion = const Value.absent(),
    this.fixedOverheadCost = const Value.absent(),
    this.colour = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       defaultYield = Value(defaultYield),
       yieldName = Value(yieldName);
  static Insertable<Recipe> custom({
    Expression<String>? recipePk,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? defaultYield,
    Expression<String>? yieldName,
    Expression<double>? targetProfitMargin,
    Expression<double>? targetPricePerPortion,
    Expression<double>? fixedOverheadCost,
    Expression<String>? colour,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateTimeModified,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recipePk != null) 'recipe_pk': recipePk,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (defaultYield != null) 'default_yield': defaultYield,
      if (yieldName != null) 'yield_name': yieldName,
      if (targetProfitMargin != null)
        'target_profit_margin': targetProfitMargin,
      if (targetPricePerPortion != null)
        'target_price_per_portion': targetPricePerPortion,
      if (fixedOverheadCost != null) 'fixed_overhead_cost': fixedOverheadCost,
      if (colour != null) 'colour': colour,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith({
    Value<String>? recipePk,
    Value<String>? name,
    Value<String?>? description,
    Value<double>? defaultYield,
    Value<String>? yieldName,
    Value<double>? targetProfitMargin,
    Value<double>? targetPricePerPortion,
    Value<double>? fixedOverheadCost,
    Value<String?>? colour,
    Value<DateTime>? dateCreated,
    Value<DateTime?>? dateTimeModified,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return RecipesCompanion(
      recipePk: recipePk ?? this.recipePk,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultYield: defaultYield ?? this.defaultYield,
      yieldName: yieldName ?? this.yieldName,
      targetProfitMargin: targetProfitMargin ?? this.targetProfitMargin,
      targetPricePerPortion:
          targetPricePerPortion ?? this.targetPricePerPortion,
      fixedOverheadCost: fixedOverheadCost ?? this.fixedOverheadCost,
      colour: colour ?? this.colour,
      dateCreated: dateCreated ?? this.dateCreated,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recipePk.present) {
      map['recipe_pk'] = Variable<String>(recipePk.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (defaultYield.present) {
      map['default_yield'] = Variable<double>(defaultYield.value);
    }
    if (yieldName.present) {
      map['yield_name'] = Variable<String>(yieldName.value);
    }
    if (targetProfitMargin.present) {
      map['target_profit_margin'] = Variable<double>(targetProfitMargin.value);
    }
    if (targetPricePerPortion.present) {
      map['target_price_per_portion'] = Variable<double>(
        targetPricePerPortion.value,
      );
    }
    if (fixedOverheadCost.present) {
      map['fixed_overhead_cost'] = Variable<double>(fixedOverheadCost.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('recipePk: $recipePk, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('defaultYield: $defaultYield, ')
          ..write('yieldName: $yieldName, ')
          ..write('targetProfitMargin: $targetProfitMargin, ')
          ..write('targetPricePerPortion: $targetPricePerPortion, ')
          ..write('fixedOverheadCost: $fixedOverheadCost, ')
          ..write('colour: $colour, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitsTable extends Units with TableInfo<$UnitsTable, Unit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _unitPkMeta = const VerificationMeta('unitPk');
  @override
  late final GeneratedColumn<String> unitPk = GeneratedColumn<String>(
    'unit_pk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _factorToBaseMeta = const VerificationMeta(
    'factorToBase',
  );
  @override
  late final GeneratedColumn<double> factorToBase = GeneratedColumn<double>(
    'factor_to_base',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _isMutableMeta = const VerificationMeta(
    'isMutable',
  );
  @override
  late final GeneratedColumn<bool> isMutable = GeneratedColumn<bool>(
    'is_mutable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mutable" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    unitPk,
    name,
    symbol,
    category,
    factorToBase,
    isMutable,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units';
  @override
  VerificationContext validateIntegrity(
    Insertable<Unit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('unit_pk')) {
      context.handle(
        _unitPkMeta,
        unitPk.isAcceptableOrUnknown(data['unit_pk']!, _unitPkMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('factor_to_base')) {
      context.handle(
        _factorToBaseMeta,
        factorToBase.isAcceptableOrUnknown(
          data['factor_to_base']!,
          _factorToBaseMeta,
        ),
      );
    }
    if (data.containsKey('is_mutable')) {
      context.handle(
        _isMutableMeta,
        isMutable.isAcceptableOrUnknown(data['is_mutable']!, _isMutableMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {unitPk};
  @override
  Unit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Unit(
      unitPk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_pk'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      factorToBase: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}factor_to_base'],
      )!,
      isMutable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mutable'],
      )!,
    );
  }

  @override
  $UnitsTable createAlias(String alias) {
    return $UnitsTable(attachedDatabase, alias);
  }
}

class Unit extends DataClass implements Insertable<Unit> {
  final String unitPk;
  final String name;
  final String symbol;
  final String? category;
  final double factorToBase;
  final bool isMutable;
  const Unit({
    required this.unitPk,
    required this.name,
    required this.symbol,
    this.category,
    required this.factorToBase,
    required this.isMutable,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['unit_pk'] = Variable<String>(unitPk);
    map['name'] = Variable<String>(name);
    map['symbol'] = Variable<String>(symbol);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['factor_to_base'] = Variable<double>(factorToBase);
    map['is_mutable'] = Variable<bool>(isMutable);
    return map;
  }

  UnitsCompanion toCompanion(bool nullToAbsent) {
    return UnitsCompanion(
      unitPk: Value(unitPk),
      name: Value(name),
      symbol: Value(symbol),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      factorToBase: Value(factorToBase),
      isMutable: Value(isMutable),
    );
  }

  factory Unit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Unit(
      unitPk: serializer.fromJson<String>(json['unitPk']),
      name: serializer.fromJson<String>(json['name']),
      symbol: serializer.fromJson<String>(json['symbol']),
      category: serializer.fromJson<String?>(json['category']),
      factorToBase: serializer.fromJson<double>(json['factorToBase']),
      isMutable: serializer.fromJson<bool>(json['isMutable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'unitPk': serializer.toJson<String>(unitPk),
      'name': serializer.toJson<String>(name),
      'symbol': serializer.toJson<String>(symbol),
      'category': serializer.toJson<String?>(category),
      'factorToBase': serializer.toJson<double>(factorToBase),
      'isMutable': serializer.toJson<bool>(isMutable),
    };
  }

  Unit copyWith({
    String? unitPk,
    String? name,
    String? symbol,
    Value<String?> category = const Value.absent(),
    double? factorToBase,
    bool? isMutable,
  }) => Unit(
    unitPk: unitPk ?? this.unitPk,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    category: category.present ? category.value : this.category,
    factorToBase: factorToBase ?? this.factorToBase,
    isMutable: isMutable ?? this.isMutable,
  );
  Unit copyWithCompanion(UnitsCompanion data) {
    return Unit(
      unitPk: data.unitPk.present ? data.unitPk.value : this.unitPk,
      name: data.name.present ? data.name.value : this.name,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      category: data.category.present ? data.category.value : this.category,
      factorToBase: data.factorToBase.present
          ? data.factorToBase.value
          : this.factorToBase,
      isMutable: data.isMutable.present ? data.isMutable.value : this.isMutable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Unit(')
          ..write('unitPk: $unitPk, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('category: $category, ')
          ..write('factorToBase: $factorToBase, ')
          ..write('isMutable: $isMutable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(unitPk, name, symbol, category, factorToBase, isMutable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unit &&
          other.unitPk == this.unitPk &&
          other.name == this.name &&
          other.symbol == this.symbol &&
          other.category == this.category &&
          other.factorToBase == this.factorToBase &&
          other.isMutable == this.isMutable);
}

class UnitsCompanion extends UpdateCompanion<Unit> {
  final Value<String> unitPk;
  final Value<String> name;
  final Value<String> symbol;
  final Value<String?> category;
  final Value<double> factorToBase;
  final Value<bool> isMutable;
  final Value<int> rowid;
  const UnitsCompanion({
    this.unitPk = const Value.absent(),
    this.name = const Value.absent(),
    this.symbol = const Value.absent(),
    this.category = const Value.absent(),
    this.factorToBase = const Value.absent(),
    this.isMutable = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitsCompanion.insert({
    this.unitPk = const Value.absent(),
    required String name,
    required String symbol,
    this.category = const Value.absent(),
    this.factorToBase = const Value.absent(),
    this.isMutable = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       symbol = Value(symbol);
  static Insertable<Unit> custom({
    Expression<String>? unitPk,
    Expression<String>? name,
    Expression<String>? symbol,
    Expression<String>? category,
    Expression<double>? factorToBase,
    Expression<bool>? isMutable,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (unitPk != null) 'unit_pk': unitPk,
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (category != null) 'category': category,
      if (factorToBase != null) 'factor_to_base': factorToBase,
      if (isMutable != null) 'is_mutable': isMutable,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitsCompanion copyWith({
    Value<String>? unitPk,
    Value<String>? name,
    Value<String>? symbol,
    Value<String?>? category,
    Value<double>? factorToBase,
    Value<bool>? isMutable,
    Value<int>? rowid,
  }) {
    return UnitsCompanion(
      unitPk: unitPk ?? this.unitPk,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      category: category ?? this.category,
      factorToBase: factorToBase ?? this.factorToBase,
      isMutable: isMutable ?? this.isMutable,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (unitPk.present) {
      map['unit_pk'] = Variable<String>(unitPk.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (factorToBase.present) {
      map['factor_to_base'] = Variable<double>(factorToBase.value);
    }
    if (isMutable.present) {
      map['is_mutable'] = Variable<bool>(isMutable.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitsCompanion(')
          ..write('unitPk: $unitPk, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('category: $category, ')
          ..write('factorToBase: $factorToBase, ')
          ..write('isMutable: $isMutable, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ingredientPkMeta = const VerificationMeta(
    'ingredientPk',
  );
  @override
  late final GeneratedColumn<String> ingredientPk = GeneratedColumn<String>(
    'ingredient_pk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityForCostMeta = const VerificationMeta(
    'quantityForCost',
  );
  @override
  late final GeneratedColumn<double> quantityForCost = GeneratedColumn<double>(
    'quantity_for_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitFkMeta = const VerificationMeta('unitFk');
  @override
  late final GeneratedColumn<String> unitFk = GeneratedColumn<String>(
    'unit_fk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES units (unit_pk)',
    ),
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _dateTimeModifiedMeta = const VerificationMeta(
    'dateTimeModified',
  );
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>(
        'date_time_modified',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: Constant(DateTime.now()),
      );
  @override
  List<GeneratedColumn> get $columns => [
    ingredientPk,
    name,
    cost,
    quantityForCost,
    unitFk,
    dateCreated,
    dateTimeModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ingredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ingredient_pk')) {
      context.handle(
        _ingredientPkMeta,
        ingredientPk.isAcceptableOrUnknown(
          data['ingredient_pk']!,
          _ingredientPkMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('quantity_for_cost')) {
      context.handle(
        _quantityForCostMeta,
        quantityForCost.isAcceptableOrUnknown(
          data['quantity_for_cost']!,
          _quantityForCostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityForCostMeta);
    }
    if (data.containsKey('unit_fk')) {
      context.handle(
        _unitFkMeta,
        unitFk.isAcceptableOrUnknown(data['unit_fk']!, _unitFkMeta),
      );
    } else if (isInserting) {
      context.missing(_unitFkMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
        _dateTimeModifiedMeta,
        dateTimeModified.isAcceptableOrUnknown(
          data['date_time_modified']!,
          _dateTimeModifiedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ingredientPk};
  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
      ingredientPk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_pk'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      quantityForCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_for_cost'],
      )!,
      unitFk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_fk'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateTimeModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_time_modified'],
      ),
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  final String ingredientPk;
  final String name;
  final double cost;
  final double quantityForCost;
  final String unitFk;
  final DateTime dateCreated;
  final DateTime? dateTimeModified;
  const Ingredient({
    required this.ingredientPk,
    required this.name,
    required this.cost,
    required this.quantityForCost,
    required this.unitFk,
    required this.dateCreated,
    this.dateTimeModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ingredient_pk'] = Variable<String>(ingredientPk);
    map['name'] = Variable<String>(name);
    map['cost'] = Variable<double>(cost);
    map['quantity_for_cost'] = Variable<double>(quantityForCost);
    map['unit_fk'] = Variable<String>(unitFk);
    map['date_created'] = Variable<DateTime>(dateCreated);
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      ingredientPk: Value(ingredientPk),
      name: Value(name),
      cost: Value(cost),
      quantityForCost: Value(quantityForCost),
      unitFk: Value(unitFk),
      dateCreated: Value(dateCreated),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
    );
  }

  factory Ingredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      ingredientPk: serializer.fromJson<String>(json['ingredientPk']),
      name: serializer.fromJson<String>(json['name']),
      cost: serializer.fromJson<double>(json['cost']),
      quantityForCost: serializer.fromJson<double>(json['quantityForCost']),
      unitFk: serializer.fromJson<String>(json['unitFk']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateTimeModified: serializer.fromJson<DateTime?>(
        json['dateTimeModified'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ingredientPk': serializer.toJson<String>(ingredientPk),
      'name': serializer.toJson<String>(name),
      'cost': serializer.toJson<double>(cost),
      'quantityForCost': serializer.toJson<double>(quantityForCost),
      'unitFk': serializer.toJson<String>(unitFk),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
    };
  }

  Ingredient copyWith({
    String? ingredientPk,
    String? name,
    double? cost,
    double? quantityForCost,
    String? unitFk,
    DateTime? dateCreated,
    Value<DateTime?> dateTimeModified = const Value.absent(),
  }) => Ingredient(
    ingredientPk: ingredientPk ?? this.ingredientPk,
    name: name ?? this.name,
    cost: cost ?? this.cost,
    quantityForCost: quantityForCost ?? this.quantityForCost,
    unitFk: unitFk ?? this.unitFk,
    dateCreated: dateCreated ?? this.dateCreated,
    dateTimeModified: dateTimeModified.present
        ? dateTimeModified.value
        : this.dateTimeModified,
  );
  Ingredient copyWithCompanion(IngredientsCompanion data) {
    return Ingredient(
      ingredientPk: data.ingredientPk.present
          ? data.ingredientPk.value
          : this.ingredientPk,
      name: data.name.present ? data.name.value : this.name,
      cost: data.cost.present ? data.cost.value : this.cost,
      quantityForCost: data.quantityForCost.present
          ? data.quantityForCost.value
          : this.quantityForCost,
      unitFk: data.unitFk.present ? data.unitFk.value : this.unitFk,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateTimeModified: data.dateTimeModified.present
          ? data.dateTimeModified.value
          : this.dateTimeModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('ingredientPk: $ingredientPk, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('quantityForCost: $quantityForCost, ')
          ..write('unitFk: $unitFk, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ingredientPk,
    name,
    cost,
    quantityForCost,
    unitFk,
    dateCreated,
    dateTimeModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.ingredientPk == this.ingredientPk &&
          other.name == this.name &&
          other.cost == this.cost &&
          other.quantityForCost == this.quantityForCost &&
          other.unitFk == this.unitFk &&
          other.dateCreated == this.dateCreated &&
          other.dateTimeModified == this.dateTimeModified);
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<String> ingredientPk;
  final Value<String> name;
  final Value<double> cost;
  final Value<double> quantityForCost;
  final Value<String> unitFk;
  final Value<DateTime> dateCreated;
  final Value<DateTime?> dateTimeModified;
  final Value<int> rowid;
  const IngredientsCompanion({
    this.ingredientPk = const Value.absent(),
    this.name = const Value.absent(),
    this.cost = const Value.absent(),
    this.quantityForCost = const Value.absent(),
    this.unitFk = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientsCompanion.insert({
    this.ingredientPk = const Value.absent(),
    required String name,
    required double cost,
    required double quantityForCost,
    required String unitFk,
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       cost = Value(cost),
       quantityForCost = Value(quantityForCost),
       unitFk = Value(unitFk);
  static Insertable<Ingredient> custom({
    Expression<String>? ingredientPk,
    Expression<String>? name,
    Expression<double>? cost,
    Expression<double>? quantityForCost,
    Expression<String>? unitFk,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateTimeModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ingredientPk != null) 'ingredient_pk': ingredientPk,
      if (name != null) 'name': name,
      if (cost != null) 'cost': cost,
      if (quantityForCost != null) 'quantity_for_cost': quantityForCost,
      if (unitFk != null) 'unit_fk': unitFk,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientsCompanion copyWith({
    Value<String>? ingredientPk,
    Value<String>? name,
    Value<double>? cost,
    Value<double>? quantityForCost,
    Value<String>? unitFk,
    Value<DateTime>? dateCreated,
    Value<DateTime?>? dateTimeModified,
    Value<int>? rowid,
  }) {
    return IngredientsCompanion(
      ingredientPk: ingredientPk ?? this.ingredientPk,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      quantityForCost: quantityForCost ?? this.quantityForCost,
      unitFk: unitFk ?? this.unitFk,
      dateCreated: dateCreated ?? this.dateCreated,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ingredientPk.present) {
      map['ingredient_pk'] = Variable<String>(ingredientPk.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (quantityForCost.present) {
      map['quantity_for_cost'] = Variable<double>(quantityForCost.value);
    }
    if (unitFk.present) {
      map['unit_fk'] = Variable<String>(unitFk.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('ingredientPk: $ingredientPk, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('quantityForCost: $quantityForCost, ')
          ..write('unitFk: $unitFk, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, RecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recipeIngredientPkMeta =
      const VerificationMeta('recipeIngredientPk');
  @override
  late final GeneratedColumn<String> recipeIngredientPk =
      GeneratedColumn<String>(
        'recipe_ingredient_pk',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => uuid.v4(),
      );
  static const VerificationMeta _recipeFkMeta = const VerificationMeta(
    'recipeFk',
  );
  @override
  late final GeneratedColumn<String> recipeFk = GeneratedColumn<String>(
    'recipe_fk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (recipe_pk)',
    ),
  );
  static const VerificationMeta _ingredientFkMeta = const VerificationMeta(
    'ingredientFk',
  );
  @override
  late final GeneratedColumn<String> ingredientFk = GeneratedColumn<String>(
    'ingredient_fk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (ingredient_pk)',
    ),
  );
  static const VerificationMeta _amountNeededMeta = const VerificationMeta(
    'amountNeeded',
  );
  @override
  late final GeneratedColumn<double> amountNeeded = GeneratedColumn<double>(
    'amount_needed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateTimeModifiedMeta = const VerificationMeta(
    'dateTimeModified',
  );
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>(
        'date_time_modified',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: Constant(DateTime.now()),
      );
  @override
  List<GeneratedColumn> get $columns => [
    recipeIngredientPk,
    recipeFk,
    ingredientFk,
    amountNeeded,
    dateTimeModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recipe_ingredient_pk')) {
      context.handle(
        _recipeIngredientPkMeta,
        recipeIngredientPk.isAcceptableOrUnknown(
          data['recipe_ingredient_pk']!,
          _recipeIngredientPkMeta,
        ),
      );
    }
    if (data.containsKey('recipe_fk')) {
      context.handle(
        _recipeFkMeta,
        recipeFk.isAcceptableOrUnknown(data['recipe_fk']!, _recipeFkMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeFkMeta);
    }
    if (data.containsKey('ingredient_fk')) {
      context.handle(
        _ingredientFkMeta,
        ingredientFk.isAcceptableOrUnknown(
          data['ingredient_fk']!,
          _ingredientFkMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientFkMeta);
    }
    if (data.containsKey('amount_needed')) {
      context.handle(
        _amountNeededMeta,
        amountNeeded.isAcceptableOrUnknown(
          data['amount_needed']!,
          _amountNeededMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountNeededMeta);
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
        _dateTimeModifiedMeta,
        dateTimeModified.isAcceptableOrUnknown(
          data['date_time_modified']!,
          _dateTimeModifiedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recipeIngredientPk};
  @override
  RecipeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredient(
      recipeIngredientPk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_ingredient_pk'],
      )!,
      recipeFk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_fk'],
      )!,
      ingredientFk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_fk'],
      )!,
      amountNeeded: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_needed'],
      )!,
      dateTimeModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_time_modified'],
      ),
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }
}

class RecipeIngredient extends DataClass
    implements Insertable<RecipeIngredient> {
  final String recipeIngredientPk;
  final String recipeFk;
  final String ingredientFk;
  final double amountNeeded;
  final DateTime? dateTimeModified;
  const RecipeIngredient({
    required this.recipeIngredientPk,
    required this.recipeFk,
    required this.ingredientFk,
    required this.amountNeeded,
    this.dateTimeModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recipe_ingredient_pk'] = Variable<String>(recipeIngredientPk);
    map['recipe_fk'] = Variable<String>(recipeFk);
    map['ingredient_fk'] = Variable<String>(ingredientFk);
    map['amount_needed'] = Variable<double>(amountNeeded);
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      recipeIngredientPk: Value(recipeIngredientPk),
      recipeFk: Value(recipeFk),
      ingredientFk: Value(ingredientFk),
      amountNeeded: Value(amountNeeded),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
    );
  }

  factory RecipeIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredient(
      recipeIngredientPk: serializer.fromJson<String>(
        json['recipeIngredientPk'],
      ),
      recipeFk: serializer.fromJson<String>(json['recipeFk']),
      ingredientFk: serializer.fromJson<String>(json['ingredientFk']),
      amountNeeded: serializer.fromJson<double>(json['amountNeeded']),
      dateTimeModified: serializer.fromJson<DateTime?>(
        json['dateTimeModified'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recipeIngredientPk': serializer.toJson<String>(recipeIngredientPk),
      'recipeFk': serializer.toJson<String>(recipeFk),
      'ingredientFk': serializer.toJson<String>(ingredientFk),
      'amountNeeded': serializer.toJson<double>(amountNeeded),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
    };
  }

  RecipeIngredient copyWith({
    String? recipeIngredientPk,
    String? recipeFk,
    String? ingredientFk,
    double? amountNeeded,
    Value<DateTime?> dateTimeModified = const Value.absent(),
  }) => RecipeIngredient(
    recipeIngredientPk: recipeIngredientPk ?? this.recipeIngredientPk,
    recipeFk: recipeFk ?? this.recipeFk,
    ingredientFk: ingredientFk ?? this.ingredientFk,
    amountNeeded: amountNeeded ?? this.amountNeeded,
    dateTimeModified: dateTimeModified.present
        ? dateTimeModified.value
        : this.dateTimeModified,
  );
  RecipeIngredient copyWithCompanion(RecipeIngredientsCompanion data) {
    return RecipeIngredient(
      recipeIngredientPk: data.recipeIngredientPk.present
          ? data.recipeIngredientPk.value
          : this.recipeIngredientPk,
      recipeFk: data.recipeFk.present ? data.recipeFk.value : this.recipeFk,
      ingredientFk: data.ingredientFk.present
          ? data.ingredientFk.value
          : this.ingredientFk,
      amountNeeded: data.amountNeeded.present
          ? data.amountNeeded.value
          : this.amountNeeded,
      dateTimeModified: data.dateTimeModified.present
          ? data.dateTimeModified.value
          : this.dateTimeModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredient(')
          ..write('recipeIngredientPk: $recipeIngredientPk, ')
          ..write('recipeFk: $recipeFk, ')
          ..write('ingredientFk: $ingredientFk, ')
          ..write('amountNeeded: $amountNeeded, ')
          ..write('dateTimeModified: $dateTimeModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    recipeIngredientPk,
    recipeFk,
    ingredientFk,
    amountNeeded,
    dateTimeModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredient &&
          other.recipeIngredientPk == this.recipeIngredientPk &&
          other.recipeFk == this.recipeFk &&
          other.ingredientFk == this.ingredientFk &&
          other.amountNeeded == this.amountNeeded &&
          other.dateTimeModified == this.dateTimeModified);
}

class RecipeIngredientsCompanion extends UpdateCompanion<RecipeIngredient> {
  final Value<String> recipeIngredientPk;
  final Value<String> recipeFk;
  final Value<String> ingredientFk;
  final Value<double> amountNeeded;
  final Value<DateTime?> dateTimeModified;
  final Value<int> rowid;
  const RecipeIngredientsCompanion({
    this.recipeIngredientPk = const Value.absent(),
    this.recipeFk = const Value.absent(),
    this.ingredientFk = const Value.absent(),
    this.amountNeeded = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    this.recipeIngredientPk = const Value.absent(),
    required String recipeFk,
    required String ingredientFk,
    required double amountNeeded,
    this.dateTimeModified = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : recipeFk = Value(recipeFk),
       ingredientFk = Value(ingredientFk),
       amountNeeded = Value(amountNeeded);
  static Insertable<RecipeIngredient> custom({
    Expression<String>? recipeIngredientPk,
    Expression<String>? recipeFk,
    Expression<String>? ingredientFk,
    Expression<double>? amountNeeded,
    Expression<DateTime>? dateTimeModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recipeIngredientPk != null)
        'recipe_ingredient_pk': recipeIngredientPk,
      if (recipeFk != null) 'recipe_fk': recipeFk,
      if (ingredientFk != null) 'ingredient_fk': ingredientFk,
      if (amountNeeded != null) 'amount_needed': amountNeeded,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeIngredientsCompanion copyWith({
    Value<String>? recipeIngredientPk,
    Value<String>? recipeFk,
    Value<String>? ingredientFk,
    Value<double>? amountNeeded,
    Value<DateTime?>? dateTimeModified,
    Value<int>? rowid,
  }) {
    return RecipeIngredientsCompanion(
      recipeIngredientPk: recipeIngredientPk ?? this.recipeIngredientPk,
      recipeFk: recipeFk ?? this.recipeFk,
      ingredientFk: ingredientFk ?? this.ingredientFk,
      amountNeeded: amountNeeded ?? this.amountNeeded,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recipeIngredientPk.present) {
      map['recipe_ingredient_pk'] = Variable<String>(recipeIngredientPk.value);
    }
    if (recipeFk.present) {
      map['recipe_fk'] = Variable<String>(recipeFk.value);
    }
    if (ingredientFk.present) {
      map['ingredient_fk'] = Variable<String>(ingredientFk.value);
    }
    if (amountNeeded.present) {
      map['amount_needed'] = Variable<double>(amountNeeded.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('recipeIngredientPk: $recipeIngredientPk, ')
          ..write('recipeFk: $recipeFk, ')
          ..write('ingredientFk: $ingredientFk, ')
          ..write('amountNeeded: $amountNeeded, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeStepsTable extends RecipeSteps
    with TableInfo<$RecipeStepsTable, RecipeStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stepPkMeta = const VerificationMeta('stepPk');
  @override
  late final GeneratedColumn<String> stepPk = GeneratedColumn<String>(
    'step_pk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _recipeFkMeta = const VerificationMeta(
    'recipeFk',
  );
  @override
  late final GeneratedColumn<String> recipeFk = GeneratedColumn<String>(
    'recipe_fk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (recipe_pk)',
    ),
  );
  static const VerificationMeta _stepNumberMeta = const VerificationMeta(
    'stepNumber',
  );
  @override
  late final GeneratedColumn<int> stepNumber = GeneratedColumn<int>(
    'step_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructionMeta = const VerificationMeta(
    'instruction',
  );
  @override
  late final GeneratedColumn<String> instruction = GeneratedColumn<String>(
    'instruction',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateTimeModifiedMeta = const VerificationMeta(
    'dateTimeModified',
  );
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>(
        'date_time_modified',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: Constant(DateTime.now()),
      );
  @override
  List<GeneratedColumn> get $columns => [
    stepPk,
    recipeFk,
    stepNumber,
    instruction,
    dateTimeModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('step_pk')) {
      context.handle(
        _stepPkMeta,
        stepPk.isAcceptableOrUnknown(data['step_pk']!, _stepPkMeta),
      );
    }
    if (data.containsKey('recipe_fk')) {
      context.handle(
        _recipeFkMeta,
        recipeFk.isAcceptableOrUnknown(data['recipe_fk']!, _recipeFkMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeFkMeta);
    }
    if (data.containsKey('step_number')) {
      context.handle(
        _stepNumberMeta,
        stepNumber.isAcceptableOrUnknown(data['step_number']!, _stepNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_stepNumberMeta);
    }
    if (data.containsKey('instruction')) {
      context.handle(
        _instructionMeta,
        instruction.isAcceptableOrUnknown(
          data['instruction']!,
          _instructionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructionMeta);
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
        _dateTimeModifiedMeta,
        dateTimeModified.isAcceptableOrUnknown(
          data['date_time_modified']!,
          _dateTimeModifiedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stepPk};
  @override
  RecipeStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeStep(
      stepPk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_pk'],
      )!,
      recipeFk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_fk'],
      )!,
      stepNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_number'],
      )!,
      instruction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instruction'],
      )!,
      dateTimeModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_time_modified'],
      ),
    );
  }

  @override
  $RecipeStepsTable createAlias(String alias) {
    return $RecipeStepsTable(attachedDatabase, alias);
  }
}

class RecipeStep extends DataClass implements Insertable<RecipeStep> {
  final String stepPk;
  final String recipeFk;
  final int stepNumber;
  final String instruction;
  final DateTime? dateTimeModified;
  const RecipeStep({
    required this.stepPk,
    required this.recipeFk,
    required this.stepNumber,
    required this.instruction,
    this.dateTimeModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['step_pk'] = Variable<String>(stepPk);
    map['recipe_fk'] = Variable<String>(recipeFk);
    map['step_number'] = Variable<int>(stepNumber);
    map['instruction'] = Variable<String>(instruction);
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    return map;
  }

  RecipeStepsCompanion toCompanion(bool nullToAbsent) {
    return RecipeStepsCompanion(
      stepPk: Value(stepPk),
      recipeFk: Value(recipeFk),
      stepNumber: Value(stepNumber),
      instruction: Value(instruction),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
    );
  }

  factory RecipeStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeStep(
      stepPk: serializer.fromJson<String>(json['stepPk']),
      recipeFk: serializer.fromJson<String>(json['recipeFk']),
      stepNumber: serializer.fromJson<int>(json['stepNumber']),
      instruction: serializer.fromJson<String>(json['instruction']),
      dateTimeModified: serializer.fromJson<DateTime?>(
        json['dateTimeModified'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stepPk': serializer.toJson<String>(stepPk),
      'recipeFk': serializer.toJson<String>(recipeFk),
      'stepNumber': serializer.toJson<int>(stepNumber),
      'instruction': serializer.toJson<String>(instruction),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
    };
  }

  RecipeStep copyWith({
    String? stepPk,
    String? recipeFk,
    int? stepNumber,
    String? instruction,
    Value<DateTime?> dateTimeModified = const Value.absent(),
  }) => RecipeStep(
    stepPk: stepPk ?? this.stepPk,
    recipeFk: recipeFk ?? this.recipeFk,
    stepNumber: stepNumber ?? this.stepNumber,
    instruction: instruction ?? this.instruction,
    dateTimeModified: dateTimeModified.present
        ? dateTimeModified.value
        : this.dateTimeModified,
  );
  RecipeStep copyWithCompanion(RecipeStepsCompanion data) {
    return RecipeStep(
      stepPk: data.stepPk.present ? data.stepPk.value : this.stepPk,
      recipeFk: data.recipeFk.present ? data.recipeFk.value : this.recipeFk,
      stepNumber: data.stepNumber.present
          ? data.stepNumber.value
          : this.stepNumber,
      instruction: data.instruction.present
          ? data.instruction.value
          : this.instruction,
      dateTimeModified: data.dateTimeModified.present
          ? data.dateTimeModified.value
          : this.dateTimeModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeStep(')
          ..write('stepPk: $stepPk, ')
          ..write('recipeFk: $recipeFk, ')
          ..write('stepNumber: $stepNumber, ')
          ..write('instruction: $instruction, ')
          ..write('dateTimeModified: $dateTimeModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(stepPk, recipeFk, stepNumber, instruction, dateTimeModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeStep &&
          other.stepPk == this.stepPk &&
          other.recipeFk == this.recipeFk &&
          other.stepNumber == this.stepNumber &&
          other.instruction == this.instruction &&
          other.dateTimeModified == this.dateTimeModified);
}

class RecipeStepsCompanion extends UpdateCompanion<RecipeStep> {
  final Value<String> stepPk;
  final Value<String> recipeFk;
  final Value<int> stepNumber;
  final Value<String> instruction;
  final Value<DateTime?> dateTimeModified;
  final Value<int> rowid;
  const RecipeStepsCompanion({
    this.stepPk = const Value.absent(),
    this.recipeFk = const Value.absent(),
    this.stepNumber = const Value.absent(),
    this.instruction = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeStepsCompanion.insert({
    this.stepPk = const Value.absent(),
    required String recipeFk,
    required int stepNumber,
    required String instruction,
    this.dateTimeModified = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : recipeFk = Value(recipeFk),
       stepNumber = Value(stepNumber),
       instruction = Value(instruction);
  static Insertable<RecipeStep> custom({
    Expression<String>? stepPk,
    Expression<String>? recipeFk,
    Expression<int>? stepNumber,
    Expression<String>? instruction,
    Expression<DateTime>? dateTimeModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stepPk != null) 'step_pk': stepPk,
      if (recipeFk != null) 'recipe_fk': recipeFk,
      if (stepNumber != null) 'step_number': stepNumber,
      if (instruction != null) 'instruction': instruction,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeStepsCompanion copyWith({
    Value<String>? stepPk,
    Value<String>? recipeFk,
    Value<int>? stepNumber,
    Value<String>? instruction,
    Value<DateTime?>? dateTimeModified,
    Value<int>? rowid,
  }) {
    return RecipeStepsCompanion(
      stepPk: stepPk ?? this.stepPk,
      recipeFk: recipeFk ?? this.recipeFk,
      stepNumber: stepNumber ?? this.stepNumber,
      instruction: instruction ?? this.instruction,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stepPk.present) {
      map['step_pk'] = Variable<String>(stepPk.value);
    }
    if (recipeFk.present) {
      map['recipe_fk'] = Variable<String>(recipeFk.value);
    }
    if (stepNumber.present) {
      map['step_number'] = Variable<int>(stepNumber.value);
    }
    if (instruction.present) {
      map['instruction'] = Variable<String>(instruction.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeStepsCompanion(')
          ..write('stepPk: $stepPk, ')
          ..write('recipeFk: $recipeFk, ')
          ..write('stepNumber: $stepNumber, ')
          ..write('instruction: $instruction, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $UnitsTable units = $UnitsTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $RecipeStepsTable recipeSteps = $RecipeStepsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recipes,
    units,
    ingredients,
    recipeIngredients,
    recipeSteps,
  ];
}

typedef $$RecipesTableCreateCompanionBuilder =
    RecipesCompanion Function({
      Value<String> recipePk,
      required String name,
      Value<String?> description,
      required double defaultYield,
      required String yieldName,
      Value<double> targetProfitMargin,
      Value<double> targetPricePerPortion,
      Value<double> fixedOverheadCost,
      Value<String?> colour,
      Value<DateTime> dateCreated,
      Value<DateTime?> dateTimeModified,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$RecipesTableUpdateCompanionBuilder =
    RecipesCompanion Function({
      Value<String> recipePk,
      Value<String> name,
      Value<String?> description,
      Value<double> defaultYield,
      Value<String> yieldName,
      Value<double> targetProfitMargin,
      Value<double> targetPricePerPortion,
      Value<double> fixedOverheadCost,
      Value<String?> colour,
      Value<DateTime> dateCreated,
      Value<DateTime?> dateTimeModified,
      Value<bool> archived,
      Value<int> rowid,
    });

final class $$RecipesTableReferences
    extends BaseReferences<_$AppDatabase, $RecipesTable, Recipe> {
  $$RecipesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecipeIngredientsTable, List<RecipeIngredient>>
  _recipeIngredientsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recipeIngredients,
        aliasName: $_aliasNameGenerator(
          db.recipes.recipePk,
          db.recipeIngredients.recipeFk,
        ),
      );

  $$RecipeIngredientsTableProcessedTableManager get recipeIngredientsRefs {
    final manager =
        $$RecipeIngredientsTableTableManager(
          $_db,
          $_db.recipeIngredients,
        ).filter(
          (f) =>
              f.recipeFk.recipePk.sqlEquals($_itemColumn<String>('recipe_pk')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _recipeIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecipeStepsTable, List<RecipeStep>>
  _recipeStepsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeSteps,
    aliasName: $_aliasNameGenerator(
      db.recipes.recipePk,
      db.recipeSteps.recipeFk,
    ),
  );

  $$RecipeStepsTableProcessedTableManager get recipeStepsRefs {
    final manager = $$RecipeStepsTableTableManager($_db, $_db.recipeSteps)
        .filter(
          (f) =>
              f.recipeFk.recipePk.sqlEquals($_itemColumn<String>('recipe_pk')!),
        );

    final cache = $_typedResult.readTableOrNull(_recipeStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get recipePk => $composableBuilder(
    column: $table.recipePk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultYield => $composableBuilder(
    column: $table.defaultYield,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yieldName => $composableBuilder(
    column: $table.yieldName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetProfitMargin => $composableBuilder(
    column: $table.targetProfitMargin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetPricePerPortion => $composableBuilder(
    column: $table.targetPricePerPortion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fixedOverheadCost => $composableBuilder(
    column: $table.fixedOverheadCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recipeIngredientsRefs(
    Expression<bool> Function($$RecipeIngredientsTableFilterComposer f) f,
  ) {
    final $$RecipeIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipePk,
      referencedTable: $db.recipeIngredients,
      getReferencedColumn: (t) => t.recipeFk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.recipeIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recipeStepsRefs(
    Expression<bool> Function($$RecipeStepsTableFilterComposer f) f,
  ) {
    final $$RecipeStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipePk,
      referencedTable: $db.recipeSteps,
      getReferencedColumn: (t) => t.recipeFk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeStepsTableFilterComposer(
            $db: $db,
            $table: $db.recipeSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get recipePk => $composableBuilder(
    column: $table.recipePk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultYield => $composableBuilder(
    column: $table.defaultYield,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yieldName => $composableBuilder(
    column: $table.yieldName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetProfitMargin => $composableBuilder(
    column: $table.targetProfitMargin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetPricePerPortion => $composableBuilder(
    column: $table.targetPricePerPortion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fixedOverheadCost => $composableBuilder(
    column: $table.fixedOverheadCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get recipePk =>
      $composableBuilder(column: $table.recipePk, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultYield => $composableBuilder(
    column: $table.defaultYield,
    builder: (column) => column,
  );

  GeneratedColumn<String> get yieldName =>
      $composableBuilder(column: $table.yieldName, builder: (column) => column);

  GeneratedColumn<double> get targetProfitMargin => $composableBuilder(
    column: $table.targetProfitMargin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetPricePerPortion => $composableBuilder(
    column: $table.targetPricePerPortion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fixedOverheadCost => $composableBuilder(
    column: $table.fixedOverheadCost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colour =>
      $composableBuilder(column: $table.colour, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> recipeIngredientsRefs<T extends Object>(
    Expression<T> Function($$RecipeIngredientsTableAnnotationComposer a) f,
  ) {
    final $$RecipeIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recipePk,
          referencedTable: $db.recipeIngredients,
          getReferencedColumn: (t) => t.recipeFk,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecipeIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.recipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recipeStepsRefs<T extends Object>(
    Expression<T> Function($$RecipeStepsTableAnnotationComposer a) f,
  ) {
    final $$RecipeStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipePk,
      referencedTable: $db.recipeSteps,
      getReferencedColumn: (t) => t.recipeFk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          Recipe,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (Recipe, $$RecipesTableReferences),
          Recipe,
          PrefetchHooks Function({
            bool recipeIngredientsRefs,
            bool recipeStepsRefs,
          })
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> recipePk = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> defaultYield = const Value.absent(),
                Value<String> yieldName = const Value.absent(),
                Value<double> targetProfitMargin = const Value.absent(),
                Value<double> targetPricePerPortion = const Value.absent(),
                Value<double> fixedOverheadCost = const Value.absent(),
                Value<String?> colour = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime?> dateTimeModified = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion(
                recipePk: recipePk,
                name: name,
                description: description,
                defaultYield: defaultYield,
                yieldName: yieldName,
                targetProfitMargin: targetProfitMargin,
                targetPricePerPortion: targetPricePerPortion,
                fixedOverheadCost: fixedOverheadCost,
                colour: colour,
                dateCreated: dateCreated,
                dateTimeModified: dateTimeModified,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> recipePk = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                required double defaultYield,
                required String yieldName,
                Value<double> targetProfitMargin = const Value.absent(),
                Value<double> targetPricePerPortion = const Value.absent(),
                Value<double> fixedOverheadCost = const Value.absent(),
                Value<String?> colour = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime?> dateTimeModified = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion.insert(
                recipePk: recipePk,
                name: name,
                description: description,
                defaultYield: defaultYield,
                yieldName: yieldName,
                targetProfitMargin: targetProfitMargin,
                targetPricePerPortion: targetPricePerPortion,
                fixedOverheadCost: fixedOverheadCost,
                colour: colour,
                dateCreated: dateCreated,
                dateTimeModified: dateTimeModified,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({recipeIngredientsRefs = false, recipeStepsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recipeIngredientsRefs) db.recipeIngredients,
                    if (recipeStepsRefs) db.recipeSteps,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recipeIngredientsRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeIngredient
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeFk == item.recipePk,
                              ),
                          typedResults: items,
                        ),
                      if (recipeStepsRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeStep
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeStepsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeStepsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeFk == item.recipePk,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      Recipe,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (Recipe, $$RecipesTableReferences),
      Recipe,
      PrefetchHooks Function({bool recipeIngredientsRefs, bool recipeStepsRefs})
    >;
typedef $$UnitsTableCreateCompanionBuilder =
    UnitsCompanion Function({
      Value<String> unitPk,
      required String name,
      required String symbol,
      Value<String?> category,
      Value<double> factorToBase,
      Value<bool> isMutable,
      Value<int> rowid,
    });
typedef $$UnitsTableUpdateCompanionBuilder =
    UnitsCompanion Function({
      Value<String> unitPk,
      Value<String> name,
      Value<String> symbol,
      Value<String?> category,
      Value<double> factorToBase,
      Value<bool> isMutable,
      Value<int> rowid,
    });

final class $$UnitsTableReferences
    extends BaseReferences<_$AppDatabase, $UnitsTable, Unit> {
  $$UnitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$IngredientsTable, List<Ingredient>>
  _ingredientsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ingredients,
    aliasName: $_aliasNameGenerator(db.units.unitPk, db.ingredients.unitFk),
  );

  $$IngredientsTableProcessedTableManager get ingredientsRefs {
    final manager = $$IngredientsTableTableManager($_db, $_db.ingredients)
        .filter(
          (f) => f.unitFk.unitPk.sqlEquals($_itemColumn<String>('unit_pk')!),
        );

    final cache = $_typedResult.readTableOrNull(_ingredientsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UnitsTableFilterComposer extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get unitPk => $composableBuilder(
    column: $table.unitPk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get factorToBase => $composableBuilder(
    column: $table.factorToBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMutable => $composableBuilder(
    column: $table.isMutable,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ingredientsRefs(
    Expression<bool> Function($$IngredientsTableFilterComposer f) f,
  ) {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitPk,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.unitFk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get unitPk => $composableBuilder(
    column: $table.unitPk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get factorToBase => $composableBuilder(
    column: $table.factorToBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMutable => $composableBuilder(
    column: $table.isMutable,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get unitPk =>
      $composableBuilder(column: $table.unitPk, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get factorToBase => $composableBuilder(
    column: $table.factorToBase,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMutable =>
      $composableBuilder(column: $table.isMutable, builder: (column) => column);

  Expression<T> ingredientsRefs<T extends Object>(
    Expression<T> Function($$IngredientsTableAnnotationComposer a) f,
  ) {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitPk,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.unitFk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitsTable,
          Unit,
          $$UnitsTableFilterComposer,
          $$UnitsTableOrderingComposer,
          $$UnitsTableAnnotationComposer,
          $$UnitsTableCreateCompanionBuilder,
          $$UnitsTableUpdateCompanionBuilder,
          (Unit, $$UnitsTableReferences),
          Unit,
          PrefetchHooks Function({bool ingredientsRefs})
        > {
  $$UnitsTableTableManager(_$AppDatabase db, $UnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> unitPk = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double> factorToBase = const Value.absent(),
                Value<bool> isMutable = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitsCompanion(
                unitPk: unitPk,
                name: name,
                symbol: symbol,
                category: category,
                factorToBase: factorToBase,
                isMutable: isMutable,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> unitPk = const Value.absent(),
                required String name,
                required String symbol,
                Value<String?> category = const Value.absent(),
                Value<double> factorToBase = const Value.absent(),
                Value<bool> isMutable = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitsCompanion.insert(
                unitPk: unitPk,
                name: name,
                symbol: symbol,
                category: category,
                factorToBase: factorToBase,
                isMutable: isMutable,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UnitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({ingredientsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ingredientsRefs) db.ingredients],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ingredientsRefs)
                    await $_getPrefetchedData<Unit, $UnitsTable, Ingredient>(
                      currentTable: table,
                      referencedTable: $$UnitsTableReferences
                          ._ingredientsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UnitsTableReferences(db, table, p0).ingredientsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.unitFk == item.unitPk),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitsTable,
      Unit,
      $$UnitsTableFilterComposer,
      $$UnitsTableOrderingComposer,
      $$UnitsTableAnnotationComposer,
      $$UnitsTableCreateCompanionBuilder,
      $$UnitsTableUpdateCompanionBuilder,
      (Unit, $$UnitsTableReferences),
      Unit,
      PrefetchHooks Function({bool ingredientsRefs})
    >;
typedef $$IngredientsTableCreateCompanionBuilder =
    IngredientsCompanion Function({
      Value<String> ingredientPk,
      required String name,
      required double cost,
      required double quantityForCost,
      required String unitFk,
      Value<DateTime> dateCreated,
      Value<DateTime?> dateTimeModified,
      Value<int> rowid,
    });
typedef $$IngredientsTableUpdateCompanionBuilder =
    IngredientsCompanion Function({
      Value<String> ingredientPk,
      Value<String> name,
      Value<double> cost,
      Value<double> quantityForCost,
      Value<String> unitFk,
      Value<DateTime> dateCreated,
      Value<DateTime?> dateTimeModified,
      Value<int> rowid,
    });

final class $$IngredientsTableReferences
    extends BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient> {
  $$IngredientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UnitsTable _unitFkTable(_$AppDatabase db) => db.units.createAlias(
    $_aliasNameGenerator(db.ingredients.unitFk, db.units.unitPk),
  );

  $$UnitsTableProcessedTableManager get unitFk {
    final $_column = $_itemColumn<String>('unit_fk')!;

    final manager = $$UnitsTableTableManager(
      $_db,
      $_db.units,
    ).filter((f) => f.unitPk.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_unitFkTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RecipeIngredientsTable, List<RecipeIngredient>>
  _recipeIngredientsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recipeIngredients,
        aliasName: $_aliasNameGenerator(
          db.ingredients.ingredientPk,
          db.recipeIngredients.ingredientFk,
        ),
      );

  $$RecipeIngredientsTableProcessedTableManager get recipeIngredientsRefs {
    final manager =
        $$RecipeIngredientsTableTableManager(
          $_db,
          $_db.recipeIngredients,
        ).filter(
          (f) => f.ingredientFk.ingredientPk.sqlEquals(
            $_itemColumn<String>('ingredient_pk')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _recipeIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ingredientPk => $composableBuilder(
    column: $table.ingredientPk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityForCost => $composableBuilder(
    column: $table.quantityForCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => ColumnFilters(column),
  );

  $$UnitsTableFilterComposer get unitFk {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitFk,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.unitPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableFilterComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> recipeIngredientsRefs(
    Expression<bool> Function($$RecipeIngredientsTableFilterComposer f) f,
  ) {
    final $$RecipeIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientPk,
      referencedTable: $db.recipeIngredients,
      getReferencedColumn: (t) => t.ingredientFk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.recipeIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ingredientPk => $composableBuilder(
    column: $table.ingredientPk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityForCost => $composableBuilder(
    column: $table.quantityForCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => ColumnOrderings(column),
  );

  $$UnitsTableOrderingComposer get unitFk {
    final $$UnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitFk,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.unitPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableOrderingComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ingredientPk => $composableBuilder(
    column: $table.ingredientPk,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<double> get quantityForCost => $composableBuilder(
    column: $table.quantityForCost,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => column,
  );

  $$UnitsTableAnnotationComposer get unitFk {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitFk,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.unitPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> recipeIngredientsRefs<T extends Object>(
    Expression<T> Function($$RecipeIngredientsTableAnnotationComposer a) f,
  ) {
    final $$RecipeIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.ingredientPk,
          referencedTable: $db.recipeIngredients,
          getReferencedColumn: (t) => t.ingredientFk,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecipeIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.recipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientsTable,
          Ingredient,
          $$IngredientsTableFilterComposer,
          $$IngredientsTableOrderingComposer,
          $$IngredientsTableAnnotationComposer,
          $$IngredientsTableCreateCompanionBuilder,
          $$IngredientsTableUpdateCompanionBuilder,
          (Ingredient, $$IngredientsTableReferences),
          Ingredient,
          PrefetchHooks Function({bool unitFk, bool recipeIngredientsRefs})
        > {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ingredientPk = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<double> quantityForCost = const Value.absent(),
                Value<String> unitFk = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime?> dateTimeModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCompanion(
                ingredientPk: ingredientPk,
                name: name,
                cost: cost,
                quantityForCost: quantityForCost,
                unitFk: unitFk,
                dateCreated: dateCreated,
                dateTimeModified: dateTimeModified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> ingredientPk = const Value.absent(),
                required String name,
                required double cost,
                required double quantityForCost,
                required String unitFk,
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime?> dateTimeModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCompanion.insert(
                ingredientPk: ingredientPk,
                name: name,
                cost: cost,
                quantityForCost: quantityForCost,
                unitFk: unitFk,
                dateCreated: dateCreated,
                dateTimeModified: dateTimeModified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({unitFk = false, recipeIngredientsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recipeIngredientsRefs) db.recipeIngredients,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (unitFk) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.unitFk,
                                    referencedTable:
                                        $$IngredientsTableReferences
                                            ._unitFkTable(db),
                                    referencedColumn:
                                        $$IngredientsTableReferences
                                            ._unitFkTable(db)
                                            .unitPk,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recipeIngredientsRefs)
                        await $_getPrefetchedData<
                          Ingredient,
                          $IngredientsTable,
                          RecipeIngredient
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._recipeIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientFk == item.ingredientPk,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$IngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientsTable,
      Ingredient,
      $$IngredientsTableFilterComposer,
      $$IngredientsTableOrderingComposer,
      $$IngredientsTableAnnotationComposer,
      $$IngredientsTableCreateCompanionBuilder,
      $$IngredientsTableUpdateCompanionBuilder,
      (Ingredient, $$IngredientsTableReferences),
      Ingredient,
      PrefetchHooks Function({bool unitFk, bool recipeIngredientsRefs})
    >;
typedef $$RecipeIngredientsTableCreateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<String> recipeIngredientPk,
      required String recipeFk,
      required String ingredientFk,
      required double amountNeeded,
      Value<DateTime?> dateTimeModified,
      Value<int> rowid,
    });
typedef $$RecipeIngredientsTableUpdateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<String> recipeIngredientPk,
      Value<String> recipeFk,
      Value<String> ingredientFk,
      Value<double> amountNeeded,
      Value<DateTime?> dateTimeModified,
      Value<int> rowid,
    });

final class $$RecipeIngredientsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient
        > {
  $$RecipeIngredientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecipesTable _recipeFkTable(_$AppDatabase db) =>
      db.recipes.createAlias(
        $_aliasNameGenerator(
          db.recipeIngredients.recipeFk,
          db.recipes.recipePk,
        ),
      );

  $$RecipesTableProcessedTableManager get recipeFk {
    final $_column = $_itemColumn<String>('recipe_fk')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.recipePk.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeFkTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IngredientsTable _ingredientFkTable(_$AppDatabase db) =>
      db.ingredients.createAlias(
        $_aliasNameGenerator(
          db.recipeIngredients.ingredientFk,
          db.ingredients.ingredientPk,
        ),
      );

  $$IngredientsTableProcessedTableManager get ingredientFk {
    final $_column = $_itemColumn<String>('ingredient_fk')!;

    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.ingredientPk.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientFkTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get recipeIngredientPk => $composableBuilder(
    column: $table.recipeIngredientPk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountNeeded => $composableBuilder(
    column: $table.amountNeeded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeFk {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeFk,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.recipePk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableFilterComposer get ingredientFk {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientFk,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get recipeIngredientPk => $composableBuilder(
    column: $table.recipeIngredientPk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountNeeded => $composableBuilder(
    column: $table.amountNeeded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeFk {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeFk,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.recipePk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableOrderingComposer get ingredientFk {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientFk,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get recipeIngredientPk => $composableBuilder(
    column: $table.recipeIngredientPk,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountNeeded => $composableBuilder(
    column: $table.amountNeeded,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => column,
  );

  $$RecipesTableAnnotationComposer get recipeFk {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeFk,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.recipePk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableAnnotationComposer get ingredientFk {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientFk,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient,
          $$RecipeIngredientsTableFilterComposer,
          $$RecipeIngredientsTableOrderingComposer,
          $$RecipeIngredientsTableAnnotationComposer,
          $$RecipeIngredientsTableCreateCompanionBuilder,
          $$RecipeIngredientsTableUpdateCompanionBuilder,
          (RecipeIngredient, $$RecipeIngredientsTableReferences),
          RecipeIngredient,
          PrefetchHooks Function({bool recipeFk, bool ingredientFk})
        > {
  $$RecipeIngredientsTableTableManager(
    _$AppDatabase db,
    $RecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> recipeIngredientPk = const Value.absent(),
                Value<String> recipeFk = const Value.absent(),
                Value<String> ingredientFk = const Value.absent(),
                Value<double> amountNeeded = const Value.absent(),
                Value<DateTime?> dateTimeModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeIngredientsCompanion(
                recipeIngredientPk: recipeIngredientPk,
                recipeFk: recipeFk,
                ingredientFk: ingredientFk,
                amountNeeded: amountNeeded,
                dateTimeModified: dateTimeModified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> recipeIngredientPk = const Value.absent(),
                required String recipeFk,
                required String ingredientFk,
                required double amountNeeded,
                Value<DateTime?> dateTimeModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeIngredientsCompanion.insert(
                recipeIngredientPk: recipeIngredientPk,
                recipeFk: recipeFk,
                ingredientFk: ingredientFk,
                amountNeeded: amountNeeded,
                dateTimeModified: dateTimeModified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeIngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeFk = false, ingredientFk = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (recipeFk) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recipeFk,
                                referencedTable:
                                    $$RecipeIngredientsTableReferences
                                        ._recipeFkTable(db),
                                referencedColumn:
                                    $$RecipeIngredientsTableReferences
                                        ._recipeFkTable(db)
                                        .recipePk,
                              )
                              as T;
                    }
                    if (ingredientFk) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ingredientFk,
                                referencedTable:
                                    $$RecipeIngredientsTableReferences
                                        ._ingredientFkTable(db),
                                referencedColumn:
                                    $$RecipeIngredientsTableReferences
                                        ._ingredientFkTable(db)
                                        .ingredientPk,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeIngredientsTable,
      RecipeIngredient,
      $$RecipeIngredientsTableFilterComposer,
      $$RecipeIngredientsTableOrderingComposer,
      $$RecipeIngredientsTableAnnotationComposer,
      $$RecipeIngredientsTableCreateCompanionBuilder,
      $$RecipeIngredientsTableUpdateCompanionBuilder,
      (RecipeIngredient, $$RecipeIngredientsTableReferences),
      RecipeIngredient,
      PrefetchHooks Function({bool recipeFk, bool ingredientFk})
    >;
typedef $$RecipeStepsTableCreateCompanionBuilder =
    RecipeStepsCompanion Function({
      Value<String> stepPk,
      required String recipeFk,
      required int stepNumber,
      required String instruction,
      Value<DateTime?> dateTimeModified,
      Value<int> rowid,
    });
typedef $$RecipeStepsTableUpdateCompanionBuilder =
    RecipeStepsCompanion Function({
      Value<String> stepPk,
      Value<String> recipeFk,
      Value<int> stepNumber,
      Value<String> instruction,
      Value<DateTime?> dateTimeModified,
      Value<int> rowid,
    });

final class $$RecipeStepsTableReferences
    extends BaseReferences<_$AppDatabase, $RecipeStepsTable, RecipeStep> {
  $$RecipeStepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecipesTable _recipeFkTable(_$AppDatabase db) =>
      db.recipes.createAlias(
        $_aliasNameGenerator(db.recipeSteps.recipeFk, db.recipes.recipePk),
      );

  $$RecipesTableProcessedTableManager get recipeFk {
    final $_column = $_itemColumn<String>('recipe_fk')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.recipePk.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeFkTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeStepsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeStepsTable> {
  $$RecipeStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stepPk => $composableBuilder(
    column: $table.stepPk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeFk {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeFk,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.recipePk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeStepsTable> {
  $$RecipeStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stepPk => $composableBuilder(
    column: $table.stepPk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeFk {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeFk,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.recipePk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeStepsTable> {
  $$RecipeStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stepPk =>
      $composableBuilder(column: $table.stepPk, builder: (column) => column);

  GeneratedColumn<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateTimeModified => $composableBuilder(
    column: $table.dateTimeModified,
    builder: (column) => column,
  );

  $$RecipesTableAnnotationComposer get recipeFk {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeFk,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.recipePk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeStepsTable,
          RecipeStep,
          $$RecipeStepsTableFilterComposer,
          $$RecipeStepsTableOrderingComposer,
          $$RecipeStepsTableAnnotationComposer,
          $$RecipeStepsTableCreateCompanionBuilder,
          $$RecipeStepsTableUpdateCompanionBuilder,
          (RecipeStep, $$RecipeStepsTableReferences),
          RecipeStep,
          PrefetchHooks Function({bool recipeFk})
        > {
  $$RecipeStepsTableTableManager(_$AppDatabase db, $RecipeStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> stepPk = const Value.absent(),
                Value<String> recipeFk = const Value.absent(),
                Value<int> stepNumber = const Value.absent(),
                Value<String> instruction = const Value.absent(),
                Value<DateTime?> dateTimeModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeStepsCompanion(
                stepPk: stepPk,
                recipeFk: recipeFk,
                stepNumber: stepNumber,
                instruction: instruction,
                dateTimeModified: dateTimeModified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> stepPk = const Value.absent(),
                required String recipeFk,
                required int stepNumber,
                required String instruction,
                Value<DateTime?> dateTimeModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeStepsCompanion.insert(
                stepPk: stepPk,
                recipeFk: recipeFk,
                stepNumber: stepNumber,
                instruction: instruction,
                dateTimeModified: dateTimeModified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeFk = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (recipeFk) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recipeFk,
                                referencedTable: $$RecipeStepsTableReferences
                                    ._recipeFkTable(db),
                                referencedColumn: $$RecipeStepsTableReferences
                                    ._recipeFkTable(db)
                                    .recipePk,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecipeStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeStepsTable,
      RecipeStep,
      $$RecipeStepsTableFilterComposer,
      $$RecipeStepsTableOrderingComposer,
      $$RecipeStepsTableAnnotationComposer,
      $$RecipeStepsTableCreateCompanionBuilder,
      $$RecipeStepsTableUpdateCompanionBuilder,
      (RecipeStep, $$RecipeStepsTableReferences),
      RecipeStep,
      PrefetchHooks Function({bool recipeFk})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db, _db.units);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$RecipeStepsTableTableManager get recipeSteps =>
      $$RecipeStepsTableTableManager(_db, _db.recipeSteps);
}
