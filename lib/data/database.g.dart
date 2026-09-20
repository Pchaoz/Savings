// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CategoryKindDb, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CategoryKindDb>($CategoriesTable.$converterkind);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('receipt'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    id,
    name,
    kind,
    icon,
    color,
    sortOrder,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $CategoriesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CategoryKindDb, String, String> $converterkind =
      const EnumNameConverter<CategoryKindDb>(CategoryKindDb.values);
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;
  final String name;

  /// El campo que decide en que cubo entra el dinero.
  final CategoryKindDb kind;
  final String icon;
  final int? color;
  final int sortOrder;

  /// Ocultar sin perder el historico. El dia que te mudes,
  /// "Alquiler" sigue ahi esperando.
  final bool archived;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.kind,
    required this.icon,
    this.color,
    required this.sortOrder,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>(
        $CategoriesTable.$converterkind.toSql(kind),
      );
    }
    map['icon'] = Variable<String>(icon);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      icon: Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      sortOrder: Value(sortOrder),
      archived: Value(archived),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $CategoriesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int?>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(
        $CategoriesTable.$converterkind.toJson(kind),
      ),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int?>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  CategoryRow copyWith({
    int? id,
    String? name,
    CategoryKindDb? kind,
    String? icon,
    Value<int?> color = const Value.absent(),
    int? sortOrder,
    bool? archived,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    icon: icon ?? this.icon,
    color: color.present ? color.value : this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    archived: archived ?? this.archived,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, kind, icon, color, sortOrder, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.archived == this.archived);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<CategoryKindDb> kind;
  final Value<String> icon;
  final Value<int?> color;
  final Value<int> sortOrder;
  final Value<bool> archived;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required CategoryKindDb kind,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<int>? sortOrder,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (archived != null) 'archived': archived,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<CategoryKindDb>? kind,
    Value<String>? icon,
    Value<int?>? color,
    Value<int>? sortOrder,
    Value<bool>? archived,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      archived: archived ?? this.archived,
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
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CategoriesTable.$converterkind.toSql(kind.value),
      );
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refundOfIdMeta = const VerificationMeta(
    'refundOfId',
  );
  @override
  late final GeneratedColumn<int> refundOfId = GeneratedColumn<int>(
    'refund_of_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deleteReasonMeta = const VerificationMeta(
    'deleteReason',
  );
  @override
  late final GeneratedColumn<String> deleteReason = GeneratedColumn<String>(
    'delete_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurringTemplateIdMeta =
      const VerificationMeta('recurringTemplateId');
  @override
  late final GeneratedColumn<int> recurringTemplateId = GeneratedColumn<int>(
    'recurring_template_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidFromPocketIdMeta = const VerificationMeta(
    'paidFromPocketId',
  );
  @override
  late final GeneratedColumn<int> paidFromPocketId = GeneratedColumn<int>(
    'paid_from_pocket_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    amountCents,
    categoryId,
    note,
    refundOfId,
    deletedAt,
    deleteReason,
    recurringTemplateId,
    paidFromPocketId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('refund_of_id')) {
      context.handle(
        _refundOfIdMeta,
        refundOfId.isAcceptableOrUnknown(
          data['refund_of_id']!,
          _refundOfIdMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('delete_reason')) {
      context.handle(
        _deleteReasonMeta,
        deleteReason.isAcceptableOrUnknown(
          data['delete_reason']!,
          _deleteReasonMeta,
        ),
      );
    }
    if (data.containsKey('recurring_template_id')) {
      context.handle(
        _recurringTemplateIdMeta,
        recurringTemplateId.isAcceptableOrUnknown(
          data['recurring_template_id']!,
          _recurringTemplateIdMeta,
        ),
      );
    }
    if (data.containsKey('paid_from_pocket_id')) {
      context.handle(
        _paidFromPocketIdMeta,
        paidFromPocketId.isAcceptableOrUnknown(
          data['paid_from_pocket_id']!,
          _paidFromPocketIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      refundOfId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refund_of_id'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deleteReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delete_reason'],
      ),
      recurringTemplateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_template_id'],
      ),
      paidFromPocketId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_from_pocket_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final int id;

  /// Determina a que mes pertenece el movimiento.
  final DateTime date;

  /// Normalmente positivo. **Negativo = devolucion** (doc 08).
  final int amountCents;
  final int categoryId;

  /// "Monster", "Xiaomi Band 8 Pro". En caprichos es lo importante.
  final String? note;

  /// Apunta al movimiento devuelto. Permite enlazar las dos filas en la
  /// lista y saltar de una a otra, incluso entre meses distintos.
  final int? refundOfId;

  /// Borrado suave. Los calculos filtran siempre por `deletedAt IS NULL`.
  /// Se purga de verdad a los 30 dias.
  final DateTime? deletedAt;

  /// `mistake` / `duplicate` / `other`. Solo se rellena al borrar.
  /// Las devoluciones NO se borran: generan un movimiento nuevo.
  final String? deleteReason;

  /// Si este movimiento lo genero un automatismo (doc 04: "la nomina y
  /// las suscripciones se meten solas"), el id de la plantilla que lo
  /// genero. A proposito NO es una `.references()`: si el usuario borra
  /// la plantilla mas adelante, los movimientos ya generados deben
  /// quedarse tal cual, como historico, sin que una FK lo impida.
  final int? recurringTemplateId;

  /// Si este gasto se pago con dinero ya apartado en una hucha (en vez de
  /// la "cuenta principal"), el id de esa hucha. A proposito NO es una
  /// `.references()`, mismo motivo que `recurringTemplateId` de arriba: si
  /// se borra la hucha mas adelante, el historico de este gasto debe
  /// quedarse tal cual. Cuando esta puesto, `monthResult` IGNORA este
  /// movimiento del todo (no cuenta como ingreso/fijo/variable/capricho de
  /// este mes) — el dinero ya habia salido de tu ahorro general el dia
  /// que lo metiste en la hucha, asi que gastarlo ahora no debe volver a
  /// restar de este mes.
  final int? paidFromPocketId;
  final DateTime createdAt;
  const TransactionRow({
    required this.id,
    required this.date,
    required this.amountCents,
    required this.categoryId,
    this.note,
    this.refundOfId,
    this.deletedAt,
    this.deleteReason,
    this.recurringTemplateId,
    this.paidFromPocketId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['amount_cents'] = Variable<int>(amountCents);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || refundOfId != null) {
      map['refund_of_id'] = Variable<int>(refundOfId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deleteReason != null) {
      map['delete_reason'] = Variable<String>(deleteReason);
    }
    if (!nullToAbsent || recurringTemplateId != null) {
      map['recurring_template_id'] = Variable<int>(recurringTemplateId);
    }
    if (!nullToAbsent || paidFromPocketId != null) {
      map['paid_from_pocket_id'] = Variable<int>(paidFromPocketId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      date: Value(date),
      amountCents: Value(amountCents),
      categoryId: Value(categoryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      refundOfId: refundOfId == null && nullToAbsent
          ? const Value.absent()
          : Value(refundOfId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deleteReason: deleteReason == null && nullToAbsent
          ? const Value.absent()
          : Value(deleteReason),
      recurringTemplateId: recurringTemplateId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringTemplateId),
      paidFromPocketId: paidFromPocketId == null && nullToAbsent
          ? const Value.absent()
          : Value(paidFromPocketId),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      note: serializer.fromJson<String?>(json['note']),
      refundOfId: serializer.fromJson<int?>(json['refundOfId']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deleteReason: serializer.fromJson<String?>(json['deleteReason']),
      recurringTemplateId: serializer.fromJson<int?>(
        json['recurringTemplateId'],
      ),
      paidFromPocketId: serializer.fromJson<int?>(json['paidFromPocketId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'amountCents': serializer.toJson<int>(amountCents),
      'categoryId': serializer.toJson<int>(categoryId),
      'note': serializer.toJson<String?>(note),
      'refundOfId': serializer.toJson<int?>(refundOfId),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deleteReason': serializer.toJson<String?>(deleteReason),
      'recurringTemplateId': serializer.toJson<int?>(recurringTemplateId),
      'paidFromPocketId': serializer.toJson<int?>(paidFromPocketId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionRow copyWith({
    int? id,
    DateTime? date,
    int? amountCents,
    int? categoryId,
    Value<String?> note = const Value.absent(),
    Value<int?> refundOfId = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deleteReason = const Value.absent(),
    Value<int?> recurringTemplateId = const Value.absent(),
    Value<int?> paidFromPocketId = const Value.absent(),
    DateTime? createdAt,
  }) => TransactionRow(
    id: id ?? this.id,
    date: date ?? this.date,
    amountCents: amountCents ?? this.amountCents,
    categoryId: categoryId ?? this.categoryId,
    note: note.present ? note.value : this.note,
    refundOfId: refundOfId.present ? refundOfId.value : this.refundOfId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deleteReason: deleteReason.present ? deleteReason.value : this.deleteReason,
    recurringTemplateId: recurringTemplateId.present
        ? recurringTemplateId.value
        : this.recurringTemplateId,
    paidFromPocketId: paidFromPocketId.present
        ? paidFromPocketId.value
        : this.paidFromPocketId,
    createdAt: createdAt ?? this.createdAt,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      refundOfId: data.refundOfId.present
          ? data.refundOfId.value
          : this.refundOfId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deleteReason: data.deleteReason.present
          ? data.deleteReason.value
          : this.deleteReason,
      recurringTemplateId: data.recurringTemplateId.present
          ? data.recurringTemplateId.value
          : this.recurringTemplateId,
      paidFromPocketId: data.paidFromPocketId.present
          ? data.paidFromPocketId.value
          : this.paidFromPocketId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amountCents: $amountCents, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('refundOfId: $refundOfId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deleteReason: $deleteReason, ')
          ..write('recurringTemplateId: $recurringTemplateId, ')
          ..write('paidFromPocketId: $paidFromPocketId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    amountCents,
    categoryId,
    note,
    refundOfId,
    deletedAt,
    deleteReason,
    recurringTemplateId,
    paidFromPocketId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.amountCents == this.amountCents &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.refundOfId == this.refundOfId &&
          other.deletedAt == this.deletedAt &&
          other.deleteReason == this.deleteReason &&
          other.recurringTemplateId == this.recurringTemplateId &&
          other.paidFromPocketId == this.paidFromPocketId &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> amountCents;
  final Value<int> categoryId;
  final Value<String?> note;
  final Value<int?> refundOfId;
  final Value<DateTime?> deletedAt;
  final Value<String?> deleteReason;
  final Value<int?> recurringTemplateId;
  final Value<int?> paidFromPocketId;
  final Value<DateTime> createdAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.refundOfId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deleteReason = const Value.absent(),
    this.recurringTemplateId = const Value.absent(),
    this.paidFromPocketId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int amountCents,
    required int categoryId,
    this.note = const Value.absent(),
    this.refundOfId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deleteReason = const Value.absent(),
    this.recurringTemplateId = const Value.absent(),
    this.paidFromPocketId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : date = Value(date),
       amountCents = Value(amountCents),
       categoryId = Value(categoryId);
  static Insertable<TransactionRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? amountCents,
    Expression<int>? categoryId,
    Expression<String>? note,
    Expression<int>? refundOfId,
    Expression<DateTime>? deletedAt,
    Expression<String>? deleteReason,
    Expression<int>? recurringTemplateId,
    Expression<int>? paidFromPocketId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (amountCents != null) 'amount_cents': amountCents,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (refundOfId != null) 'refund_of_id': refundOfId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deleteReason != null) 'delete_reason': deleteReason,
      if (recurringTemplateId != null)
        'recurring_template_id': recurringTemplateId,
      if (paidFromPocketId != null) 'paid_from_pocket_id': paidFromPocketId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? amountCents,
    Value<int>? categoryId,
    Value<String?>? note,
    Value<int?>? refundOfId,
    Value<DateTime?>? deletedAt,
    Value<String?>? deleteReason,
    Value<int?>? recurringTemplateId,
    Value<int?>? paidFromPocketId,
    Value<DateTime>? createdAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      amountCents: amountCents ?? this.amountCents,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      refundOfId: refundOfId ?? this.refundOfId,
      deletedAt: deletedAt ?? this.deletedAt,
      deleteReason: deleteReason ?? this.deleteReason,
      recurringTemplateId: recurringTemplateId ?? this.recurringTemplateId,
      paidFromPocketId: paidFromPocketId ?? this.paidFromPocketId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (refundOfId.present) {
      map['refund_of_id'] = Variable<int>(refundOfId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deleteReason.present) {
      map['delete_reason'] = Variable<String>(deleteReason.value);
    }
    if (recurringTemplateId.present) {
      map['recurring_template_id'] = Variable<int>(recurringTemplateId.value);
    }
    if (paidFromPocketId.present) {
      map['paid_from_pocket_id'] = Variable<int>(paidFromPocketId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amountCents: $amountCents, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('refundOfId: $refundOfId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deleteReason: $deleteReason, ')
          ..write('recurringTemplateId: $recurringTemplateId, ')
          ..write('paidFromPocketId: $paidFromPocketId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecurringTemplatesTable extends RecurringTemplates
    with TableInfo<$RecurringTemplatesTable, RecurringRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _everyNMonthsMeta = const VerificationMeta(
    'everyNMonths',
  );
  @override
  late final GeneratedColumn<int> everyNMonths = GeneratedColumn<int>(
    'every_n_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _anchorYearMonthMeta = const VerificationMeta(
    'anchorYearMonth',
  );
  @override
  late final GeneratedColumn<String> anchorYearMonth = GeneratedColumn<String>(
    'anchor_year_month',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    amountCents,
    dayOfMonth,
    everyNMonths,
    anchorYearMonth,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayOfMonthMeta);
    }
    if (data.containsKey('every_n_months')) {
      context.handle(
        _everyNMonthsMeta,
        everyNMonths.isAcceptableOrUnknown(
          data['every_n_months']!,
          _everyNMonthsMeta,
        ),
      );
    }
    if (data.containsKey('anchor_year_month')) {
      context.handle(
        _anchorYearMonthMeta,
        anchorYearMonth.isAcceptableOrUnknown(
          data['anchor_year_month']!,
          _anchorYearMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anchorYearMonthMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      )!,
      everyNMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}every_n_months'],
      )!,
      anchorYearMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor_year_month'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $RecurringTemplatesTable createAlias(String alias) {
    return $RecurringTemplatesTable(attachedDatabase, alias);
  }
}

class RecurringRow extends DataClass implements Insertable<RecurringRow> {
  final int id;
  final int categoryId;
  final String name;
  final int amountCents;

  /// 1-28, para no pelearse con febrero ni con los meses de 30 dias.
  final int dayOfMonth;

  /// 1 = mensual. **3 = el T-Jove.**
  final int everyNMonths;

  /// "2026-08". Desde que mes cuenta el ciclo de [everyNMonths].
  final String anchorYearMonth;
  final bool active;
  const RecurringRow({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.amountCents,
    required this.dayOfMonth,
    required this.everyNMonths,
    required this.anchorYearMonth,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['name'] = Variable<String>(name);
    map['amount_cents'] = Variable<int>(amountCents);
    map['day_of_month'] = Variable<int>(dayOfMonth);
    map['every_n_months'] = Variable<int>(everyNMonths);
    map['anchor_year_month'] = Variable<String>(anchorYearMonth);
    map['active'] = Variable<bool>(active);
    return map;
  }

  RecurringTemplatesCompanion toCompanion(bool nullToAbsent) {
    return RecurringTemplatesCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      amountCents: Value(amountCents),
      dayOfMonth: Value(dayOfMonth),
      everyNMonths: Value(everyNMonths),
      anchorYearMonth: Value(anchorYearMonth),
      active: Value(active),
    );
  }

  factory RecurringRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRow(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      everyNMonths: serializer.fromJson<int>(json['everyNMonths']),
      anchorYearMonth: serializer.fromJson<String>(json['anchorYearMonth']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'name': serializer.toJson<String>(name),
      'amountCents': serializer.toJson<int>(amountCents),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'everyNMonths': serializer.toJson<int>(everyNMonths),
      'anchorYearMonth': serializer.toJson<String>(anchorYearMonth),
      'active': serializer.toJson<bool>(active),
    };
  }

  RecurringRow copyWith({
    int? id,
    int? categoryId,
    String? name,
    int? amountCents,
    int? dayOfMonth,
    int? everyNMonths,
    String? anchorYearMonth,
    bool? active,
  }) => RecurringRow(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    amountCents: amountCents ?? this.amountCents,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    everyNMonths: everyNMonths ?? this.everyNMonths,
    anchorYearMonth: anchorYearMonth ?? this.anchorYearMonth,
    active: active ?? this.active,
  );
  RecurringRow copyWithCompanion(RecurringTemplatesCompanion data) {
    return RecurringRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      everyNMonths: data.everyNMonths.present
          ? data.everyNMonths.value
          : this.everyNMonths,
      anchorYearMonth: data.anchorYearMonth.present
          ? data.anchorYearMonth.value
          : this.anchorYearMonth,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('amountCents: $amountCents, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('everyNMonths: $everyNMonths, ')
          ..write('anchorYearMonth: $anchorYearMonth, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    name,
    amountCents,
    dayOfMonth,
    everyNMonths,
    anchorYearMonth,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.amountCents == this.amountCents &&
          other.dayOfMonth == this.dayOfMonth &&
          other.everyNMonths == this.everyNMonths &&
          other.anchorYearMonth == this.anchorYearMonth &&
          other.active == this.active);
}

class RecurringTemplatesCompanion extends UpdateCompanion<RecurringRow> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> name;
  final Value<int> amountCents;
  final Value<int> dayOfMonth;
  final Value<int> everyNMonths;
  final Value<String> anchorYearMonth;
  final Value<bool> active;
  const RecurringTemplatesCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.everyNMonths = const Value.absent(),
    this.anchorYearMonth = const Value.absent(),
    this.active = const Value.absent(),
  });
  RecurringTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String name,
    required int amountCents,
    required int dayOfMonth,
    this.everyNMonths = const Value.absent(),
    required String anchorYearMonth,
    this.active = const Value.absent(),
  }) : categoryId = Value(categoryId),
       name = Value(name),
       amountCents = Value(amountCents),
       dayOfMonth = Value(dayOfMonth),
       anchorYearMonth = Value(anchorYearMonth);
  static Insertable<RecurringRow> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? name,
    Expression<int>? amountCents,
    Expression<int>? dayOfMonth,
    Expression<int>? everyNMonths,
    Expression<String>? anchorYearMonth,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (amountCents != null) 'amount_cents': amountCents,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (everyNMonths != null) 'every_n_months': everyNMonths,
      if (anchorYearMonth != null) 'anchor_year_month': anchorYearMonth,
      if (active != null) 'active': active,
    });
  }

  RecurringTemplatesCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<String>? name,
    Value<int>? amountCents,
    Value<int>? dayOfMonth,
    Value<int>? everyNMonths,
    Value<String>? anchorYearMonth,
    Value<bool>? active,
  }) {
    return RecurringTemplatesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      amountCents: amountCents ?? this.amountCents,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      everyNMonths: everyNMonths ?? this.everyNMonths,
      anchorYearMonth: anchorYearMonth ?? this.anchorYearMonth,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (everyNMonths.present) {
      map['every_n_months'] = Variable<int>(everyNMonths.value);
    }
    if (anchorYearMonth.present) {
      map['anchor_year_month'] = Variable<String>(anchorYearMonth.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('amountCents: $amountCents, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('everyNMonths: $everyNMonths, ')
          ..write('anchorYearMonth: $anchorYearMonth, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $MonthsTable extends Months with TableInfo<$MonthsTable, MonthRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _yearMonthMeta = const VerificationMeta(
    'yearMonth',
  );
  @override
  late final GeneratedColumn<String> yearMonth = GeneratedColumn<String>(
    'year_month',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _treatRateMeta = const VerificationMeta(
    'treatRate',
  );
  @override
  late final GeneratedColumn<double> treatRate = GeneratedColumn<double>(
    'treat_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingBalanceCentsMeta =
      const VerificationMeta('openingBalanceCents');
  @override
  late final GeneratedColumn<int> openingBalanceCents = GeneratedColumn<int>(
    'opening_balance_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    yearMonth,
    treatRate,
    openingBalanceCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'months';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('year_month')) {
      context.handle(
        _yearMonthMeta,
        yearMonth.isAcceptableOrUnknown(data['year_month']!, _yearMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMonthMeta);
    }
    if (data.containsKey('treat_rate')) {
      context.handle(
        _treatRateMeta,
        treatRate.isAcceptableOrUnknown(data['treat_rate']!, _treatRateMeta),
      );
    }
    if (data.containsKey('opening_balance_cents')) {
      context.handle(
        _openingBalanceCentsMeta,
        openingBalanceCents.isAcceptableOrUnknown(
          data['opening_balance_cents']!,
          _openingBalanceCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {yearMonth};
  @override
  MonthRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthRow(
      yearMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year_month'],
      )!,
      treatRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}treat_rate'],
      ),
      openingBalanceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_cents'],
      ),
    );
  }

  @override
  $MonthsTable createAlias(String alias) {
    return $MonthsTable(attachedDatabase, alias);
  }
}

class MonthRow extends DataClass implements Insertable<MonthRow> {
  /// "2026-08"
  final String yearMonth;

  /// Por defecto el global (10 %). Se puede sobrescribir un mes concreto.
  final double? treatRate;

  /// La semilla. **Solo el primer mes lo tiene**: 556082 (5.560,82 €).
  /// El resto de meses lo heredan calculado en cascada.
  final int? openingBalanceCents;
  const MonthRow({
    required this.yearMonth,
    this.treatRate,
    this.openingBalanceCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['year_month'] = Variable<String>(yearMonth);
    if (!nullToAbsent || treatRate != null) {
      map['treat_rate'] = Variable<double>(treatRate);
    }
    if (!nullToAbsent || openingBalanceCents != null) {
      map['opening_balance_cents'] = Variable<int>(openingBalanceCents);
    }
    return map;
  }

  MonthsCompanion toCompanion(bool nullToAbsent) {
    return MonthsCompanion(
      yearMonth: Value(yearMonth),
      treatRate: treatRate == null && nullToAbsent
          ? const Value.absent()
          : Value(treatRate),
      openingBalanceCents: openingBalanceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(openingBalanceCents),
    );
  }

  factory MonthRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthRow(
      yearMonth: serializer.fromJson<String>(json['yearMonth']),
      treatRate: serializer.fromJson<double?>(json['treatRate']),
      openingBalanceCents: serializer.fromJson<int?>(
        json['openingBalanceCents'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'yearMonth': serializer.toJson<String>(yearMonth),
      'treatRate': serializer.toJson<double?>(treatRate),
      'openingBalanceCents': serializer.toJson<int?>(openingBalanceCents),
    };
  }

  MonthRow copyWith({
    String? yearMonth,
    Value<double?> treatRate = const Value.absent(),
    Value<int?> openingBalanceCents = const Value.absent(),
  }) => MonthRow(
    yearMonth: yearMonth ?? this.yearMonth,
    treatRate: treatRate.present ? treatRate.value : this.treatRate,
    openingBalanceCents: openingBalanceCents.present
        ? openingBalanceCents.value
        : this.openingBalanceCents,
  );
  MonthRow copyWithCompanion(MonthsCompanion data) {
    return MonthRow(
      yearMonth: data.yearMonth.present ? data.yearMonth.value : this.yearMonth,
      treatRate: data.treatRate.present ? data.treatRate.value : this.treatRate,
      openingBalanceCents: data.openingBalanceCents.present
          ? data.openingBalanceCents.value
          : this.openingBalanceCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthRow(')
          ..write('yearMonth: $yearMonth, ')
          ..write('treatRate: $treatRate, ')
          ..write('openingBalanceCents: $openingBalanceCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(yearMonth, treatRate, openingBalanceCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthRow &&
          other.yearMonth == this.yearMonth &&
          other.treatRate == this.treatRate &&
          other.openingBalanceCents == this.openingBalanceCents);
}

class MonthsCompanion extends UpdateCompanion<MonthRow> {
  final Value<String> yearMonth;
  final Value<double?> treatRate;
  final Value<int?> openingBalanceCents;
  final Value<int> rowid;
  const MonthsCompanion({
    this.yearMonth = const Value.absent(),
    this.treatRate = const Value.absent(),
    this.openingBalanceCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthsCompanion.insert({
    required String yearMonth,
    this.treatRate = const Value.absent(),
    this.openingBalanceCents = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : yearMonth = Value(yearMonth);
  static Insertable<MonthRow> custom({
    Expression<String>? yearMonth,
    Expression<double>? treatRate,
    Expression<int>? openingBalanceCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (yearMonth != null) 'year_month': yearMonth,
      if (treatRate != null) 'treat_rate': treatRate,
      if (openingBalanceCents != null)
        'opening_balance_cents': openingBalanceCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthsCompanion copyWith({
    Value<String>? yearMonth,
    Value<double?>? treatRate,
    Value<int?>? openingBalanceCents,
    Value<int>? rowid,
  }) {
    return MonthsCompanion(
      yearMonth: yearMonth ?? this.yearMonth,
      treatRate: treatRate ?? this.treatRate,
      openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (yearMonth.present) {
      map['year_month'] = Variable<String>(yearMonth.value);
    }
    if (treatRate.present) {
      map['treat_rate'] = Variable<double>(treatRate.value);
    }
    if (openingBalanceCents.present) {
      map['opening_balance_cents'] = Variable<int>(openingBalanceCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthsCompanion(')
          ..write('yearMonth: $yearMonth, ')
          ..write('treatRate: $treatRate, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuickActionsTable extends QuickActions
    with TableInfo<$QuickActionsTable, QuickActionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuickActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    amountCents,
    categoryId,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quick_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuickActionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuickActionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuickActionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $QuickActionsTable createAlias(String alias) {
    return $QuickActionsTable(attachedDatabase, alias);
  }
}

class QuickActionRow extends DataClass implements Insertable<QuickActionRow> {
  final int id;

  /// "Monster"
  final String label;

  /// 180
  final int amountCents;
  final int categoryId;
  final int sortOrder;
  const QuickActionRow({
    required this.id,
    required this.label,
    required this.amountCents,
    required this.categoryId,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['amount_cents'] = Variable<int>(amountCents);
    map['category_id'] = Variable<int>(categoryId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  QuickActionsCompanion toCompanion(bool nullToAbsent) {
    return QuickActionsCompanion(
      id: Value(id),
      label: Value(label),
      amountCents: Value(amountCents),
      categoryId: Value(categoryId),
      sortOrder: Value(sortOrder),
    );
  }

  factory QuickActionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuickActionRow(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'amountCents': serializer.toJson<int>(amountCents),
      'categoryId': serializer.toJson<int>(categoryId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  QuickActionRow copyWith({
    int? id,
    String? label,
    int? amountCents,
    int? categoryId,
    int? sortOrder,
  }) => QuickActionRow(
    id: id ?? this.id,
    label: label ?? this.label,
    amountCents: amountCents ?? this.amountCents,
    categoryId: categoryId ?? this.categoryId,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  QuickActionRow copyWithCompanion(QuickActionsCompanion data) {
    return QuickActionRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuickActionRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('amountCents: $amountCents, ')
          ..write('categoryId: $categoryId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, label, amountCents, categoryId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuickActionRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.amountCents == this.amountCents &&
          other.categoryId == this.categoryId &&
          other.sortOrder == this.sortOrder);
}

class QuickActionsCompanion extends UpdateCompanion<QuickActionRow> {
  final Value<int> id;
  final Value<String> label;
  final Value<int> amountCents;
  final Value<int> categoryId;
  final Value<int> sortOrder;
  const QuickActionsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  QuickActionsCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required int amountCents,
    required int categoryId,
    this.sortOrder = const Value.absent(),
  }) : label = Value(label),
       amountCents = Value(amountCents),
       categoryId = Value(categoryId);
  static Insertable<QuickActionRow> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<int>? amountCents,
    Expression<int>? categoryId,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (amountCents != null) 'amount_cents': amountCents,
      if (categoryId != null) 'category_id': categoryId,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  QuickActionsCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<int>? amountCents,
    Value<int>? categoryId,
    Value<int>? sortOrder,
  }) {
    return QuickActionsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      amountCents: amountCents ?? this.amountCents,
      categoryId: categoryId ?? this.categoryId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuickActionsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('amountCents: $amountCents, ')
          ..write('categoryId: $categoryId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $SavingsPocketsTable extends SavingsPockets
    with TableInfo<$SavingsPocketsTable, PocketRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsPocketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCentsMeta = const VerificationMeta(
    'targetCents',
  );
  @override
  late final GeneratedColumn<int> targetCents = GeneratedColumn<int>(
    'target_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    id,
    name,
    targetCents,
    sortOrder,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_pockets';
  @override
  VerificationContext validateIntegrity(
    Insertable<PocketRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_cents')) {
      context.handle(
        _targetCentsMeta,
        targetCents.isAcceptableOrUnknown(
          data['target_cents']!,
          _targetCentsMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PocketRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PocketRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_cents'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $SavingsPocketsTable createAlias(String alias) {
    return $SavingsPocketsTable(attachedDatabase, alias);
  }
}

class PocketRow extends DataClass implements Insertable<PocketRow> {
  final int id;
  final String name;

  /// Meta opcional. Si esta puesta, la pantalla muestra una barra de
  /// progreso y un aviso al llegar al 100 % — nada mas pasa solo, la
  /// hucha sigue funcionando igual despues de cumplirla.
  final int? targetCents;
  final int sortOrder;
  final bool archived;
  const PocketRow({
    required this.id,
    required this.name,
    this.targetCents,
    required this.sortOrder,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || targetCents != null) {
      map['target_cents'] = Variable<int>(targetCents);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  SavingsPocketsCompanion toCompanion(bool nullToAbsent) {
    return SavingsPocketsCompanion(
      id: Value(id),
      name: Value(name),
      targetCents: targetCents == null && nullToAbsent
          ? const Value.absent()
          : Value(targetCents),
      sortOrder: Value(sortOrder),
      archived: Value(archived),
    );
  }

  factory PocketRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PocketRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetCents: serializer.fromJson<int?>(json['targetCents']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'targetCents': serializer.toJson<int?>(targetCents),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  PocketRow copyWith({
    int? id,
    String? name,
    Value<int?> targetCents = const Value.absent(),
    int? sortOrder,
    bool? archived,
  }) => PocketRow(
    id: id ?? this.id,
    name: name ?? this.name,
    targetCents: targetCents.present ? targetCents.value : this.targetCents,
    sortOrder: sortOrder ?? this.sortOrder,
    archived: archived ?? this.archived,
  );
  PocketRow copyWithCompanion(SavingsPocketsCompanion data) {
    return PocketRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetCents: data.targetCents.present
          ? data.targetCents.value
          : this.targetCents,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PocketRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetCents: $targetCents, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, targetCents, sortOrder, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PocketRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetCents == this.targetCents &&
          other.sortOrder == this.sortOrder &&
          other.archived == this.archived);
}

class SavingsPocketsCompanion extends UpdateCompanion<PocketRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> targetCents;
  final Value<int> sortOrder;
  final Value<bool> archived;
  const SavingsPocketsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetCents = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
  });
  SavingsPocketsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.targetCents = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PocketRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? targetCents,
    Expression<int>? sortOrder,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetCents != null) 'target_cents': targetCents,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (archived != null) 'archived': archived,
    });
  }

  SavingsPocketsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? targetCents,
    Value<int>? sortOrder,
    Value<bool>? archived,
  }) {
    return SavingsPocketsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetCents: targetCents ?? this.targetCents,
      sortOrder: sortOrder ?? this.sortOrder,
      archived: archived ?? this.archived,
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
    if (targetCents.present) {
      map['target_cents'] = Variable<int>(targetCents.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsPocketsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetCents: $targetCents, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $PocketMovementsTable extends PocketMovements
    with TableInfo<$PocketMovementsTable, PocketMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PocketMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pocketIdMeta = const VerificationMeta(
    'pocketId',
  );
  @override
  late final GeneratedColumn<int> pocketId = GeneratedColumn<int>(
    'pocket_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES savings_pockets (id)',
    ),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurringPocketTemplateIdMeta =
      const VerificationMeta('recurringPocketTemplateId');
  @override
  late final GeneratedColumn<int> recurringPocketTemplateId =
      GeneratedColumn<int>(
        'recurring_pocket_template_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _relatedTransactionIdMeta =
      const VerificationMeta('relatedTransactionId');
  @override
  late final GeneratedColumn<int> relatedTransactionId = GeneratedColumn<int>(
    'related_transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pocketId,
    amountCents,
    date,
    note,
    recurringPocketTemplateId,
    relatedTransactionId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pocket_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<PocketMovementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pocket_id')) {
      context.handle(
        _pocketIdMeta,
        pocketId.isAcceptableOrUnknown(data['pocket_id']!, _pocketIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pocketIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('recurring_pocket_template_id')) {
      context.handle(
        _recurringPocketTemplateIdMeta,
        recurringPocketTemplateId.isAcceptableOrUnknown(
          data['recurring_pocket_template_id']!,
          _recurringPocketTemplateIdMeta,
        ),
      );
    }
    if (data.containsKey('related_transaction_id')) {
      context.handle(
        _relatedTransactionIdMeta,
        relatedTransactionId.isAcceptableOrUnknown(
          data['related_transaction_id']!,
          _relatedTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PocketMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PocketMovementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pocketId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pocket_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      recurringPocketTemplateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_pocket_template_id'],
      ),
      relatedTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}related_transaction_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PocketMovementsTable createAlias(String alias) {
    return $PocketMovementsTable(attachedDatabase, alias);
  }
}

class PocketMovementRow extends DataClass
    implements Insertable<PocketMovementRow> {
  final int id;
  final int pocketId;
  final int amountCents;
  final DateTime date;
  final String? note;

  /// Igual que `Transactions.recurringTemplateId`: si esto lo genero una
  /// aportacion automatica, el id de esa plantilla, sin `.references()`
  /// para que borrar la plantilla no afecte al historico ya generado.
  final int? recurringPocketTemplateId;

  /// Si este movimiento lo genero pagar un gasto con esta hucha (en vez
  /// de con la "cuenta principal"), el id de ese gasto en `Transactions`.
  /// Sirve para mantener el importe sincronizado si se edita el gasto, y
  /// para dejar de contar este movimiento si el gasto se borra (ver
  /// `pocketBalances`/`movementsForPocket`) — sin duplicar el concepto de
  /// "borrado" aqui: el estado real vive en `Transactions.deletedAt`.
  /// Null en el resto de movimientos (meter/sacar a mano, aportacion
  /// automatica).
  final int? relatedTransactionId;
  final DateTime createdAt;
  const PocketMovementRow({
    required this.id,
    required this.pocketId,
    required this.amountCents,
    required this.date,
    this.note,
    this.recurringPocketTemplateId,
    this.relatedTransactionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pocket_id'] = Variable<int>(pocketId);
    map['amount_cents'] = Variable<int>(amountCents);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || recurringPocketTemplateId != null) {
      map['recurring_pocket_template_id'] = Variable<int>(
        recurringPocketTemplateId,
      );
    }
    if (!nullToAbsent || relatedTransactionId != null) {
      map['related_transaction_id'] = Variable<int>(relatedTransactionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PocketMovementsCompanion toCompanion(bool nullToAbsent) {
    return PocketMovementsCompanion(
      id: Value(id),
      pocketId: Value(pocketId),
      amountCents: Value(amountCents),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      recurringPocketTemplateId:
          recurringPocketTemplateId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringPocketTemplateId),
      relatedTransactionId: relatedTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedTransactionId),
      createdAt: Value(createdAt),
    );
  }

  factory PocketMovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PocketMovementRow(
      id: serializer.fromJson<int>(json['id']),
      pocketId: serializer.fromJson<int>(json['pocketId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      recurringPocketTemplateId: serializer.fromJson<int?>(
        json['recurringPocketTemplateId'],
      ),
      relatedTransactionId: serializer.fromJson<int?>(
        json['relatedTransactionId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pocketId': serializer.toJson<int>(pocketId),
      'amountCents': serializer.toJson<int>(amountCents),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'recurringPocketTemplateId': serializer.toJson<int?>(
        recurringPocketTemplateId,
      ),
      'relatedTransactionId': serializer.toJson<int?>(relatedTransactionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PocketMovementRow copyWith({
    int? id,
    int? pocketId,
    int? amountCents,
    DateTime? date,
    Value<String?> note = const Value.absent(),
    Value<int?> recurringPocketTemplateId = const Value.absent(),
    Value<int?> relatedTransactionId = const Value.absent(),
    DateTime? createdAt,
  }) => PocketMovementRow(
    id: id ?? this.id,
    pocketId: pocketId ?? this.pocketId,
    amountCents: amountCents ?? this.amountCents,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    recurringPocketTemplateId: recurringPocketTemplateId.present
        ? recurringPocketTemplateId.value
        : this.recurringPocketTemplateId,
    relatedTransactionId: relatedTransactionId.present
        ? relatedTransactionId.value
        : this.relatedTransactionId,
    createdAt: createdAt ?? this.createdAt,
  );
  PocketMovementRow copyWithCompanion(PocketMovementsCompanion data) {
    return PocketMovementRow(
      id: data.id.present ? data.id.value : this.id,
      pocketId: data.pocketId.present ? data.pocketId.value : this.pocketId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      recurringPocketTemplateId: data.recurringPocketTemplateId.present
          ? data.recurringPocketTemplateId.value
          : this.recurringPocketTemplateId,
      relatedTransactionId: data.relatedTransactionId.present
          ? data.relatedTransactionId.value
          : this.relatedTransactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PocketMovementRow(')
          ..write('id: $id, ')
          ..write('pocketId: $pocketId, ')
          ..write('amountCents: $amountCents, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('recurringPocketTemplateId: $recurringPocketTemplateId, ')
          ..write('relatedTransactionId: $relatedTransactionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pocketId,
    amountCents,
    date,
    note,
    recurringPocketTemplateId,
    relatedTransactionId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PocketMovementRow &&
          other.id == this.id &&
          other.pocketId == this.pocketId &&
          other.amountCents == this.amountCents &&
          other.date == this.date &&
          other.note == this.note &&
          other.recurringPocketTemplateId == this.recurringPocketTemplateId &&
          other.relatedTransactionId == this.relatedTransactionId &&
          other.createdAt == this.createdAt);
}

class PocketMovementsCompanion extends UpdateCompanion<PocketMovementRow> {
  final Value<int> id;
  final Value<int> pocketId;
  final Value<int> amountCents;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<int?> recurringPocketTemplateId;
  final Value<int?> relatedTransactionId;
  final Value<DateTime> createdAt;
  const PocketMovementsCompanion({
    this.id = const Value.absent(),
    this.pocketId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.recurringPocketTemplateId = const Value.absent(),
    this.relatedTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PocketMovementsCompanion.insert({
    this.id = const Value.absent(),
    required int pocketId,
    required int amountCents,
    required DateTime date,
    this.note = const Value.absent(),
    this.recurringPocketTemplateId = const Value.absent(),
    this.relatedTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : pocketId = Value(pocketId),
       amountCents = Value(amountCents),
       date = Value(date);
  static Insertable<PocketMovementRow> custom({
    Expression<int>? id,
    Expression<int>? pocketId,
    Expression<int>? amountCents,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<int>? recurringPocketTemplateId,
    Expression<int>? relatedTransactionId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pocketId != null) 'pocket_id': pocketId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (recurringPocketTemplateId != null)
        'recurring_pocket_template_id': recurringPocketTemplateId,
      if (relatedTransactionId != null)
        'related_transaction_id': relatedTransactionId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PocketMovementsCompanion copyWith({
    Value<int>? id,
    Value<int>? pocketId,
    Value<int>? amountCents,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<int?>? recurringPocketTemplateId,
    Value<int?>? relatedTransactionId,
    Value<DateTime>? createdAt,
  }) {
    return PocketMovementsCompanion(
      id: id ?? this.id,
      pocketId: pocketId ?? this.pocketId,
      amountCents: amountCents ?? this.amountCents,
      date: date ?? this.date,
      note: note ?? this.note,
      recurringPocketTemplateId:
          recurringPocketTemplateId ?? this.recurringPocketTemplateId,
      relatedTransactionId: relatedTransactionId ?? this.relatedTransactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pocketId.present) {
      map['pocket_id'] = Variable<int>(pocketId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (recurringPocketTemplateId.present) {
      map['recurring_pocket_template_id'] = Variable<int>(
        recurringPocketTemplateId.value,
      );
    }
    if (relatedTransactionId.present) {
      map['related_transaction_id'] = Variable<int>(relatedTransactionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PocketMovementsCompanion(')
          ..write('id: $id, ')
          ..write('pocketId: $pocketId, ')
          ..write('amountCents: $amountCents, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('recurringPocketTemplateId: $recurringPocketTemplateId, ')
          ..write('relatedTransactionId: $relatedTransactionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PocketRecurringTemplatesTable extends PocketRecurringTemplates
    with TableInfo<$PocketRecurringTemplatesTable, PocketRecurringRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PocketRecurringTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pocketIdMeta = const VerificationMeta(
    'pocketId',
  );
  @override
  late final GeneratedColumn<int> pocketId = GeneratedColumn<int>(
    'pocket_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES savings_pockets (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _everyNMonthsMeta = const VerificationMeta(
    'everyNMonths',
  );
  @override
  late final GeneratedColumn<int> everyNMonths = GeneratedColumn<int>(
    'every_n_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _anchorYearMonthMeta = const VerificationMeta(
    'anchorYearMonth',
  );
  @override
  late final GeneratedColumn<String> anchorYearMonth = GeneratedColumn<String>(
    'anchor_year_month',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pocketId,
    name,
    amountCents,
    dayOfMonth,
    everyNMonths,
    anchorYearMonth,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pocket_recurring_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<PocketRecurringRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pocket_id')) {
      context.handle(
        _pocketIdMeta,
        pocketId.isAcceptableOrUnknown(data['pocket_id']!, _pocketIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pocketIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayOfMonthMeta);
    }
    if (data.containsKey('every_n_months')) {
      context.handle(
        _everyNMonthsMeta,
        everyNMonths.isAcceptableOrUnknown(
          data['every_n_months']!,
          _everyNMonthsMeta,
        ),
      );
    }
    if (data.containsKey('anchor_year_month')) {
      context.handle(
        _anchorYearMonthMeta,
        anchorYearMonth.isAcceptableOrUnknown(
          data['anchor_year_month']!,
          _anchorYearMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anchorYearMonthMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PocketRecurringRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PocketRecurringRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pocketId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pocket_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      )!,
      everyNMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}every_n_months'],
      )!,
      anchorYearMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor_year_month'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $PocketRecurringTemplatesTable createAlias(String alias) {
    return $PocketRecurringTemplatesTable(attachedDatabase, alias);
  }
}

class PocketRecurringRow extends DataClass
    implements Insertable<PocketRecurringRow> {
  final int id;
  final int pocketId;
  final String name;
  final int amountCents;
  final int dayOfMonth;
  final int everyNMonths;
  final String anchorYearMonth;
  final bool active;
  const PocketRecurringRow({
    required this.id,
    required this.pocketId,
    required this.name,
    required this.amountCents,
    required this.dayOfMonth,
    required this.everyNMonths,
    required this.anchorYearMonth,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pocket_id'] = Variable<int>(pocketId);
    map['name'] = Variable<String>(name);
    map['amount_cents'] = Variable<int>(amountCents);
    map['day_of_month'] = Variable<int>(dayOfMonth);
    map['every_n_months'] = Variable<int>(everyNMonths);
    map['anchor_year_month'] = Variable<String>(anchorYearMonth);
    map['active'] = Variable<bool>(active);
    return map;
  }

  PocketRecurringTemplatesCompanion toCompanion(bool nullToAbsent) {
    return PocketRecurringTemplatesCompanion(
      id: Value(id),
      pocketId: Value(pocketId),
      name: Value(name),
      amountCents: Value(amountCents),
      dayOfMonth: Value(dayOfMonth),
      everyNMonths: Value(everyNMonths),
      anchorYearMonth: Value(anchorYearMonth),
      active: Value(active),
    );
  }

  factory PocketRecurringRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PocketRecurringRow(
      id: serializer.fromJson<int>(json['id']),
      pocketId: serializer.fromJson<int>(json['pocketId']),
      name: serializer.fromJson<String>(json['name']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      everyNMonths: serializer.fromJson<int>(json['everyNMonths']),
      anchorYearMonth: serializer.fromJson<String>(json['anchorYearMonth']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pocketId': serializer.toJson<int>(pocketId),
      'name': serializer.toJson<String>(name),
      'amountCents': serializer.toJson<int>(amountCents),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'everyNMonths': serializer.toJson<int>(everyNMonths),
      'anchorYearMonth': serializer.toJson<String>(anchorYearMonth),
      'active': serializer.toJson<bool>(active),
    };
  }

  PocketRecurringRow copyWith({
    int? id,
    int? pocketId,
    String? name,
    int? amountCents,
    int? dayOfMonth,
    int? everyNMonths,
    String? anchorYearMonth,
    bool? active,
  }) => PocketRecurringRow(
    id: id ?? this.id,
    pocketId: pocketId ?? this.pocketId,
    name: name ?? this.name,
    amountCents: amountCents ?? this.amountCents,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    everyNMonths: everyNMonths ?? this.everyNMonths,
    anchorYearMonth: anchorYearMonth ?? this.anchorYearMonth,
    active: active ?? this.active,
  );
  PocketRecurringRow copyWithCompanion(PocketRecurringTemplatesCompanion data) {
    return PocketRecurringRow(
      id: data.id.present ? data.id.value : this.id,
      pocketId: data.pocketId.present ? data.pocketId.value : this.pocketId,
      name: data.name.present ? data.name.value : this.name,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      everyNMonths: data.everyNMonths.present
          ? data.everyNMonths.value
          : this.everyNMonths,
      anchorYearMonth: data.anchorYearMonth.present
          ? data.anchorYearMonth.value
          : this.anchorYearMonth,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PocketRecurringRow(')
          ..write('id: $id, ')
          ..write('pocketId: $pocketId, ')
          ..write('name: $name, ')
          ..write('amountCents: $amountCents, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('everyNMonths: $everyNMonths, ')
          ..write('anchorYearMonth: $anchorYearMonth, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pocketId,
    name,
    amountCents,
    dayOfMonth,
    everyNMonths,
    anchorYearMonth,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PocketRecurringRow &&
          other.id == this.id &&
          other.pocketId == this.pocketId &&
          other.name == this.name &&
          other.amountCents == this.amountCents &&
          other.dayOfMonth == this.dayOfMonth &&
          other.everyNMonths == this.everyNMonths &&
          other.anchorYearMonth == this.anchorYearMonth &&
          other.active == this.active);
}

class PocketRecurringTemplatesCompanion
    extends UpdateCompanion<PocketRecurringRow> {
  final Value<int> id;
  final Value<int> pocketId;
  final Value<String> name;
  final Value<int> amountCents;
  final Value<int> dayOfMonth;
  final Value<int> everyNMonths;
  final Value<String> anchorYearMonth;
  final Value<bool> active;
  const PocketRecurringTemplatesCompanion({
    this.id = const Value.absent(),
    this.pocketId = const Value.absent(),
    this.name = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.everyNMonths = const Value.absent(),
    this.anchorYearMonth = const Value.absent(),
    this.active = const Value.absent(),
  });
  PocketRecurringTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required int pocketId,
    required String name,
    required int amountCents,
    required int dayOfMonth,
    this.everyNMonths = const Value.absent(),
    required String anchorYearMonth,
    this.active = const Value.absent(),
  }) : pocketId = Value(pocketId),
       name = Value(name),
       amountCents = Value(amountCents),
       dayOfMonth = Value(dayOfMonth),
       anchorYearMonth = Value(anchorYearMonth);
  static Insertable<PocketRecurringRow> custom({
    Expression<int>? id,
    Expression<int>? pocketId,
    Expression<String>? name,
    Expression<int>? amountCents,
    Expression<int>? dayOfMonth,
    Expression<int>? everyNMonths,
    Expression<String>? anchorYearMonth,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pocketId != null) 'pocket_id': pocketId,
      if (name != null) 'name': name,
      if (amountCents != null) 'amount_cents': amountCents,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (everyNMonths != null) 'every_n_months': everyNMonths,
      if (anchorYearMonth != null) 'anchor_year_month': anchorYearMonth,
      if (active != null) 'active': active,
    });
  }

  PocketRecurringTemplatesCompanion copyWith({
    Value<int>? id,
    Value<int>? pocketId,
    Value<String>? name,
    Value<int>? amountCents,
    Value<int>? dayOfMonth,
    Value<int>? everyNMonths,
    Value<String>? anchorYearMonth,
    Value<bool>? active,
  }) {
    return PocketRecurringTemplatesCompanion(
      id: id ?? this.id,
      pocketId: pocketId ?? this.pocketId,
      name: name ?? this.name,
      amountCents: amountCents ?? this.amountCents,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      everyNMonths: everyNMonths ?? this.everyNMonths,
      anchorYearMonth: anchorYearMonth ?? this.anchorYearMonth,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pocketId.present) {
      map['pocket_id'] = Variable<int>(pocketId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (everyNMonths.present) {
      map['every_n_months'] = Variable<int>(everyNMonths.value);
    }
    if (anchorYearMonth.present) {
      map['anchor_year_month'] = Variable<String>(anchorYearMonth.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PocketRecurringTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('pocketId: $pocketId, ')
          ..write('name: $name, ')
          ..write('amountCents: $amountCents, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('everyNMonths: $everyNMonths, ')
          ..write('anchorYearMonth: $anchorYearMonth, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultTreatRateMeta = const VerificationMeta(
    'defaultTreatRate',
  );
  @override
  late final GeneratedColumn<double> defaultTreatRate = GeneratedColumn<double>(
    'default_treat_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _showPocketsInTotalMeta =
      const VerificationMeta('showPocketsInTotal');
  @override
  late final GeneratedColumn<bool> showPocketsInTotal = GeneratedColumn<bool>(
    'show_pockets_in_total',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_pockets_in_total" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dismissedTreatSweepYearMonthMeta =
      const VerificationMeta('dismissedTreatSweepYearMonth');
  @override
  late final GeneratedColumn<String> dismissedTreatSweepYearMonth =
      GeneratedColumn<String>(
        'dismissed_treat_sweep_year_month',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 7,
          maxTextLength: 7,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _monthStartDayMeta = const VerificationMeta(
    'monthStartDay',
  );
  @override
  late final GeneratedColumn<int> monthStartDay = GeneratedColumn<int>(
    'month_start_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasSeenTutorialMeta = const VerificationMeta(
    'hasSeenTutorial',
  );
  @override
  late final GeneratedColumn<bool> hasSeenTutorial = GeneratedColumn<bool>(
    'has_seen_tutorial',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_seen_tutorial" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    defaultTreatRate,
    showPocketsInTotal,
    dismissedTreatSweepYearMonth,
    monthStartDay,
    hasSeenTutorial,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('default_treat_rate')) {
      context.handle(
        _defaultTreatRateMeta,
        defaultTreatRate.isAcceptableOrUnknown(
          data['default_treat_rate']!,
          _defaultTreatRateMeta,
        ),
      );
    }
    if (data.containsKey('show_pockets_in_total')) {
      context.handle(
        _showPocketsInTotalMeta,
        showPocketsInTotal.isAcceptableOrUnknown(
          data['show_pockets_in_total']!,
          _showPocketsInTotalMeta,
        ),
      );
    }
    if (data.containsKey('dismissed_treat_sweep_year_month')) {
      context.handle(
        _dismissedTreatSweepYearMonthMeta,
        dismissedTreatSweepYearMonth.isAcceptableOrUnknown(
          data['dismissed_treat_sweep_year_month']!,
          _dismissedTreatSweepYearMonthMeta,
        ),
      );
    }
    if (data.containsKey('month_start_day')) {
      context.handle(
        _monthStartDayMeta,
        monthStartDay.isAcceptableOrUnknown(
          data['month_start_day']!,
          _monthStartDayMeta,
        ),
      );
    }
    if (data.containsKey('has_seen_tutorial')) {
      context.handle(
        _hasSeenTutorialMeta,
        hasSeenTutorial.isAcceptableOrUnknown(
          data['has_seen_tutorial']!,
          _hasSeenTutorialMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      defaultTreatRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_treat_rate'],
      ),
      showPocketsInTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_pockets_in_total'],
      )!,
      dismissedTreatSweepYearMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dismissed_treat_sweep_year_month'],
      ),
      monthStartDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_start_day'],
      ),
      hasSeenTutorial: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_seen_tutorial'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final int id;

  /// Sustituye a `kDefaultTreatRate` (10 %) como margen de caprichos por
  /// defecto para los meses que no tengan su propio `Months.treatRate`.
  /// Null = se sigue usando el 10 % de fabrica.
  final double? defaultTreatRate;

  /// Que muestra "Ahorro total" en Inicio: true = el ahorro real
  /// (incluye lo que llevas metido en huchas), false = solo lo disponible
  /// sin apartar (ahorro real - huchas).
  final bool showPocketsInTotal;

  /// "2026-09": el mes en el que Inicio ya preguntó (o el usuario ya
  /// contestó) que hacer con el sobrante de caprichos del mes anterior.
  /// Evita repetir el aviso en cada apertura de la app durante el mismo
  /// mes, tanto si se movió a una hucha como si se eligió seguir
  /// acumulandolo. Null = todavia no se ha preguntado nunca.
  final String? dismissedTreatSweepYearMonth;

  /// Día 1-28 en el que "empieza el mes" para todos los cálculos
  /// (`SavingsRepository.yearMonthOf`). Null = 1, el calendario de toda
  /// la vida. Puesto a otro día (p. ej. 28, el día de cobro de Pol), un
  /// "mes" pasa a ser un ciclo de nómina a nómina en vez de un mes de
  /// calendario — el día 28 de agosto ya cuenta para "septiembre", no
  /// para "agosto" (se etiqueta por el mes en el que termina el ciclo).
  /// Igual que `dayOfMonth` en `RecurringTemplates`, limitado a 1-28 para
  /// no pelearse con febrero.
  final int? monthStartDay;

  /// Si ya se le enseño el tutorial guiado (bolsa de caprichos + como
  /// apuntar un gasto) al menos una vez -- por defecto false, asi que a
  /// una instalacion nueva se le ofrece automaticamente en Inicio. Se
  /// pone a true tanto al terminar el tutorial entero como al pulsar
  /// "Saltar tutorial" (las dos cuentan como "ya visto", para no volver a
  /// insistir). "Ajustes > Repetir tutorial" lo pone de nuevo a false.
  final bool hasSeenTutorial;
  const AppSettingsRow({
    required this.id,
    this.defaultTreatRate,
    required this.showPocketsInTotal,
    this.dismissedTreatSweepYearMonth,
    this.monthStartDay,
    required this.hasSeenTutorial,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || defaultTreatRate != null) {
      map['default_treat_rate'] = Variable<double>(defaultTreatRate);
    }
    map['show_pockets_in_total'] = Variable<bool>(showPocketsInTotal);
    if (!nullToAbsent || dismissedTreatSweepYearMonth != null) {
      map['dismissed_treat_sweep_year_month'] = Variable<String>(
        dismissedTreatSweepYearMonth,
      );
    }
    if (!nullToAbsent || monthStartDay != null) {
      map['month_start_day'] = Variable<int>(monthStartDay);
    }
    map['has_seen_tutorial'] = Variable<bool>(hasSeenTutorial);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      defaultTreatRate: defaultTreatRate == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultTreatRate),
      showPocketsInTotal: Value(showPocketsInTotal),
      dismissedTreatSweepYearMonth:
          dismissedTreatSweepYearMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(dismissedTreatSweepYearMonth),
      monthStartDay: monthStartDay == null && nullToAbsent
          ? const Value.absent()
          : Value(monthStartDay),
      hasSeenTutorial: Value(hasSeenTutorial),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      defaultTreatRate: serializer.fromJson<double?>(json['defaultTreatRate']),
      showPocketsInTotal: serializer.fromJson<bool>(json['showPocketsInTotal']),
      dismissedTreatSweepYearMonth: serializer.fromJson<String?>(
        json['dismissedTreatSweepYearMonth'],
      ),
      monthStartDay: serializer.fromJson<int?>(json['monthStartDay']),
      hasSeenTutorial: serializer.fromJson<bool>(json['hasSeenTutorial']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'defaultTreatRate': serializer.toJson<double?>(defaultTreatRate),
      'showPocketsInTotal': serializer.toJson<bool>(showPocketsInTotal),
      'dismissedTreatSweepYearMonth': serializer.toJson<String?>(
        dismissedTreatSweepYearMonth,
      ),
      'monthStartDay': serializer.toJson<int?>(monthStartDay),
      'hasSeenTutorial': serializer.toJson<bool>(hasSeenTutorial),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    Value<double?> defaultTreatRate = const Value.absent(),
    bool? showPocketsInTotal,
    Value<String?> dismissedTreatSweepYearMonth = const Value.absent(),
    Value<int?> monthStartDay = const Value.absent(),
    bool? hasSeenTutorial,
  }) => AppSettingsRow(
    id: id ?? this.id,
    defaultTreatRate: defaultTreatRate.present
        ? defaultTreatRate.value
        : this.defaultTreatRate,
    showPocketsInTotal: showPocketsInTotal ?? this.showPocketsInTotal,
    dismissedTreatSweepYearMonth: dismissedTreatSweepYearMonth.present
        ? dismissedTreatSweepYearMonth.value
        : this.dismissedTreatSweepYearMonth,
    monthStartDay: monthStartDay.present
        ? monthStartDay.value
        : this.monthStartDay,
    hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      defaultTreatRate: data.defaultTreatRate.present
          ? data.defaultTreatRate.value
          : this.defaultTreatRate,
      showPocketsInTotal: data.showPocketsInTotal.present
          ? data.showPocketsInTotal.value
          : this.showPocketsInTotal,
      dismissedTreatSweepYearMonth: data.dismissedTreatSweepYearMonth.present
          ? data.dismissedTreatSweepYearMonth.value
          : this.dismissedTreatSweepYearMonth,
      monthStartDay: data.monthStartDay.present
          ? data.monthStartDay.value
          : this.monthStartDay,
      hasSeenTutorial: data.hasSeenTutorial.present
          ? data.hasSeenTutorial.value
          : this.hasSeenTutorial,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('defaultTreatRate: $defaultTreatRate, ')
          ..write('showPocketsInTotal: $showPocketsInTotal, ')
          ..write(
            'dismissedTreatSweepYearMonth: $dismissedTreatSweepYearMonth, ',
          )
          ..write('monthStartDay: $monthStartDay, ')
          ..write('hasSeenTutorial: $hasSeenTutorial')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    defaultTreatRate,
    showPocketsInTotal,
    dismissedTreatSweepYearMonth,
    monthStartDay,
    hasSeenTutorial,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.defaultTreatRate == this.defaultTreatRate &&
          other.showPocketsInTotal == this.showPocketsInTotal &&
          other.dismissedTreatSweepYearMonth ==
              this.dismissedTreatSweepYearMonth &&
          other.monthStartDay == this.monthStartDay &&
          other.hasSeenTutorial == this.hasSeenTutorial);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<double?> defaultTreatRate;
  final Value<bool> showPocketsInTotal;
  final Value<String?> dismissedTreatSweepYearMonth;
  final Value<int?> monthStartDay;
  final Value<bool> hasSeenTutorial;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.defaultTreatRate = const Value.absent(),
    this.showPocketsInTotal = const Value.absent(),
    this.dismissedTreatSweepYearMonth = const Value.absent(),
    this.monthStartDay = const Value.absent(),
    this.hasSeenTutorial = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.defaultTreatRate = const Value.absent(),
    this.showPocketsInTotal = const Value.absent(),
    this.dismissedTreatSweepYearMonth = const Value.absent(),
    this.monthStartDay = const Value.absent(),
    this.hasSeenTutorial = const Value.absent(),
  });
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<double>? defaultTreatRate,
    Expression<bool>? showPocketsInTotal,
    Expression<String>? dismissedTreatSweepYearMonth,
    Expression<int>? monthStartDay,
    Expression<bool>? hasSeenTutorial,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (defaultTreatRate != null) 'default_treat_rate': defaultTreatRate,
      if (showPocketsInTotal != null)
        'show_pockets_in_total': showPocketsInTotal,
      if (dismissedTreatSweepYearMonth != null)
        'dismissed_treat_sweep_year_month': dismissedTreatSweepYearMonth,
      if (monthStartDay != null) 'month_start_day': monthStartDay,
      if (hasSeenTutorial != null) 'has_seen_tutorial': hasSeenTutorial,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<double?>? defaultTreatRate,
    Value<bool>? showPocketsInTotal,
    Value<String?>? dismissedTreatSweepYearMonth,
    Value<int?>? monthStartDay,
    Value<bool>? hasSeenTutorial,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      defaultTreatRate: defaultTreatRate ?? this.defaultTreatRate,
      showPocketsInTotal: showPocketsInTotal ?? this.showPocketsInTotal,
      dismissedTreatSweepYearMonth:
          dismissedTreatSweepYearMonth ?? this.dismissedTreatSweepYearMonth,
      monthStartDay: monthStartDay ?? this.monthStartDay,
      hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (defaultTreatRate.present) {
      map['default_treat_rate'] = Variable<double>(defaultTreatRate.value);
    }
    if (showPocketsInTotal.present) {
      map['show_pockets_in_total'] = Variable<bool>(showPocketsInTotal.value);
    }
    if (dismissedTreatSweepYearMonth.present) {
      map['dismissed_treat_sweep_year_month'] = Variable<String>(
        dismissedTreatSweepYearMonth.value,
      );
    }
    if (monthStartDay.present) {
      map['month_start_day'] = Variable<int>(monthStartDay.value);
    }
    if (hasSeenTutorial.present) {
      map['has_seen_tutorial'] = Variable<bool>(hasSeenTutorial.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('defaultTreatRate: $defaultTreatRate, ')
          ..write('showPocketsInTotal: $showPocketsInTotal, ')
          ..write(
            'dismissedTreatSweepYearMonth: $dismissedTreatSweepYearMonth, ',
          )
          ..write('monthStartDay: $monthStartDay, ')
          ..write('hasSeenTutorial: $hasSeenTutorial')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $RecurringTemplatesTable recurringTemplates =
      $RecurringTemplatesTable(this);
  late final $MonthsTable months = $MonthsTable(this);
  late final $QuickActionsTable quickActions = $QuickActionsTable(this);
  late final $SavingsPocketsTable savingsPockets = $SavingsPocketsTable(this);
  late final $PocketMovementsTable pocketMovements = $PocketMovementsTable(
    this,
  );
  late final $PocketRecurringTemplatesTable pocketRecurringTemplates =
      $PocketRecurringTemplatesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    transactions,
    recurringTemplates,
    months,
    quickActions,
    savingsPockets,
    pocketMovements,
    pocketRecurringTemplates,
    appSettings,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required CategoryKindDb kind,
      Value<String> icon,
      Value<int?> color,
      Value<int> sortOrder,
      Value<bool> archived,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<CategoryKindDb> kind,
      Value<String> icon,
      Value<int?> color,
      Value<int> sortOrder,
      Value<bool> archived,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecurringTemplatesTable, List<RecurringRow>>
  _recurringTemplatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringTemplates,
        aliasName: 'categories__id__recurring_templates__category_id',
      );

  $$RecurringTemplatesTableProcessedTableManager get recurringTemplatesRefs {
    final manager = $$RecurringTemplatesTableTableManager(
      $_db,
      $_db.recurringTemplates,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringTemplatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuickActionsTable, List<QuickActionRow>>
  _quickActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.quickActions,
    aliasName: 'categories__id__quick_actions__category_id',
  );

  $$QuickActionsTableProcessedTableManager get quickActionsRefs {
    final manager = $$QuickActionsTableTableManager(
      $_db,
      $_db.quickActions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_quickActionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CategoryKindDb, CategoryKindDb, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringTemplatesRefs(
    Expression<bool> Function($$RecurringTemplatesTableFilterComposer f) f,
  ) {
    final $$RecurringTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringTemplates,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.recurringTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quickActionsRefs(
    Expression<bool> Function($$QuickActionsTableFilterComposer f) f,
  ) {
    final $$QuickActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quickActions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuickActionsTableFilterComposer(
            $db: $db,
            $table: $db.quickActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<CategoryKindDb, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringTemplatesRefs<T extends Object>(
    Expression<T> Function($$RecurringTemplatesTableAnnotationComposer a) f,
  ) {
    final $$RecurringTemplatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTemplates,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTemplatesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringTemplates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> quickActionsRefs<T extends Object>(
    Expression<T> Function($$QuickActionsTableAnnotationComposer a) f,
  ) {
    final $$QuickActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quickActions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuickActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.quickActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({
            bool transactionsRefs,
            bool recurringTemplatesRefs,
            bool quickActionsRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<CategoryKindDb> kind = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                kind: kind,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                archived: archived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required CategoryKindDb kind,
                Value<String> icon = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                archived: archived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                transactionsRefs = false,
                recurringTemplatesRefs = false,
                quickActionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (recurringTemplatesRefs) db.recurringTemplates,
                    if (quickActionsRefs) db.quickActions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          TransactionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringTemplatesRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          RecurringRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._recurringTemplatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringTemplatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (quickActionsRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          QuickActionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._quickActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).quickActionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
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

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({
        bool transactionsRefs,
        bool recurringTemplatesRefs,
        bool quickActionsRefs,
      })
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required DateTime date,
      required int amountCents,
      required int categoryId,
      Value<String?> note,
      Value<int?> refundOfId,
      Value<DateTime?> deletedAt,
      Value<String?> deleteReason,
      Value<int?> recurringTemplateId,
      Value<int?> paidFromPocketId,
      Value<DateTime> createdAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> amountCents,
      Value<int> categoryId,
      Value<String?> note,
      Value<int?> refundOfId,
      Value<DateTime?> deletedAt,
      Value<String?> deleteReason,
      Value<int?> recurringTemplateId,
      Value<int?> paidFromPocketId,
      Value<DateTime> createdAt,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TransactionsTable _refundOfIdTable(_$AppDatabase db) => db
      .transactions
      .createAlias('transactions__refund_of_id__transactions__id');

  $$TransactionsTableProcessedTableManager? get refundOfId {
    final $_column = $_itemColumn<int>('refund_of_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_refundOfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deleteReason => $composableBuilder(
    column: $table.deleteReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurringTemplateId => $composableBuilder(
    column: $table.recurringTemplateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidFromPocketId => $composableBuilder(
    column: $table.paidFromPocketId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableFilterComposer get refundOfId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refundOfId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deleteReason => $composableBuilder(
    column: $table.deleteReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurringTemplateId => $composableBuilder(
    column: $table.recurringTemplateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidFromPocketId => $composableBuilder(
    column: $table.paidFromPocketId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableOrderingComposer get refundOfId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refundOfId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deleteReason => $composableBuilder(
    column: $table.deleteReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurringTemplateId => $composableBuilder(
    column: $table.recurringTemplateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidFromPocketId => $composableBuilder(
    column: $table.paidFromPocketId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableAnnotationComposer get refundOfId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refundOfId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (TransactionRow, $$TransactionsTableReferences),
          TransactionRow,
          PrefetchHooks Function({bool categoryId, bool refundOfId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> refundOfId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deleteReason = const Value.absent(),
                Value<int?> recurringTemplateId = const Value.absent(),
                Value<int?> paidFromPocketId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                date: date,
                amountCents: amountCents,
                categoryId: categoryId,
                note: note,
                refundOfId: refundOfId,
                deletedAt: deletedAt,
                deleteReason: deleteReason,
                recurringTemplateId: recurringTemplateId,
                paidFromPocketId: paidFromPocketId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int amountCents,
                required int categoryId,
                Value<String?> note = const Value.absent(),
                Value<int?> refundOfId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deleteReason = const Value.absent(),
                Value<int?> recurringTemplateId = const Value.absent(),
                Value<int?> paidFromPocketId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                date: date,
                amountCents: amountCents,
                categoryId: categoryId,
                note: note,
                refundOfId: refundOfId,
                deletedAt: deletedAt,
                deleteReason: deleteReason,
                recurringTemplateId: recurringTemplateId,
                paidFromPocketId: paidFromPocketId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false, refundOfId = false}) {
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
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$TransactionsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$TransactionsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (refundOfId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.refundOfId,
                                referencedTable: $$TransactionsTableReferences
                                    ._refundOfIdTable(db),
                                referencedColumn: $$TransactionsTableReferences
                                    ._refundOfIdTable(db)
                                    .id,
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (TransactionRow, $$TransactionsTableReferences),
      TransactionRow,
      PrefetchHooks Function({bool categoryId, bool refundOfId})
    >;
typedef $$RecurringTemplatesTableCreateCompanionBuilder =
    RecurringTemplatesCompanion Function({
      Value<int> id,
      required int categoryId,
      required String name,
      required int amountCents,
      required int dayOfMonth,
      Value<int> everyNMonths,
      required String anchorYearMonth,
      Value<bool> active,
    });
typedef $$RecurringTemplatesTableUpdateCompanionBuilder =
    RecurringTemplatesCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<String> name,
      Value<int> amountCents,
      Value<int> dayOfMonth,
      Value<int> everyNMonths,
      Value<String> anchorYearMonth,
      Value<bool> active,
    });

final class $$RecurringTemplatesTableReferences
    extends
        BaseReferences<_$AppDatabase, $RecurringTemplatesTable, RecurringRow> {
  $$RecurringTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('recurring_templates__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecurringTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get everyNMonths => $composableBuilder(
    column: $table.everyNMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchorYearMonth => $composableBuilder(
    column: $table.anchorYearMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get everyNMonths => $composableBuilder(
    column: $table.everyNMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorYearMonth => $composableBuilder(
    column: $table.anchorYearMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableAnnotationComposer({
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

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get everyNMonths => $composableBuilder(
    column: $table.everyNMonths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get anchorYearMonth => $composableBuilder(
    column: $table.anchorYearMonth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringTemplatesTable,
          RecurringRow,
          $$RecurringTemplatesTableFilterComposer,
          $$RecurringTemplatesTableOrderingComposer,
          $$RecurringTemplatesTableAnnotationComposer,
          $$RecurringTemplatesTableCreateCompanionBuilder,
          $$RecurringTemplatesTableUpdateCompanionBuilder,
          (RecurringRow, $$RecurringTemplatesTableReferences),
          RecurringRow,
          PrefetchHooks Function({bool categoryId})
        > {
  $$RecurringTemplatesTableTableManager(
    _$AppDatabase db,
    $RecurringTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int> dayOfMonth = const Value.absent(),
                Value<int> everyNMonths = const Value.absent(),
                Value<String> anchorYearMonth = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => RecurringTemplatesCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                amountCents: amountCents,
                dayOfMonth: dayOfMonth,
                everyNMonths: everyNMonths,
                anchorYearMonth: anchorYearMonth,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required String name,
                required int amountCents,
                required int dayOfMonth,
                Value<int> everyNMonths = const Value.absent(),
                required String anchorYearMonth,
                Value<bool> active = const Value.absent(),
              }) => RecurringTemplatesCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                amountCents: amountCents,
                dayOfMonth: dayOfMonth,
                everyNMonths: everyNMonths,
                anchorYearMonth: anchorYearMonth,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecurringTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$RecurringTemplatesTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$RecurringTemplatesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
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

typedef $$RecurringTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringTemplatesTable,
      RecurringRow,
      $$RecurringTemplatesTableFilterComposer,
      $$RecurringTemplatesTableOrderingComposer,
      $$RecurringTemplatesTableAnnotationComposer,
      $$RecurringTemplatesTableCreateCompanionBuilder,
      $$RecurringTemplatesTableUpdateCompanionBuilder,
      (RecurringRow, $$RecurringTemplatesTableReferences),
      RecurringRow,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$MonthsTableCreateCompanionBuilder =
    MonthsCompanion Function({
      required String yearMonth,
      Value<double?> treatRate,
      Value<int?> openingBalanceCents,
      Value<int> rowid,
    });
typedef $$MonthsTableUpdateCompanionBuilder =
    MonthsCompanion Function({
      Value<String> yearMonth,
      Value<double?> treatRate,
      Value<int?> openingBalanceCents,
      Value<int> rowid,
    });

class $$MonthsTableFilterComposer
    extends Composer<_$AppDatabase, $MonthsTable> {
  $$MonthsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get treatRate => $composableBuilder(
    column: $table.treatRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonthsTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthsTable> {
  $$MonthsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get treatRate => $composableBuilder(
    column: $table.treatRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonthsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthsTable> {
  $$MonthsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get yearMonth =>
      $composableBuilder(column: $table.yearMonth, builder: (column) => column);

  GeneratedColumn<double> get treatRate =>
      $composableBuilder(column: $table.treatRate, builder: (column) => column);

  GeneratedColumn<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => column,
  );
}

class $$MonthsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonthsTable,
          MonthRow,
          $$MonthsTableFilterComposer,
          $$MonthsTableOrderingComposer,
          $$MonthsTableAnnotationComposer,
          $$MonthsTableCreateCompanionBuilder,
          $$MonthsTableUpdateCompanionBuilder,
          (MonthRow, BaseReferences<_$AppDatabase, $MonthsTable, MonthRow>),
          MonthRow,
          PrefetchHooks Function()
        > {
  $$MonthsTableTableManager(_$AppDatabase db, $MonthsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> yearMonth = const Value.absent(),
                Value<double?> treatRate = const Value.absent(),
                Value<int?> openingBalanceCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthsCompanion(
                yearMonth: yearMonth,
                treatRate: treatRate,
                openingBalanceCents: openingBalanceCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String yearMonth,
                Value<double?> treatRate = const Value.absent(),
                Value<int?> openingBalanceCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthsCompanion.insert(
                yearMonth: yearMonth,
                treatRate: treatRate,
                openingBalanceCents: openingBalanceCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonthsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonthsTable,
      MonthRow,
      $$MonthsTableFilterComposer,
      $$MonthsTableOrderingComposer,
      $$MonthsTableAnnotationComposer,
      $$MonthsTableCreateCompanionBuilder,
      $$MonthsTableUpdateCompanionBuilder,
      (MonthRow, BaseReferences<_$AppDatabase, $MonthsTable, MonthRow>),
      MonthRow,
      PrefetchHooks Function()
    >;
typedef $$QuickActionsTableCreateCompanionBuilder =
    QuickActionsCompanion Function({
      Value<int> id,
      required String label,
      required int amountCents,
      required int categoryId,
      Value<int> sortOrder,
    });
typedef $$QuickActionsTableUpdateCompanionBuilder =
    QuickActionsCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<int> amountCents,
      Value<int> categoryId,
      Value<int> sortOrder,
    });

final class $$QuickActionsTableReferences
    extends BaseReferences<_$AppDatabase, $QuickActionsTable, QuickActionRow> {
  $$QuickActionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('quick_actions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuickActionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuickActionsTable> {
  $$QuickActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuickActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuickActionsTable> {
  $$QuickActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuickActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuickActionsTable> {
  $$QuickActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuickActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuickActionsTable,
          QuickActionRow,
          $$QuickActionsTableFilterComposer,
          $$QuickActionsTableOrderingComposer,
          $$QuickActionsTableAnnotationComposer,
          $$QuickActionsTableCreateCompanionBuilder,
          $$QuickActionsTableUpdateCompanionBuilder,
          (QuickActionRow, $$QuickActionsTableReferences),
          QuickActionRow,
          PrefetchHooks Function({bool categoryId})
        > {
  $$QuickActionsTableTableManager(_$AppDatabase db, $QuickActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuickActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuickActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuickActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => QuickActionsCompanion(
                id: id,
                label: label,
                amountCents: amountCents,
                categoryId: categoryId,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required int amountCents,
                required int categoryId,
                Value<int> sortOrder = const Value.absent(),
              }) => QuickActionsCompanion.insert(
                id: id,
                label: label,
                amountCents: amountCents,
                categoryId: categoryId,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuickActionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$QuickActionsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$QuickActionsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
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

typedef $$QuickActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuickActionsTable,
      QuickActionRow,
      $$QuickActionsTableFilterComposer,
      $$QuickActionsTableOrderingComposer,
      $$QuickActionsTableAnnotationComposer,
      $$QuickActionsTableCreateCompanionBuilder,
      $$QuickActionsTableUpdateCompanionBuilder,
      (QuickActionRow, $$QuickActionsTableReferences),
      QuickActionRow,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$SavingsPocketsTableCreateCompanionBuilder =
    SavingsPocketsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> targetCents,
      Value<int> sortOrder,
      Value<bool> archived,
    });
typedef $$SavingsPocketsTableUpdateCompanionBuilder =
    SavingsPocketsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> targetCents,
      Value<int> sortOrder,
      Value<bool> archived,
    });

final class $$SavingsPocketsTableReferences
    extends BaseReferences<_$AppDatabase, $SavingsPocketsTable, PocketRow> {
  $$SavingsPocketsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PocketMovementsTable, List<PocketMovementRow>>
  _pocketMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pocketMovements,
    aliasName: 'savings_pockets__id__pocket_movements__pocket_id',
  );

  $$PocketMovementsTableProcessedTableManager get pocketMovementsRefs {
    final manager = $$PocketMovementsTableTableManager(
      $_db,
      $_db.pocketMovements,
    ).filter((f) => f.pocketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pocketMovementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PocketRecurringTemplatesTable,
    List<PocketRecurringRow>
  >
  _pocketRecurringTemplatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pocketRecurringTemplates,
        aliasName: 'savings_pockets__id__pocket_recurring_templates__pocket_id',
      );

  $$PocketRecurringTemplatesTableProcessedTableManager
  get pocketRecurringTemplatesRefs {
    final manager = $$PocketRecurringTemplatesTableTableManager(
      $_db,
      $_db.pocketRecurringTemplates,
    ).filter((f) => f.pocketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pocketRecurringTemplatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SavingsPocketsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsPocketsTable> {
  $$SavingsPocketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCents => $composableBuilder(
    column: $table.targetCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pocketMovementsRefs(
    Expression<bool> Function($$PocketMovementsTableFilterComposer f) f,
  ) {
    final $$PocketMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pocketMovements,
      getReferencedColumn: (t) => t.pocketId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PocketMovementsTableFilterComposer(
            $db: $db,
            $table: $db.pocketMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pocketRecurringTemplatesRefs(
    Expression<bool> Function($$PocketRecurringTemplatesTableFilterComposer f)
    f,
  ) {
    final $$PocketRecurringTemplatesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pocketRecurringTemplates,
          getReferencedColumn: (t) => t.pocketId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PocketRecurringTemplatesTableFilterComposer(
                $db: $db,
                $table: $db.pocketRecurringTemplates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SavingsPocketsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsPocketsTable> {
  $$SavingsPocketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCents => $composableBuilder(
    column: $table.targetCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsPocketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsPocketsTable> {
  $$SavingsPocketsTableAnnotationComposer({
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

  GeneratedColumn<int> get targetCents => $composableBuilder(
    column: $table.targetCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> pocketMovementsRefs<T extends Object>(
    Expression<T> Function($$PocketMovementsTableAnnotationComposer a) f,
  ) {
    final $$PocketMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pocketMovements,
      getReferencedColumn: (t) => t.pocketId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PocketMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.pocketMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pocketRecurringTemplatesRefs<T extends Object>(
    Expression<T> Function($$PocketRecurringTemplatesTableAnnotationComposer a)
    f,
  ) {
    final $$PocketRecurringTemplatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pocketRecurringTemplates,
          getReferencedColumn: (t) => t.pocketId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PocketRecurringTemplatesTableAnnotationComposer(
                $db: $db,
                $table: $db.pocketRecurringTemplates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SavingsPocketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsPocketsTable,
          PocketRow,
          $$SavingsPocketsTableFilterComposer,
          $$SavingsPocketsTableOrderingComposer,
          $$SavingsPocketsTableAnnotationComposer,
          $$SavingsPocketsTableCreateCompanionBuilder,
          $$SavingsPocketsTableUpdateCompanionBuilder,
          (PocketRow, $$SavingsPocketsTableReferences),
          PocketRow,
          PrefetchHooks Function({
            bool pocketMovementsRefs,
            bool pocketRecurringTemplatesRefs,
          })
        > {
  $$SavingsPocketsTableTableManager(
    _$AppDatabase db,
    $SavingsPocketsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsPocketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsPocketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsPocketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> targetCents = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => SavingsPocketsCompanion(
                id: id,
                name: name,
                targetCents: targetCents,
                sortOrder: sortOrder,
                archived: archived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> targetCents = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => SavingsPocketsCompanion.insert(
                id: id,
                name: name,
                targetCents: targetCents,
                sortOrder: sortOrder,
                archived: archived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavingsPocketsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pocketMovementsRefs = false,
                pocketRecurringTemplatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pocketMovementsRefs) db.pocketMovements,
                    if (pocketRecurringTemplatesRefs)
                      db.pocketRecurringTemplates,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pocketMovementsRefs)
                        await $_getPrefetchedData<
                          PocketRow,
                          $SavingsPocketsTable,
                          PocketMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$SavingsPocketsTableReferences
                              ._pocketMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavingsPocketsTableReferences(
                                db,
                                table,
                                p0,
                              ).pocketMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pocketId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pocketRecurringTemplatesRefs)
                        await $_getPrefetchedData<
                          PocketRow,
                          $SavingsPocketsTable,
                          PocketRecurringRow
                        >(
                          currentTable: table,
                          referencedTable: $$SavingsPocketsTableReferences
                              ._pocketRecurringTemplatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavingsPocketsTableReferences(
                                db,
                                table,
                                p0,
                              ).pocketRecurringTemplatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pocketId == item.id,
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

typedef $$SavingsPocketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsPocketsTable,
      PocketRow,
      $$SavingsPocketsTableFilterComposer,
      $$SavingsPocketsTableOrderingComposer,
      $$SavingsPocketsTableAnnotationComposer,
      $$SavingsPocketsTableCreateCompanionBuilder,
      $$SavingsPocketsTableUpdateCompanionBuilder,
      (PocketRow, $$SavingsPocketsTableReferences),
      PocketRow,
      PrefetchHooks Function({
        bool pocketMovementsRefs,
        bool pocketRecurringTemplatesRefs,
      })
    >;
typedef $$PocketMovementsTableCreateCompanionBuilder =
    PocketMovementsCompanion Function({
      Value<int> id,
      required int pocketId,
      required int amountCents,
      required DateTime date,
      Value<String?> note,
      Value<int?> recurringPocketTemplateId,
      Value<int?> relatedTransactionId,
      Value<DateTime> createdAt,
    });
typedef $$PocketMovementsTableUpdateCompanionBuilder =
    PocketMovementsCompanion Function({
      Value<int> id,
      Value<int> pocketId,
      Value<int> amountCents,
      Value<DateTime> date,
      Value<String?> note,
      Value<int?> recurringPocketTemplateId,
      Value<int?> relatedTransactionId,
      Value<DateTime> createdAt,
    });

final class $$PocketMovementsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PocketMovementsTable,
          PocketMovementRow
        > {
  $$PocketMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavingsPocketsTable _pocketIdTable(_$AppDatabase db) => db
      .savingsPockets
      .createAlias('pocket_movements__pocket_id__savings_pockets__id');

  $$SavingsPocketsTableProcessedTableManager get pocketId {
    final $_column = $_itemColumn<int>('pocket_id')!;

    final manager = $$SavingsPocketsTableTableManager(
      $_db,
      $_db.savingsPockets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pocketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PocketMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $PocketMovementsTable> {
  $$PocketMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurringPocketTemplateId => $composableBuilder(
    column: $table.recurringPocketTemplateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relatedTransactionId => $composableBuilder(
    column: $table.relatedTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SavingsPocketsTableFilterComposer get pocketId {
    final $$SavingsPocketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pocketId,
      referencedTable: $db.savingsPockets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingsPocketsTableFilterComposer(
            $db: $db,
            $table: $db.savingsPockets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PocketMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $PocketMovementsTable> {
  $$PocketMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurringPocketTemplateId => $composableBuilder(
    column: $table.recurringPocketTemplateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relatedTransactionId => $composableBuilder(
    column: $table.relatedTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavingsPocketsTableOrderingComposer get pocketId {
    final $$SavingsPocketsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pocketId,
      referencedTable: $db.savingsPockets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingsPocketsTableOrderingComposer(
            $db: $db,
            $table: $db.savingsPockets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PocketMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PocketMovementsTable> {
  $$PocketMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get recurringPocketTemplateId => $composableBuilder(
    column: $table.recurringPocketTemplateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get relatedTransactionId => $composableBuilder(
    column: $table.relatedTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SavingsPocketsTableAnnotationComposer get pocketId {
    final $$SavingsPocketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pocketId,
      referencedTable: $db.savingsPockets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingsPocketsTableAnnotationComposer(
            $db: $db,
            $table: $db.savingsPockets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PocketMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PocketMovementsTable,
          PocketMovementRow,
          $$PocketMovementsTableFilterComposer,
          $$PocketMovementsTableOrderingComposer,
          $$PocketMovementsTableAnnotationComposer,
          $$PocketMovementsTableCreateCompanionBuilder,
          $$PocketMovementsTableUpdateCompanionBuilder,
          (PocketMovementRow, $$PocketMovementsTableReferences),
          PocketMovementRow,
          PrefetchHooks Function({bool pocketId})
        > {
  $$PocketMovementsTableTableManager(
    _$AppDatabase db,
    $PocketMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PocketMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PocketMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PocketMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pocketId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> recurringPocketTemplateId = const Value.absent(),
                Value<int?> relatedTransactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PocketMovementsCompanion(
                id: id,
                pocketId: pocketId,
                amountCents: amountCents,
                date: date,
                note: note,
                recurringPocketTemplateId: recurringPocketTemplateId,
                relatedTransactionId: relatedTransactionId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pocketId,
                required int amountCents,
                required DateTime date,
                Value<String?> note = const Value.absent(),
                Value<int?> recurringPocketTemplateId = const Value.absent(),
                Value<int?> relatedTransactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PocketMovementsCompanion.insert(
                id: id,
                pocketId: pocketId,
                amountCents: amountCents,
                date: date,
                note: note,
                recurringPocketTemplateId: recurringPocketTemplateId,
                relatedTransactionId: relatedTransactionId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PocketMovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pocketId = false}) {
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
                    if (pocketId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pocketId,
                                referencedTable:
                                    $$PocketMovementsTableReferences
                                        ._pocketIdTable(db),
                                referencedColumn:
                                    $$PocketMovementsTableReferences
                                        ._pocketIdTable(db)
                                        .id,
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

typedef $$PocketMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PocketMovementsTable,
      PocketMovementRow,
      $$PocketMovementsTableFilterComposer,
      $$PocketMovementsTableOrderingComposer,
      $$PocketMovementsTableAnnotationComposer,
      $$PocketMovementsTableCreateCompanionBuilder,
      $$PocketMovementsTableUpdateCompanionBuilder,
      (PocketMovementRow, $$PocketMovementsTableReferences),
      PocketMovementRow,
      PrefetchHooks Function({bool pocketId})
    >;
typedef $$PocketRecurringTemplatesTableCreateCompanionBuilder =
    PocketRecurringTemplatesCompanion Function({
      Value<int> id,
      required int pocketId,
      required String name,
      required int amountCents,
      required int dayOfMonth,
      Value<int> everyNMonths,
      required String anchorYearMonth,
      Value<bool> active,
    });
typedef $$PocketRecurringTemplatesTableUpdateCompanionBuilder =
    PocketRecurringTemplatesCompanion Function({
      Value<int> id,
      Value<int> pocketId,
      Value<String> name,
      Value<int> amountCents,
      Value<int> dayOfMonth,
      Value<int> everyNMonths,
      Value<String> anchorYearMonth,
      Value<bool> active,
    });

final class $$PocketRecurringTemplatesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PocketRecurringTemplatesTable,
          PocketRecurringRow
        > {
  $$PocketRecurringTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavingsPocketsTable _pocketIdTable(_$AppDatabase db) =>
      db.savingsPockets.createAlias(
        'pocket_recurring_templates__pocket_id__savings_pockets__id',
      );

  $$SavingsPocketsTableProcessedTableManager get pocketId {
    final $_column = $_itemColumn<int>('pocket_id')!;

    final manager = $$SavingsPocketsTableTableManager(
      $_db,
      $_db.savingsPockets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pocketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PocketRecurringTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $PocketRecurringTemplatesTable> {
  $$PocketRecurringTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get everyNMonths => $composableBuilder(
    column: $table.everyNMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchorYearMonth => $composableBuilder(
    column: $table.anchorYearMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$SavingsPocketsTableFilterComposer get pocketId {
    final $$SavingsPocketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pocketId,
      referencedTable: $db.savingsPockets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingsPocketsTableFilterComposer(
            $db: $db,
            $table: $db.savingsPockets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PocketRecurringTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PocketRecurringTemplatesTable> {
  $$PocketRecurringTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get everyNMonths => $composableBuilder(
    column: $table.everyNMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorYearMonth => $composableBuilder(
    column: $table.anchorYearMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavingsPocketsTableOrderingComposer get pocketId {
    final $$SavingsPocketsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pocketId,
      referencedTable: $db.savingsPockets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingsPocketsTableOrderingComposer(
            $db: $db,
            $table: $db.savingsPockets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PocketRecurringTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PocketRecurringTemplatesTable> {
  $$PocketRecurringTemplatesTableAnnotationComposer({
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

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get everyNMonths => $composableBuilder(
    column: $table.everyNMonths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get anchorYearMonth => $composableBuilder(
    column: $table.anchorYearMonth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$SavingsPocketsTableAnnotationComposer get pocketId {
    final $$SavingsPocketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pocketId,
      referencedTable: $db.savingsPockets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingsPocketsTableAnnotationComposer(
            $db: $db,
            $table: $db.savingsPockets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PocketRecurringTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PocketRecurringTemplatesTable,
          PocketRecurringRow,
          $$PocketRecurringTemplatesTableFilterComposer,
          $$PocketRecurringTemplatesTableOrderingComposer,
          $$PocketRecurringTemplatesTableAnnotationComposer,
          $$PocketRecurringTemplatesTableCreateCompanionBuilder,
          $$PocketRecurringTemplatesTableUpdateCompanionBuilder,
          (PocketRecurringRow, $$PocketRecurringTemplatesTableReferences),
          PocketRecurringRow,
          PrefetchHooks Function({bool pocketId})
        > {
  $$PocketRecurringTemplatesTableTableManager(
    _$AppDatabase db,
    $PocketRecurringTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PocketRecurringTemplatesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PocketRecurringTemplatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PocketRecurringTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pocketId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int> dayOfMonth = const Value.absent(),
                Value<int> everyNMonths = const Value.absent(),
                Value<String> anchorYearMonth = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => PocketRecurringTemplatesCompanion(
                id: id,
                pocketId: pocketId,
                name: name,
                amountCents: amountCents,
                dayOfMonth: dayOfMonth,
                everyNMonths: everyNMonths,
                anchorYearMonth: anchorYearMonth,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pocketId,
                required String name,
                required int amountCents,
                required int dayOfMonth,
                Value<int> everyNMonths = const Value.absent(),
                required String anchorYearMonth,
                Value<bool> active = const Value.absent(),
              }) => PocketRecurringTemplatesCompanion.insert(
                id: id,
                pocketId: pocketId,
                name: name,
                amountCents: amountCents,
                dayOfMonth: dayOfMonth,
                everyNMonths: everyNMonths,
                anchorYearMonth: anchorYearMonth,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PocketRecurringTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pocketId = false}) {
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
                    if (pocketId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pocketId,
                                referencedTable:
                                    $$PocketRecurringTemplatesTableReferences
                                        ._pocketIdTable(db),
                                referencedColumn:
                                    $$PocketRecurringTemplatesTableReferences
                                        ._pocketIdTable(db)
                                        .id,
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

typedef $$PocketRecurringTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PocketRecurringTemplatesTable,
      PocketRecurringRow,
      $$PocketRecurringTemplatesTableFilterComposer,
      $$PocketRecurringTemplatesTableOrderingComposer,
      $$PocketRecurringTemplatesTableAnnotationComposer,
      $$PocketRecurringTemplatesTableCreateCompanionBuilder,
      $$PocketRecurringTemplatesTableUpdateCompanionBuilder,
      (PocketRecurringRow, $$PocketRecurringTemplatesTableReferences),
      PocketRecurringRow,
      PrefetchHooks Function({bool pocketId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<double?> defaultTreatRate,
      Value<bool> showPocketsInTotal,
      Value<String?> dismissedTreatSweepYearMonth,
      Value<int?> monthStartDay,
      Value<bool> hasSeenTutorial,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<double?> defaultTreatRate,
      Value<bool> showPocketsInTotal,
      Value<String?> dismissedTreatSweepYearMonth,
      Value<int?> monthStartDay,
      Value<bool> hasSeenTutorial,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultTreatRate => $composableBuilder(
    column: $table.defaultTreatRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showPocketsInTotal => $composableBuilder(
    column: $table.showPocketsInTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dismissedTreatSweepYearMonth => $composableBuilder(
    column: $table.dismissedTreatSweepYearMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthStartDay => $composableBuilder(
    column: $table.monthStartDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasSeenTutorial => $composableBuilder(
    column: $table.hasSeenTutorial,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultTreatRate => $composableBuilder(
    column: $table.defaultTreatRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showPocketsInTotal => $composableBuilder(
    column: $table.showPocketsInTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dismissedTreatSweepYearMonth =>
      $composableBuilder(
        column: $table.dismissedTreatSweepYearMonth,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get monthStartDay => $composableBuilder(
    column: $table.monthStartDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasSeenTutorial => $composableBuilder(
    column: $table.hasSeenTutorial,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get defaultTreatRate => $composableBuilder(
    column: $table.defaultTreatRate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showPocketsInTotal => $composableBuilder(
    column: $table.showPocketsInTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dismissedTreatSweepYearMonth =>
      $composableBuilder(
        column: $table.dismissedTreatSweepYearMonth,
        builder: (column) => column,
      );

  GeneratedColumn<int> get monthStartDay => $composableBuilder(
    column: $table.monthStartDay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasSeenTutorial => $composableBuilder(
    column: $table.hasSeenTutorial,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingsRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double?> defaultTreatRate = const Value.absent(),
                Value<bool> showPocketsInTotal = const Value.absent(),
                Value<String?> dismissedTreatSweepYearMonth =
                    const Value.absent(),
                Value<int?> monthStartDay = const Value.absent(),
                Value<bool> hasSeenTutorial = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                defaultTreatRate: defaultTreatRate,
                showPocketsInTotal: showPocketsInTotal,
                dismissedTreatSweepYearMonth: dismissedTreatSweepYearMonth,
                monthStartDay: monthStartDay,
                hasSeenTutorial: hasSeenTutorial,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double?> defaultTreatRate = const Value.absent(),
                Value<bool> showPocketsInTotal = const Value.absent(),
                Value<String?> dismissedTreatSweepYearMonth =
                    const Value.absent(),
                Value<int?> monthStartDay = const Value.absent(),
                Value<bool> hasSeenTutorial = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                defaultTreatRate: defaultTreatRate,
                showPocketsInTotal: showPocketsInTotal,
                dismissedTreatSweepYearMonth: dismissedTreatSweepYearMonth,
                monthStartDay: monthStartDay,
                hasSeenTutorial: hasSeenTutorial,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingsRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$RecurringTemplatesTableTableManager get recurringTemplates =>
      $$RecurringTemplatesTableTableManager(_db, _db.recurringTemplates);
  $$MonthsTableTableManager get months =>
      $$MonthsTableTableManager(_db, _db.months);
  $$QuickActionsTableTableManager get quickActions =>
      $$QuickActionsTableTableManager(_db, _db.quickActions);
  $$SavingsPocketsTableTableManager get savingsPockets =>
      $$SavingsPocketsTableTableManager(_db, _db.savingsPockets);
  $$PocketMovementsTableTableManager get pocketMovements =>
      $$PocketMovementsTableTableManager(_db, _db.pocketMovements);
  $$PocketRecurringTemplatesTableTableManager get pocketRecurringTemplates =>
      $$PocketRecurringTemplatesTableTableManager(
        _db,
        _db.pocketRecurringTemplates,
      );
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
