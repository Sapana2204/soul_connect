// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
      'item_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _itemNameMeta =
      const VerificationMeta('itemName');
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
      'item_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _itemCodeMeta =
      const VerificationMeta('itemCode');
  @override
  late final GeneratedColumn<String> itemCode = GeneratedColumn<String>(
      'item_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastPurchaseRateMeta =
      const VerificationMeta('lastPurchaseRate');
  @override
  late final GeneratedColumn<double> lastPurchaseRate = GeneratedColumn<double>(
      'last_purchase_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lastMRPMeta =
      const VerificationMeta('lastMRP');
  @override
  late final GeneratedColumn<double> lastMRP = GeneratedColumn<double>(
      'last_m_r_p', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _taxPerMeta = const VerificationMeta('taxPer');
  @override
  late final GeneratedColumn<String> taxPer = GeneratedColumn<String>(
      'tax_per', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<int> unitId = GeneratedColumn<int>(
      'unit_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [itemId, itemName, itemCode, lastPurchaseRate, lastMRP, taxPer, unitId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<Item> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta));
    }
    if (data.containsKey('item_code')) {
      context.handle(_itemCodeMeta,
          itemCode.isAcceptableOrUnknown(data['item_code']!, _itemCodeMeta));
    }
    if (data.containsKey('last_purchase_rate')) {
      context.handle(
          _lastPurchaseRateMeta,
          lastPurchaseRate.isAcceptableOrUnknown(
              data['last_purchase_rate']!, _lastPurchaseRateMeta));
    }
    if (data.containsKey('last_m_r_p')) {
      context.handle(_lastMRPMeta,
          lastMRP.isAcceptableOrUnknown(data['last_m_r_p']!, _lastMRPMeta));
    }
    if (data.containsKey('tax_per')) {
      context.handle(_taxPerMeta,
          taxPer.isAcceptableOrUnknown(data['tax_per']!, _taxPerMeta));
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta,
          unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_id'])!,
      itemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_name']),
      itemCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_code']),
      lastPurchaseRate: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}last_purchase_rate']),
      lastMRP: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}last_m_r_p']),
      taxPer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tax_per']),
      unitId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_id']),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final int itemId;
  final String? itemName;
  final String? itemCode;
  final double? lastPurchaseRate;
  final double? lastMRP;
  final String? taxPer;
  final int? unitId;
  const Item(
      {required this.itemId,
      this.itemName,
      this.itemCode,
      this.lastPurchaseRate,
      this.lastMRP,
      this.taxPer,
      this.unitId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<int>(itemId);
    if (!nullToAbsent || itemName != null) {
      map['item_name'] = Variable<String>(itemName);
    }
    if (!nullToAbsent || itemCode != null) {
      map['item_code'] = Variable<String>(itemCode);
    }
    if (!nullToAbsent || lastPurchaseRate != null) {
      map['last_purchase_rate'] = Variable<double>(lastPurchaseRate);
    }
    if (!nullToAbsent || lastMRP != null) {
      map['last_m_r_p'] = Variable<double>(lastMRP);
    }
    if (!nullToAbsent || taxPer != null) {
      map['tax_per'] = Variable<String>(taxPer);
    }
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<int>(unitId);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      itemId: Value(itemId),
      itemName: itemName == null && nullToAbsent
          ? const Value.absent()
          : Value(itemName),
      itemCode: itemCode == null && nullToAbsent
          ? const Value.absent()
          : Value(itemCode),
      lastPurchaseRate: lastPurchaseRate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPurchaseRate),
      lastMRP: lastMRP == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMRP),
      taxPer:
          taxPer == null && nullToAbsent ? const Value.absent() : Value(taxPer),
      unitId:
          unitId == null && nullToAbsent ? const Value.absent() : Value(unitId),
    );
  }

  factory Item.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      itemId: serializer.fromJson<int>(json['itemId']),
      itemName: serializer.fromJson<String?>(json['itemName']),
      itemCode: serializer.fromJson<String?>(json['itemCode']),
      lastPurchaseRate: serializer.fromJson<double?>(json['lastPurchaseRate']),
      lastMRP: serializer.fromJson<double?>(json['lastMRP']),
      taxPer: serializer.fromJson<String?>(json['taxPer']),
      unitId: serializer.fromJson<int?>(json['unitId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<int>(itemId),
      'itemName': serializer.toJson<String?>(itemName),
      'itemCode': serializer.toJson<String?>(itemCode),
      'lastPurchaseRate': serializer.toJson<double?>(lastPurchaseRate),
      'lastMRP': serializer.toJson<double?>(lastMRP),
      'taxPer': serializer.toJson<String?>(taxPer),
      'unitId': serializer.toJson<int?>(unitId),
    };
  }

  Item copyWith(
          {int? itemId,
          Value<String?> itemName = const Value.absent(),
          Value<String?> itemCode = const Value.absent(),
          Value<double?> lastPurchaseRate = const Value.absent(),
          Value<double?> lastMRP = const Value.absent(),
          Value<String?> taxPer = const Value.absent(),
          Value<int?> unitId = const Value.absent()}) =>
      Item(
        itemId: itemId ?? this.itemId,
        itemName: itemName.present ? itemName.value : this.itemName,
        itemCode: itemCode.present ? itemCode.value : this.itemCode,
        lastPurchaseRate: lastPurchaseRate.present
            ? lastPurchaseRate.value
            : this.lastPurchaseRate,
        lastMRP: lastMRP.present ? lastMRP.value : this.lastMRP,
        taxPer: taxPer.present ? taxPer.value : this.taxPer,
        unitId: unitId.present ? unitId.value : this.unitId,
      );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      itemCode: data.itemCode.present ? data.itemCode.value : this.itemCode,
      lastPurchaseRate: data.lastPurchaseRate.present
          ? data.lastPurchaseRate.value
          : this.lastPurchaseRate,
      lastMRP: data.lastMRP.present ? data.lastMRP.value : this.lastMRP,
      taxPer: data.taxPer.present ? data.taxPer.value : this.taxPer,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemCode: $itemCode, ')
          ..write('lastPurchaseRate: $lastPurchaseRate, ')
          ..write('lastMRP: $lastMRP, ')
          ..write('taxPer: $taxPer, ')
          ..write('unitId: $unitId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      itemId, itemName, itemCode, lastPurchaseRate, lastMRP, taxPer, unitId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.itemId == this.itemId &&
          other.itemName == this.itemName &&
          other.itemCode == this.itemCode &&
          other.lastPurchaseRate == this.lastPurchaseRate &&
          other.lastMRP == this.lastMRP &&
          other.taxPer == this.taxPer &&
          other.unitId == this.unitId);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> itemId;
  final Value<String?> itemName;
  final Value<String?> itemCode;
  final Value<double?> lastPurchaseRate;
  final Value<double?> lastMRP;
  final Value<String?> taxPer;
  final Value<int?> unitId;
  const ItemsCompanion({
    this.itemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemCode = const Value.absent(),
    this.lastPurchaseRate = const Value.absent(),
    this.lastMRP = const Value.absent(),
    this.taxPer = const Value.absent(),
    this.unitId = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.itemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemCode = const Value.absent(),
    this.lastPurchaseRate = const Value.absent(),
    this.lastMRP = const Value.absent(),
    this.taxPer = const Value.absent(),
    this.unitId = const Value.absent(),
  });
  static Insertable<Item> custom({
    Expression<int>? itemId,
    Expression<String>? itemName,
    Expression<String>? itemCode,
    Expression<double>? lastPurchaseRate,
    Expression<double>? lastMRP,
    Expression<String>? taxPer,
    Expression<int>? unitId,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (itemName != null) 'item_name': itemName,
      if (itemCode != null) 'item_code': itemCode,
      if (lastPurchaseRate != null) 'last_purchase_rate': lastPurchaseRate,
      if (lastMRP != null) 'last_m_r_p': lastMRP,
      if (taxPer != null) 'tax_per': taxPer,
      if (unitId != null) 'unit_id': unitId,
    });
  }

  ItemsCompanion copyWith(
      {Value<int>? itemId,
      Value<String?>? itemName,
      Value<String?>? itemCode,
      Value<double?>? lastPurchaseRate,
      Value<double?>? lastMRP,
      Value<String?>? taxPer,
      Value<int?>? unitId}) {
    return ItemsCompanion(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemCode: itemCode ?? this.itemCode,
      lastPurchaseRate: lastPurchaseRate ?? this.lastPurchaseRate,
      lastMRP: lastMRP ?? this.lastMRP,
      taxPer: taxPer ?? this.taxPer,
      unitId: unitId ?? this.unitId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (itemCode.present) {
      map['item_code'] = Variable<String>(itemCode.value);
    }
    if (lastPurchaseRate.present) {
      map['last_purchase_rate'] = Variable<double>(lastPurchaseRate.value);
    }
    if (lastMRP.present) {
      map['last_m_r_p'] = Variable<double>(lastMRP.value);
    }
    if (taxPer.present) {
      map['tax_per'] = Variable<String>(taxPer.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<int>(unitId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemCode: $itemCode, ')
          ..write('lastPurchaseRate: $lastPurchaseRate, ')
          ..write('lastMRP: $lastMRP, ')
          ..write('taxPer: $taxPer, ')
          ..write('unitId: $unitId')
          ..write(')'))
        .toString();
  }
}

class $RateTypesTable extends RateTypes
    with TableInfo<$RateTypesTable, RateType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RateTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rateTypeIdMeta =
      const VerificationMeta('rateTypeId');
  @override
  late final GeneratedColumn<int> rateTypeId = GeneratedColumn<int>(
      'rate_type_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rateTypeMeta =
      const VerificationMeta('rateType');
  @override
  late final GeneratedColumn<String> rateType = GeneratedColumn<String>(
      'rate_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rateTypeDisplayMeta =
      const VerificationMeta('rateTypeDisplay');
  @override
  late final GeneratedColumn<String> rateTypeDisplay = GeneratedColumn<String>(
      'rate_type_display', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [rateTypeId, rateType, rateTypeDisplay];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rate_types';
  @override
  VerificationContext validateIntegrity(Insertable<RateType> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('rate_type_id')) {
      context.handle(
          _rateTypeIdMeta,
          rateTypeId.isAcceptableOrUnknown(
              data['rate_type_id']!, _rateTypeIdMeta));
    }
    if (data.containsKey('rate_type')) {
      context.handle(_rateTypeMeta,
          rateType.isAcceptableOrUnknown(data['rate_type']!, _rateTypeMeta));
    }
    if (data.containsKey('rate_type_display')) {
      context.handle(
          _rateTypeDisplayMeta,
          rateTypeDisplay.isAcceptableOrUnknown(
              data['rate_type_display']!, _rateTypeDisplayMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rateTypeId};
  @override
  RateType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RateType(
      rateTypeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rate_type_id'])!,
      rateType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rate_type']),
      rateTypeDisplay: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}rate_type_display']),
    );
  }

  @override
  $RateTypesTable createAlias(String alias) {
    return $RateTypesTable(attachedDatabase, alias);
  }
}

class RateType extends DataClass implements Insertable<RateType> {
  final int rateTypeId;
  final String? rateType;
  final String? rateTypeDisplay;
  const RateType(
      {required this.rateTypeId, this.rateType, this.rateTypeDisplay});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['rate_type_id'] = Variable<int>(rateTypeId);
    if (!nullToAbsent || rateType != null) {
      map['rate_type'] = Variable<String>(rateType);
    }
    if (!nullToAbsent || rateTypeDisplay != null) {
      map['rate_type_display'] = Variable<String>(rateTypeDisplay);
    }
    return map;
  }

  RateTypesCompanion toCompanion(bool nullToAbsent) {
    return RateTypesCompanion(
      rateTypeId: Value(rateTypeId),
      rateType: rateType == null && nullToAbsent
          ? const Value.absent()
          : Value(rateType),
      rateTypeDisplay: rateTypeDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(rateTypeDisplay),
    );
  }

  factory RateType.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RateType(
      rateTypeId: serializer.fromJson<int>(json['rateTypeId']),
      rateType: serializer.fromJson<String?>(json['rateType']),
      rateTypeDisplay: serializer.fromJson<String?>(json['rateTypeDisplay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rateTypeId': serializer.toJson<int>(rateTypeId),
      'rateType': serializer.toJson<String?>(rateType),
      'rateTypeDisplay': serializer.toJson<String?>(rateTypeDisplay),
    };
  }

  RateType copyWith(
          {int? rateTypeId,
          Value<String?> rateType = const Value.absent(),
          Value<String?> rateTypeDisplay = const Value.absent()}) =>
      RateType(
        rateTypeId: rateTypeId ?? this.rateTypeId,
        rateType: rateType.present ? rateType.value : this.rateType,
        rateTypeDisplay: rateTypeDisplay.present
            ? rateTypeDisplay.value
            : this.rateTypeDisplay,
      );
  RateType copyWithCompanion(RateTypesCompanion data) {
    return RateType(
      rateTypeId:
          data.rateTypeId.present ? data.rateTypeId.value : this.rateTypeId,
      rateType: data.rateType.present ? data.rateType.value : this.rateType,
      rateTypeDisplay: data.rateTypeDisplay.present
          ? data.rateTypeDisplay.value
          : this.rateTypeDisplay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RateType(')
          ..write('rateTypeId: $rateTypeId, ')
          ..write('rateType: $rateType, ')
          ..write('rateTypeDisplay: $rateTypeDisplay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rateTypeId, rateType, rateTypeDisplay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RateType &&
          other.rateTypeId == this.rateTypeId &&
          other.rateType == this.rateType &&
          other.rateTypeDisplay == this.rateTypeDisplay);
}

class RateTypesCompanion extends UpdateCompanion<RateType> {
  final Value<int> rateTypeId;
  final Value<String?> rateType;
  final Value<String?> rateTypeDisplay;
  const RateTypesCompanion({
    this.rateTypeId = const Value.absent(),
    this.rateType = const Value.absent(),
    this.rateTypeDisplay = const Value.absent(),
  });
  RateTypesCompanion.insert({
    this.rateTypeId = const Value.absent(),
    this.rateType = const Value.absent(),
    this.rateTypeDisplay = const Value.absent(),
  });
  static Insertable<RateType> custom({
    Expression<int>? rateTypeId,
    Expression<String>? rateType,
    Expression<String>? rateTypeDisplay,
  }) {
    return RawValuesInsertable({
      if (rateTypeId != null) 'rate_type_id': rateTypeId,
      if (rateType != null) 'rate_type': rateType,
      if (rateTypeDisplay != null) 'rate_type_display': rateTypeDisplay,
    });
  }

  RateTypesCompanion copyWith(
      {Value<int>? rateTypeId,
      Value<String?>? rateType,
      Value<String?>? rateTypeDisplay}) {
    return RateTypesCompanion(
      rateTypeId: rateTypeId ?? this.rateTypeId,
      rateType: rateType ?? this.rateType,
      rateTypeDisplay: rateTypeDisplay ?? this.rateTypeDisplay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rateTypeId.present) {
      map['rate_type_id'] = Variable<int>(rateTypeId.value);
    }
    if (rateType.present) {
      map['rate_type'] = Variable<String>(rateType.value);
    }
    if (rateTypeDisplay.present) {
      map['rate_type_display'] = Variable<String>(rateTypeDisplay.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RateTypesCompanion(')
          ..write('rateTypeId: $rateTypeId, ')
          ..write('rateType: $rateType, ')
          ..write('rateTypeDisplay: $rateTypeDisplay')
          ..write(')'))
        .toString();
  }
}

class $BillTypesTable extends BillTypes
    with TableInfo<$BillTypesTable, BillType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _billTypeIdMeta =
      const VerificationMeta('billTypeId');
  @override
  late final GeneratedColumn<int> billTypeId = GeneratedColumn<int>(
      'bill_type_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _billTypeMeta =
      const VerificationMeta('billType');
  @override
  late final GeneratedColumn<String> billType = GeneratedColumn<String>(
      'bill_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prefixMeta = const VerificationMeta('prefix');
  @override
  late final GeneratedColumn<String> prefix = GeneratedColumn<String>(
      'prefix', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _includeFinancialYearMeta =
      const VerificationMeta('includeFinancialYear');
  @override
  late final GeneratedColumn<bool> includeFinancialYear = GeneratedColumn<bool>(
      'include_financial_year', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("include_financial_year" IN (0, 1))'));
  static const VerificationMeta _salesQuotationMeta =
      const VerificationMeta('salesQuotation');
  @override
  late final GeneratedColumn<String> salesQuotation = GeneratedColumn<String>(
      'sales_quotation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [billTypeId, billType, prefix, includeFinancialYear, salesQuotation];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bill_types';
  @override
  VerificationContext validateIntegrity(Insertable<BillType> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bill_type_id')) {
      context.handle(
          _billTypeIdMeta,
          billTypeId.isAcceptableOrUnknown(
              data['bill_type_id']!, _billTypeIdMeta));
    }
    if (data.containsKey('bill_type')) {
      context.handle(_billTypeMeta,
          billType.isAcceptableOrUnknown(data['bill_type']!, _billTypeMeta));
    }
    if (data.containsKey('prefix')) {
      context.handle(_prefixMeta,
          prefix.isAcceptableOrUnknown(data['prefix']!, _prefixMeta));
    }
    if (data.containsKey('include_financial_year')) {
      context.handle(
          _includeFinancialYearMeta,
          includeFinancialYear.isAcceptableOrUnknown(
              data['include_financial_year']!, _includeFinancialYearMeta));
    }
    if (data.containsKey('sales_quotation')) {
      context.handle(
          _salesQuotationMeta,
          salesQuotation.isAcceptableOrUnknown(
              data['sales_quotation']!, _salesQuotationMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {billTypeId};
  @override
  BillType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillType(
      billTypeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bill_type_id'])!,
      billType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bill_type']),
      prefix: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prefix']),
      includeFinancialYear: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}include_financial_year']),
      salesQuotation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sales_quotation']),
    );
  }

  @override
  $BillTypesTable createAlias(String alias) {
    return $BillTypesTable(attachedDatabase, alias);
  }
}

class BillType extends DataClass implements Insertable<BillType> {
  final int billTypeId;
  final String? billType;
  final String? prefix;
  final bool? includeFinancialYear;
  final String? salesQuotation;
  const BillType(
      {required this.billTypeId,
      this.billType,
      this.prefix,
      this.includeFinancialYear,
      this.salesQuotation});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bill_type_id'] = Variable<int>(billTypeId);
    if (!nullToAbsent || billType != null) {
      map['bill_type'] = Variable<String>(billType);
    }
    if (!nullToAbsent || prefix != null) {
      map['prefix'] = Variable<String>(prefix);
    }
    if (!nullToAbsent || includeFinancialYear != null) {
      map['include_financial_year'] = Variable<bool>(includeFinancialYear);
    }
    if (!nullToAbsent || salesQuotation != null) {
      map['sales_quotation'] = Variable<String>(salesQuotation);
    }
    return map;
  }

  BillTypesCompanion toCompanion(bool nullToAbsent) {
    return BillTypesCompanion(
      billTypeId: Value(billTypeId),
      billType: billType == null && nullToAbsent
          ? const Value.absent()
          : Value(billType),
      prefix:
          prefix == null && nullToAbsent ? const Value.absent() : Value(prefix),
      includeFinancialYear: includeFinancialYear == null && nullToAbsent
          ? const Value.absent()
          : Value(includeFinancialYear),
      salesQuotation: salesQuotation == null && nullToAbsent
          ? const Value.absent()
          : Value(salesQuotation),
    );
  }

  factory BillType.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillType(
      billTypeId: serializer.fromJson<int>(json['billTypeId']),
      billType: serializer.fromJson<String?>(json['billType']),
      prefix: serializer.fromJson<String?>(json['prefix']),
      includeFinancialYear:
          serializer.fromJson<bool?>(json['includeFinancialYear']),
      salesQuotation: serializer.fromJson<String?>(json['salesQuotation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'billTypeId': serializer.toJson<int>(billTypeId),
      'billType': serializer.toJson<String?>(billType),
      'prefix': serializer.toJson<String?>(prefix),
      'includeFinancialYear': serializer.toJson<bool?>(includeFinancialYear),
      'salesQuotation': serializer.toJson<String?>(salesQuotation),
    };
  }

  BillType copyWith(
          {int? billTypeId,
          Value<String?> billType = const Value.absent(),
          Value<String?> prefix = const Value.absent(),
          Value<bool?> includeFinancialYear = const Value.absent(),
          Value<String?> salesQuotation = const Value.absent()}) =>
      BillType(
        billTypeId: billTypeId ?? this.billTypeId,
        billType: billType.present ? billType.value : this.billType,
        prefix: prefix.present ? prefix.value : this.prefix,
        includeFinancialYear: includeFinancialYear.present
            ? includeFinancialYear.value
            : this.includeFinancialYear,
        salesQuotation:
            salesQuotation.present ? salesQuotation.value : this.salesQuotation,
      );
  BillType copyWithCompanion(BillTypesCompanion data) {
    return BillType(
      billTypeId:
          data.billTypeId.present ? data.billTypeId.value : this.billTypeId,
      billType: data.billType.present ? data.billType.value : this.billType,
      prefix: data.prefix.present ? data.prefix.value : this.prefix,
      includeFinancialYear: data.includeFinancialYear.present
          ? data.includeFinancialYear.value
          : this.includeFinancialYear,
      salesQuotation: data.salesQuotation.present
          ? data.salesQuotation.value
          : this.salesQuotation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillType(')
          ..write('billTypeId: $billTypeId, ')
          ..write('billType: $billType, ')
          ..write('prefix: $prefix, ')
          ..write('includeFinancialYear: $includeFinancialYear, ')
          ..write('salesQuotation: $salesQuotation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      billTypeId, billType, prefix, includeFinancialYear, salesQuotation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillType &&
          other.billTypeId == this.billTypeId &&
          other.billType == this.billType &&
          other.prefix == this.prefix &&
          other.includeFinancialYear == this.includeFinancialYear &&
          other.salesQuotation == this.salesQuotation);
}

class BillTypesCompanion extends UpdateCompanion<BillType> {
  final Value<int> billTypeId;
  final Value<String?> billType;
  final Value<String?> prefix;
  final Value<bool?> includeFinancialYear;
  final Value<String?> salesQuotation;
  const BillTypesCompanion({
    this.billTypeId = const Value.absent(),
    this.billType = const Value.absent(),
    this.prefix = const Value.absent(),
    this.includeFinancialYear = const Value.absent(),
    this.salesQuotation = const Value.absent(),
  });
  BillTypesCompanion.insert({
    this.billTypeId = const Value.absent(),
    this.billType = const Value.absent(),
    this.prefix = const Value.absent(),
    this.includeFinancialYear = const Value.absent(),
    this.salesQuotation = const Value.absent(),
  });
  static Insertable<BillType> custom({
    Expression<int>? billTypeId,
    Expression<String>? billType,
    Expression<String>? prefix,
    Expression<bool>? includeFinancialYear,
    Expression<String>? salesQuotation,
  }) {
    return RawValuesInsertable({
      if (billTypeId != null) 'bill_type_id': billTypeId,
      if (billType != null) 'bill_type': billType,
      if (prefix != null) 'prefix': prefix,
      if (includeFinancialYear != null)
        'include_financial_year': includeFinancialYear,
      if (salesQuotation != null) 'sales_quotation': salesQuotation,
    });
  }

  BillTypesCompanion copyWith(
      {Value<int>? billTypeId,
      Value<String?>? billType,
      Value<String?>? prefix,
      Value<bool?>? includeFinancialYear,
      Value<String?>? salesQuotation}) {
    return BillTypesCompanion(
      billTypeId: billTypeId ?? this.billTypeId,
      billType: billType ?? this.billType,
      prefix: prefix ?? this.prefix,
      includeFinancialYear: includeFinancialYear ?? this.includeFinancialYear,
      salesQuotation: salesQuotation ?? this.salesQuotation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (billTypeId.present) {
      map['bill_type_id'] = Variable<int>(billTypeId.value);
    }
    if (billType.present) {
      map['bill_type'] = Variable<String>(billType.value);
    }
    if (prefix.present) {
      map['prefix'] = Variable<String>(prefix.value);
    }
    if (includeFinancialYear.present) {
      map['include_financial_year'] =
          Variable<bool>(includeFinancialYear.value);
    }
    if (salesQuotation.present) {
      map['sales_quotation'] = Variable<String>(salesQuotation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillTypesCompanion(')
          ..write('billTypeId: $billTypeId, ')
          ..write('billType: $billType, ')
          ..write('prefix: $prefix, ')
          ..write('includeFinancialYear: $includeFinancialYear, ')
          ..write('salesQuotation: $salesQuotation')
          ..write(')'))
        .toString();
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, Location> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<int> locationId = GeneratedColumn<int>(
      'location_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _locationNameMeta =
      const VerificationMeta('locationName');
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
      'location_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
      'created_by', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdOnMeta =
      const VerificationMeta('createdOn');
  @override
  late final GeneratedColumn<String> createdOn = GeneratedColumn<String>(
      'created_on', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<int> updatedBy = GeneratedColumn<int>(
      'updated_by', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _updatedOnMeta =
      const VerificationMeta('updatedOn');
  @override
  late final GeneratedColumn<String> updatedOn = GeneratedColumn<String>(
      'updated_on', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _misc1Meta = const VerificationMeta('misc1');
  @override
  late final GeneratedColumn<String> misc1 = GeneratedColumn<String>(
      'misc1', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _misc2Meta = const VerificationMeta('misc2');
  @override
  late final GeneratedColumn<String> misc2 = GeneratedColumn<String>(
      'misc2', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _misc3Meta = const VerificationMeta('misc3');
  @override
  late final GeneratedColumn<String> misc3 = GeneratedColumn<String>(
      'misc3', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _misc4Meta = const VerificationMeta('misc4');
  @override
  late final GeneratedColumn<String> misc4 = GeneratedColumn<String>(
      'misc4', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _misc5Meta = const VerificationMeta('misc5');
  @override
  late final GeneratedColumn<String> misc5 = GeneratedColumn<String>(
      'misc5', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<int> firmId = GeneratedColumn<int>(
      'firm_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _firmNameMeta =
      const VerificationMeta('firmName');
  @override
  late final GeneratedColumn<String> firmName = GeneratedColumn<String>(
      'firm_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        locationId,
        locationName,
        createdBy,
        createdOn,
        updatedBy,
        updatedOn,
        misc1,
        misc2,
        misc3,
        misc4,
        misc5,
        firmId,
        firmName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(Insertable<Location> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    }
    if (data.containsKey('location_name')) {
      context.handle(
          _locationNameMeta,
          locationName.isAcceptableOrUnknown(
              data['location_name']!, _locationNameMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_on')) {
      context.handle(_createdOnMeta,
          createdOn.isAcceptableOrUnknown(data['created_on']!, _createdOnMeta));
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    }
    if (data.containsKey('updated_on')) {
      context.handle(_updatedOnMeta,
          updatedOn.isAcceptableOrUnknown(data['updated_on']!, _updatedOnMeta));
    }
    if (data.containsKey('misc1')) {
      context.handle(
          _misc1Meta, misc1.isAcceptableOrUnknown(data['misc1']!, _misc1Meta));
    }
    if (data.containsKey('misc2')) {
      context.handle(
          _misc2Meta, misc2.isAcceptableOrUnknown(data['misc2']!, _misc2Meta));
    }
    if (data.containsKey('misc3')) {
      context.handle(
          _misc3Meta, misc3.isAcceptableOrUnknown(data['misc3']!, _misc3Meta));
    }
    if (data.containsKey('misc4')) {
      context.handle(
          _misc4Meta, misc4.isAcceptableOrUnknown(data['misc4']!, _misc4Meta));
    }
    if (data.containsKey('misc5')) {
      context.handle(
          _misc5Meta, misc5.isAcceptableOrUnknown(data['misc5']!, _misc5Meta));
    }
    if (data.containsKey('firm_id')) {
      context.handle(_firmIdMeta,
          firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta));
    }
    if (data.containsKey('firm_name')) {
      context.handle(_firmNameMeta,
          firmName.isAcceptableOrUnknown(data['firm_name']!, _firmNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {locationId};
  @override
  Location map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Location(
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}location_id'])!,
      locationName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_name']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_by']),
      createdOn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_on']),
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_by']),
      updatedOn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_on']),
      misc1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}misc1']),
      misc2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}misc2']),
      misc3: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}misc3']),
      misc4: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}misc4']),
      misc5: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}misc5']),
      firmId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}firm_id']),
      firmName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firm_name']),
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }
}

class Location extends DataClass implements Insertable<Location> {
  final int locationId;
  final String? locationName;
  final int? createdBy;
  final String? createdOn;
  final int? updatedBy;
  final String? updatedOn;
  final String? misc1;
  final String? misc2;
  final String? misc3;
  final String? misc4;
  final String? misc5;
  final int? firmId;
  final String? firmName;
  const Location(
      {required this.locationId,
      this.locationName,
      this.createdBy,
      this.createdOn,
      this.updatedBy,
      this.updatedOn,
      this.misc1,
      this.misc2,
      this.misc3,
      this.misc4,
      this.misc5,
      this.firmId,
      this.firmName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['location_id'] = Variable<int>(locationId);
    if (!nullToAbsent || locationName != null) {
      map['location_name'] = Variable<String>(locationName);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<int>(createdBy);
    }
    if (!nullToAbsent || createdOn != null) {
      map['created_on'] = Variable<String>(createdOn);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<int>(updatedBy);
    }
    if (!nullToAbsent || updatedOn != null) {
      map['updated_on'] = Variable<String>(updatedOn);
    }
    if (!nullToAbsent || misc1 != null) {
      map['misc1'] = Variable<String>(misc1);
    }
    if (!nullToAbsent || misc2 != null) {
      map['misc2'] = Variable<String>(misc2);
    }
    if (!nullToAbsent || misc3 != null) {
      map['misc3'] = Variable<String>(misc3);
    }
    if (!nullToAbsent || misc4 != null) {
      map['misc4'] = Variable<String>(misc4);
    }
    if (!nullToAbsent || misc5 != null) {
      map['misc5'] = Variable<String>(misc5);
    }
    if (!nullToAbsent || firmId != null) {
      map['firm_id'] = Variable<int>(firmId);
    }
    if (!nullToAbsent || firmName != null) {
      map['firm_name'] = Variable<String>(firmName);
    }
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      locationId: Value(locationId),
      locationName: locationName == null && nullToAbsent
          ? const Value.absent()
          : Value(locationName),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdOn: createdOn == null && nullToAbsent
          ? const Value.absent()
          : Value(createdOn),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      updatedOn: updatedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedOn),
      misc1:
          misc1 == null && nullToAbsent ? const Value.absent() : Value(misc1),
      misc2:
          misc2 == null && nullToAbsent ? const Value.absent() : Value(misc2),
      misc3:
          misc3 == null && nullToAbsent ? const Value.absent() : Value(misc3),
      misc4:
          misc4 == null && nullToAbsent ? const Value.absent() : Value(misc4),
      misc5:
          misc5 == null && nullToAbsent ? const Value.absent() : Value(misc5),
      firmId:
          firmId == null && nullToAbsent ? const Value.absent() : Value(firmId),
      firmName: firmName == null && nullToAbsent
          ? const Value.absent()
          : Value(firmName),
    );
  }

  factory Location.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Location(
      locationId: serializer.fromJson<int>(json['locationId']),
      locationName: serializer.fromJson<String?>(json['locationName']),
      createdBy: serializer.fromJson<int?>(json['createdBy']),
      createdOn: serializer.fromJson<String?>(json['createdOn']),
      updatedBy: serializer.fromJson<int?>(json['updatedBy']),
      updatedOn: serializer.fromJson<String?>(json['updatedOn']),
      misc1: serializer.fromJson<String?>(json['misc1']),
      misc2: serializer.fromJson<String?>(json['misc2']),
      misc3: serializer.fromJson<String?>(json['misc3']),
      misc4: serializer.fromJson<String?>(json['misc4']),
      misc5: serializer.fromJson<String?>(json['misc5']),
      firmId: serializer.fromJson<int?>(json['firmId']),
      firmName: serializer.fromJson<String?>(json['firmName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'locationId': serializer.toJson<int>(locationId),
      'locationName': serializer.toJson<String?>(locationName),
      'createdBy': serializer.toJson<int?>(createdBy),
      'createdOn': serializer.toJson<String?>(createdOn),
      'updatedBy': serializer.toJson<int?>(updatedBy),
      'updatedOn': serializer.toJson<String?>(updatedOn),
      'misc1': serializer.toJson<String?>(misc1),
      'misc2': serializer.toJson<String?>(misc2),
      'misc3': serializer.toJson<String?>(misc3),
      'misc4': serializer.toJson<String?>(misc4),
      'misc5': serializer.toJson<String?>(misc5),
      'firmId': serializer.toJson<int?>(firmId),
      'firmName': serializer.toJson<String?>(firmName),
    };
  }

  Location copyWith(
          {int? locationId,
          Value<String?> locationName = const Value.absent(),
          Value<int?> createdBy = const Value.absent(),
          Value<String?> createdOn = const Value.absent(),
          Value<int?> updatedBy = const Value.absent(),
          Value<String?> updatedOn = const Value.absent(),
          Value<String?> misc1 = const Value.absent(),
          Value<String?> misc2 = const Value.absent(),
          Value<String?> misc3 = const Value.absent(),
          Value<String?> misc4 = const Value.absent(),
          Value<String?> misc5 = const Value.absent(),
          Value<int?> firmId = const Value.absent(),
          Value<String?> firmName = const Value.absent()}) =>
      Location(
        locationId: locationId ?? this.locationId,
        locationName:
            locationName.present ? locationName.value : this.locationName,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        createdOn: createdOn.present ? createdOn.value : this.createdOn,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        updatedOn: updatedOn.present ? updatedOn.value : this.updatedOn,
        misc1: misc1.present ? misc1.value : this.misc1,
        misc2: misc2.present ? misc2.value : this.misc2,
        misc3: misc3.present ? misc3.value : this.misc3,
        misc4: misc4.present ? misc4.value : this.misc4,
        misc5: misc5.present ? misc5.value : this.misc5,
        firmId: firmId.present ? firmId.value : this.firmId,
        firmName: firmName.present ? firmName.value : this.firmName,
      );
  Location copyWithCompanion(LocationsCompanion data) {
    return Location(
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdOn: data.createdOn.present ? data.createdOn.value : this.createdOn,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      updatedOn: data.updatedOn.present ? data.updatedOn.value : this.updatedOn,
      misc1: data.misc1.present ? data.misc1.value : this.misc1,
      misc2: data.misc2.present ? data.misc2.value : this.misc2,
      misc3: data.misc3.present ? data.misc3.value : this.misc3,
      misc4: data.misc4.present ? data.misc4.value : this.misc4,
      misc5: data.misc5.present ? data.misc5.value : this.misc5,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      firmName: data.firmName.present ? data.firmName.value : this.firmName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Location(')
          ..write('locationId: $locationId, ')
          ..write('locationName: $locationName, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdOn: $createdOn, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedOn: $updatedOn, ')
          ..write('misc1: $misc1, ')
          ..write('misc2: $misc2, ')
          ..write('misc3: $misc3, ')
          ..write('misc4: $misc4, ')
          ..write('misc5: $misc5, ')
          ..write('firmId: $firmId, ')
          ..write('firmName: $firmName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      locationId,
      locationName,
      createdBy,
      createdOn,
      updatedBy,
      updatedOn,
      misc1,
      misc2,
      misc3,
      misc4,
      misc5,
      firmId,
      firmName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Location &&
          other.locationId == this.locationId &&
          other.locationName == this.locationName &&
          other.createdBy == this.createdBy &&
          other.createdOn == this.createdOn &&
          other.updatedBy == this.updatedBy &&
          other.updatedOn == this.updatedOn &&
          other.misc1 == this.misc1 &&
          other.misc2 == this.misc2 &&
          other.misc3 == this.misc3 &&
          other.misc4 == this.misc4 &&
          other.misc5 == this.misc5 &&
          other.firmId == this.firmId &&
          other.firmName == this.firmName);
}

class LocationsCompanion extends UpdateCompanion<Location> {
  final Value<int> locationId;
  final Value<String?> locationName;
  final Value<int?> createdBy;
  final Value<String?> createdOn;
  final Value<int?> updatedBy;
  final Value<String?> updatedOn;
  final Value<String?> misc1;
  final Value<String?> misc2;
  final Value<String?> misc3;
  final Value<String?> misc4;
  final Value<String?> misc5;
  final Value<int?> firmId;
  final Value<String?> firmName;
  const LocationsCompanion({
    this.locationId = const Value.absent(),
    this.locationName = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedOn = const Value.absent(),
    this.misc1 = const Value.absent(),
    this.misc2 = const Value.absent(),
    this.misc3 = const Value.absent(),
    this.misc4 = const Value.absent(),
    this.misc5 = const Value.absent(),
    this.firmId = const Value.absent(),
    this.firmName = const Value.absent(),
  });
  LocationsCompanion.insert({
    this.locationId = const Value.absent(),
    this.locationName = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedOn = const Value.absent(),
    this.misc1 = const Value.absent(),
    this.misc2 = const Value.absent(),
    this.misc3 = const Value.absent(),
    this.misc4 = const Value.absent(),
    this.misc5 = const Value.absent(),
    this.firmId = const Value.absent(),
    this.firmName = const Value.absent(),
  });
  static Insertable<Location> custom({
    Expression<int>? locationId,
    Expression<String>? locationName,
    Expression<int>? createdBy,
    Expression<String>? createdOn,
    Expression<int>? updatedBy,
    Expression<String>? updatedOn,
    Expression<String>? misc1,
    Expression<String>? misc2,
    Expression<String>? misc3,
    Expression<String>? misc4,
    Expression<String>? misc5,
    Expression<int>? firmId,
    Expression<String>? firmName,
  }) {
    return RawValuesInsertable({
      if (locationId != null) 'location_id': locationId,
      if (locationName != null) 'location_name': locationName,
      if (createdBy != null) 'created_by': createdBy,
      if (createdOn != null) 'created_on': createdOn,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedOn != null) 'updated_on': updatedOn,
      if (misc1 != null) 'misc1': misc1,
      if (misc2 != null) 'misc2': misc2,
      if (misc3 != null) 'misc3': misc3,
      if (misc4 != null) 'misc4': misc4,
      if (misc5 != null) 'misc5': misc5,
      if (firmId != null) 'firm_id': firmId,
      if (firmName != null) 'firm_name': firmName,
    });
  }

  LocationsCompanion copyWith(
      {Value<int>? locationId,
      Value<String?>? locationName,
      Value<int?>? createdBy,
      Value<String?>? createdOn,
      Value<int?>? updatedBy,
      Value<String?>? updatedOn,
      Value<String?>? misc1,
      Value<String?>? misc2,
      Value<String?>? misc3,
      Value<String?>? misc4,
      Value<String?>? misc5,
      Value<int?>? firmId,
      Value<String?>? firmName}) {
    return LocationsCompanion(
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      createdBy: createdBy ?? this.createdBy,
      createdOn: createdOn ?? this.createdOn,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedOn: updatedOn ?? this.updatedOn,
      misc1: misc1 ?? this.misc1,
      misc2: misc2 ?? this.misc2,
      misc3: misc3 ?? this.misc3,
      misc4: misc4 ?? this.misc4,
      misc5: misc5 ?? this.misc5,
      firmId: firmId ?? this.firmId,
      firmName: firmName ?? this.firmName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (locationId.present) {
      map['location_id'] = Variable<int>(locationId.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    if (createdOn.present) {
      map['created_on'] = Variable<String>(createdOn.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<int>(updatedBy.value);
    }
    if (updatedOn.present) {
      map['updated_on'] = Variable<String>(updatedOn.value);
    }
    if (misc1.present) {
      map['misc1'] = Variable<String>(misc1.value);
    }
    if (misc2.present) {
      map['misc2'] = Variable<String>(misc2.value);
    }
    if (misc3.present) {
      map['misc3'] = Variable<String>(misc3.value);
    }
    if (misc4.present) {
      map['misc4'] = Variable<String>(misc4.value);
    }
    if (misc5.present) {
      map['misc5'] = Variable<String>(misc5.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<int>(firmId.value);
    }
    if (firmName.present) {
      map['firm_name'] = Variable<String>(firmName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCompanion(')
          ..write('locationId: $locationId, ')
          ..write('locationName: $locationName, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdOn: $createdOn, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedOn: $updatedOn, ')
          ..write('misc1: $misc1, ')
          ..write('misc2: $misc2, ')
          ..write('misc3: $misc3, ')
          ..write('misc4: $misc4, ')
          ..write('misc5: $misc5, ')
          ..write('firmId: $firmId, ')
          ..write('firmName: $firmName')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cateIdMeta = const VerificationMeta('cateId');
  @override
  late final GeneratedColumn<int> cateId = GeneratedColumn<int>(
      'cate_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _cateNameMeta =
      const VerificationMeta('cateName');
  @override
  late final GeneratedColumn<String> cateName = GeneratedColumn<String>(
      'cate_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cateShortNameMeta =
      const VerificationMeta('cateShortName');
  @override
  late final GeneratedColumn<String> cateShortName = GeneratedColumn<String>(
      'cate_short_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isHardwareMeta =
      const VerificationMeta('isHardware');
  @override
  late final GeneratedColumn<bool> isHardware = GeneratedColumn<bool>(
      'is_hardware', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_hardware" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [cateId, cateName, cateShortName, isHardware];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cate_id')) {
      context.handle(_cateIdMeta,
          cateId.isAcceptableOrUnknown(data['cate_id']!, _cateIdMeta));
    }
    if (data.containsKey('cate_name')) {
      context.handle(_cateNameMeta,
          cateName.isAcceptableOrUnknown(data['cate_name']!, _cateNameMeta));
    }
    if (data.containsKey('cate_short_name')) {
      context.handle(
          _cateShortNameMeta,
          cateShortName.isAcceptableOrUnknown(
              data['cate_short_name']!, _cateShortNameMeta));
    }
    if (data.containsKey('is_hardware')) {
      context.handle(
          _isHardwareMeta,
          isHardware.isAcceptableOrUnknown(
              data['is_hardware']!, _isHardwareMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cateId};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      cateId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cate_id'])!,
      cateName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cate_name']),
      cateShortName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cate_short_name']),
      isHardware: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_hardware']),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int cateId;
  final String? cateName;
  final String? cateShortName;
  final bool? isHardware;
  const Category(
      {required this.cateId,
      this.cateName,
      this.cateShortName,
      this.isHardware});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cate_id'] = Variable<int>(cateId);
    if (!nullToAbsent || cateName != null) {
      map['cate_name'] = Variable<String>(cateName);
    }
    if (!nullToAbsent || cateShortName != null) {
      map['cate_short_name'] = Variable<String>(cateShortName);
    }
    if (!nullToAbsent || isHardware != null) {
      map['is_hardware'] = Variable<bool>(isHardware);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      cateId: Value(cateId),
      cateName: cateName == null && nullToAbsent
          ? const Value.absent()
          : Value(cateName),
      cateShortName: cateShortName == null && nullToAbsent
          ? const Value.absent()
          : Value(cateShortName),
      isHardware: isHardware == null && nullToAbsent
          ? const Value.absent()
          : Value(isHardware),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      cateId: serializer.fromJson<int>(json['cateId']),
      cateName: serializer.fromJson<String?>(json['cateName']),
      cateShortName: serializer.fromJson<String?>(json['cateShortName']),
      isHardware: serializer.fromJson<bool?>(json['isHardware']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cateId': serializer.toJson<int>(cateId),
      'cateName': serializer.toJson<String?>(cateName),
      'cateShortName': serializer.toJson<String?>(cateShortName),
      'isHardware': serializer.toJson<bool?>(isHardware),
    };
  }

  Category copyWith(
          {int? cateId,
          Value<String?> cateName = const Value.absent(),
          Value<String?> cateShortName = const Value.absent(),
          Value<bool?> isHardware = const Value.absent()}) =>
      Category(
        cateId: cateId ?? this.cateId,
        cateName: cateName.present ? cateName.value : this.cateName,
        cateShortName:
            cateShortName.present ? cateShortName.value : this.cateShortName,
        isHardware: isHardware.present ? isHardware.value : this.isHardware,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      cateId: data.cateId.present ? data.cateId.value : this.cateId,
      cateName: data.cateName.present ? data.cateName.value : this.cateName,
      cateShortName: data.cateShortName.present
          ? data.cateShortName.value
          : this.cateShortName,
      isHardware:
          data.isHardware.present ? data.isHardware.value : this.isHardware,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('cateId: $cateId, ')
          ..write('cateName: $cateName, ')
          ..write('cateShortName: $cateShortName, ')
          ..write('isHardware: $isHardware')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cateId, cateName, cateShortName, isHardware);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.cateId == this.cateId &&
          other.cateName == this.cateName &&
          other.cateShortName == this.cateShortName &&
          other.isHardware == this.isHardware);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> cateId;
  final Value<String?> cateName;
  final Value<String?> cateShortName;
  final Value<bool?> isHardware;
  const CategoriesCompanion({
    this.cateId = const Value.absent(),
    this.cateName = const Value.absent(),
    this.cateShortName = const Value.absent(),
    this.isHardware = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.cateId = const Value.absent(),
    this.cateName = const Value.absent(),
    this.cateShortName = const Value.absent(),
    this.isHardware = const Value.absent(),
  });
  static Insertable<Category> custom({
    Expression<int>? cateId,
    Expression<String>? cateName,
    Expression<String>? cateShortName,
    Expression<bool>? isHardware,
  }) {
    return RawValuesInsertable({
      if (cateId != null) 'cate_id': cateId,
      if (cateName != null) 'cate_name': cateName,
      if (cateShortName != null) 'cate_short_name': cateShortName,
      if (isHardware != null) 'is_hardware': isHardware,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? cateId,
      Value<String?>? cateName,
      Value<String?>? cateShortName,
      Value<bool?>? isHardware}) {
    return CategoriesCompanion(
      cateId: cateId ?? this.cateId,
      cateName: cateName ?? this.cateName,
      cateShortName: cateShortName ?? this.cateShortName,
      isHardware: isHardware ?? this.isHardware,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cateId.present) {
      map['cate_id'] = Variable<int>(cateId.value);
    }
    if (cateName.present) {
      map['cate_name'] = Variable<String>(cateName.value);
    }
    if (cateShortName.present) {
      map['cate_short_name'] = Variable<String>(cateShortName.value);
    }
    if (isHardware.present) {
      map['is_hardware'] = Variable<bool>(isHardware.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('cateId: $cateId, ')
          ..write('cateName: $cateName, ')
          ..write('cateShortName: $cateShortName, ')
          ..write('isHardware: $isHardware')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $RateTypesTable rateTypes = $RateTypesTable(this);
  late final $BillTypesTable billTypes = $BillTypesTable(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [items, rateTypes, billTypes, locations, categories];
}

typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  Value<int> itemId,
  Value<String?> itemName,
  Value<String?> itemCode,
  Value<double?> lastPurchaseRate,
  Value<double?> lastMRP,
  Value<String?> taxPer,
  Value<int?> unitId,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<int> itemId,
  Value<String?> itemName,
  Value<String?> itemCode,
  Value<double?> lastPurchaseRate,
  Value<double?> lastMRP,
  Value<String?> taxPer,
  Value<int?> unitId,
});

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemCode => $composableBuilder(
      column: $table.itemCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lastPurchaseRate => $composableBuilder(
      column: $table.lastPurchaseRate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lastMRP => $composableBuilder(
      column: $table.lastMRP, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxPer => $composableBuilder(
      column: $table.taxPer, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnFilters(column));
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemCode => $composableBuilder(
      column: $table.itemCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lastPurchaseRate => $composableBuilder(
      column: $table.lastPurchaseRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lastMRP => $composableBuilder(
      column: $table.lastMRP, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxPer => $composableBuilder(
      column: $table.taxPer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnOrderings(column));
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get itemCode =>
      $composableBuilder(column: $table.itemCode, builder: (column) => column);

  GeneratedColumn<double> get lastPurchaseRate => $composableBuilder(
      column: $table.lastPurchaseRate, builder: (column) => column);

  GeneratedColumn<double> get lastMRP =>
      $composableBuilder(column: $table.lastMRP, builder: (column) => column);

  GeneratedColumn<String> get taxPer =>
      $composableBuilder(column: $table.taxPer, builder: (column) => column);

  GeneratedColumn<int> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);
}

class $$ItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
    Item,
    PrefetchHooks Function()> {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> itemId = const Value.absent(),
            Value<String?> itemName = const Value.absent(),
            Value<String?> itemCode = const Value.absent(),
            Value<double?> lastPurchaseRate = const Value.absent(),
            Value<double?> lastMRP = const Value.absent(),
            Value<String?> taxPer = const Value.absent(),
            Value<int?> unitId = const Value.absent(),
          }) =>
              ItemsCompanion(
            itemId: itemId,
            itemName: itemName,
            itemCode: itemCode,
            lastPurchaseRate: lastPurchaseRate,
            lastMRP: lastMRP,
            taxPer: taxPer,
            unitId: unitId,
          ),
          createCompanionCallback: ({
            Value<int> itemId = const Value.absent(),
            Value<String?> itemName = const Value.absent(),
            Value<String?> itemCode = const Value.absent(),
            Value<double?> lastPurchaseRate = const Value.absent(),
            Value<double?> lastMRP = const Value.absent(),
            Value<String?> taxPer = const Value.absent(),
            Value<int?> unitId = const Value.absent(),
          }) =>
              ItemsCompanion.insert(
            itemId: itemId,
            itemName: itemName,
            itemCode: itemCode,
            lastPurchaseRate: lastPurchaseRate,
            lastMRP: lastMRP,
            taxPer: taxPer,
            unitId: unitId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
    Item,
    PrefetchHooks Function()>;
typedef $$RateTypesTableCreateCompanionBuilder = RateTypesCompanion Function({
  Value<int> rateTypeId,
  Value<String?> rateType,
  Value<String?> rateTypeDisplay,
});
typedef $$RateTypesTableUpdateCompanionBuilder = RateTypesCompanion Function({
  Value<int> rateTypeId,
  Value<String?> rateType,
  Value<String?> rateTypeDisplay,
});

class $$RateTypesTableFilterComposer
    extends Composer<_$AppDatabase, $RateTypesTable> {
  $$RateTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rateTypeId => $composableBuilder(
      column: $table.rateTypeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rateType => $composableBuilder(
      column: $table.rateType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rateTypeDisplay => $composableBuilder(
      column: $table.rateTypeDisplay,
      builder: (column) => ColumnFilters(column));
}

class $$RateTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $RateTypesTable> {
  $$RateTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rateTypeId => $composableBuilder(
      column: $table.rateTypeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rateType => $composableBuilder(
      column: $table.rateType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rateTypeDisplay => $composableBuilder(
      column: $table.rateTypeDisplay,
      builder: (column) => ColumnOrderings(column));
}

class $$RateTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RateTypesTable> {
  $$RateTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rateTypeId => $composableBuilder(
      column: $table.rateTypeId, builder: (column) => column);

  GeneratedColumn<String> get rateType =>
      $composableBuilder(column: $table.rateType, builder: (column) => column);

  GeneratedColumn<String> get rateTypeDisplay => $composableBuilder(
      column: $table.rateTypeDisplay, builder: (column) => column);
}

class $$RateTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RateTypesTable,
    RateType,
    $$RateTypesTableFilterComposer,
    $$RateTypesTableOrderingComposer,
    $$RateTypesTableAnnotationComposer,
    $$RateTypesTableCreateCompanionBuilder,
    $$RateTypesTableUpdateCompanionBuilder,
    (RateType, BaseReferences<_$AppDatabase, $RateTypesTable, RateType>),
    RateType,
    PrefetchHooks Function()> {
  $$RateTypesTableTableManager(_$AppDatabase db, $RateTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RateTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RateTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RateTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> rateTypeId = const Value.absent(),
            Value<String?> rateType = const Value.absent(),
            Value<String?> rateTypeDisplay = const Value.absent(),
          }) =>
              RateTypesCompanion(
            rateTypeId: rateTypeId,
            rateType: rateType,
            rateTypeDisplay: rateTypeDisplay,
          ),
          createCompanionCallback: ({
            Value<int> rateTypeId = const Value.absent(),
            Value<String?> rateType = const Value.absent(),
            Value<String?> rateTypeDisplay = const Value.absent(),
          }) =>
              RateTypesCompanion.insert(
            rateTypeId: rateTypeId,
            rateType: rateType,
            rateTypeDisplay: rateTypeDisplay,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RateTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RateTypesTable,
    RateType,
    $$RateTypesTableFilterComposer,
    $$RateTypesTableOrderingComposer,
    $$RateTypesTableAnnotationComposer,
    $$RateTypesTableCreateCompanionBuilder,
    $$RateTypesTableUpdateCompanionBuilder,
    (RateType, BaseReferences<_$AppDatabase, $RateTypesTable, RateType>),
    RateType,
    PrefetchHooks Function()>;
typedef $$BillTypesTableCreateCompanionBuilder = BillTypesCompanion Function({
  Value<int> billTypeId,
  Value<String?> billType,
  Value<String?> prefix,
  Value<bool?> includeFinancialYear,
  Value<String?> salesQuotation,
});
typedef $$BillTypesTableUpdateCompanionBuilder = BillTypesCompanion Function({
  Value<int> billTypeId,
  Value<String?> billType,
  Value<String?> prefix,
  Value<bool?> includeFinancialYear,
  Value<String?> salesQuotation,
});

class $$BillTypesTableFilterComposer
    extends Composer<_$AppDatabase, $BillTypesTable> {
  $$BillTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get billTypeId => $composableBuilder(
      column: $table.billTypeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billType => $composableBuilder(
      column: $table.billType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prefix => $composableBuilder(
      column: $table.prefix, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get includeFinancialYear => $composableBuilder(
      column: $table.includeFinancialYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get salesQuotation => $composableBuilder(
      column: $table.salesQuotation,
      builder: (column) => ColumnFilters(column));
}

class $$BillTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $BillTypesTable> {
  $$BillTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get billTypeId => $composableBuilder(
      column: $table.billTypeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billType => $composableBuilder(
      column: $table.billType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prefix => $composableBuilder(
      column: $table.prefix, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get includeFinancialYear => $composableBuilder(
      column: $table.includeFinancialYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get salesQuotation => $composableBuilder(
      column: $table.salesQuotation,
      builder: (column) => ColumnOrderings(column));
}

class $$BillTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillTypesTable> {
  $$BillTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get billTypeId => $composableBuilder(
      column: $table.billTypeId, builder: (column) => column);

  GeneratedColumn<String> get billType =>
      $composableBuilder(column: $table.billType, builder: (column) => column);

  GeneratedColumn<String> get prefix =>
      $composableBuilder(column: $table.prefix, builder: (column) => column);

  GeneratedColumn<bool> get includeFinancialYear => $composableBuilder(
      column: $table.includeFinancialYear, builder: (column) => column);

  GeneratedColumn<String> get salesQuotation => $composableBuilder(
      column: $table.salesQuotation, builder: (column) => column);
}

class $$BillTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BillTypesTable,
    BillType,
    $$BillTypesTableFilterComposer,
    $$BillTypesTableOrderingComposer,
    $$BillTypesTableAnnotationComposer,
    $$BillTypesTableCreateCompanionBuilder,
    $$BillTypesTableUpdateCompanionBuilder,
    (BillType, BaseReferences<_$AppDatabase, $BillTypesTable, BillType>),
    BillType,
    PrefetchHooks Function()> {
  $$BillTypesTableTableManager(_$AppDatabase db, $BillTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> billTypeId = const Value.absent(),
            Value<String?> billType = const Value.absent(),
            Value<String?> prefix = const Value.absent(),
            Value<bool?> includeFinancialYear = const Value.absent(),
            Value<String?> salesQuotation = const Value.absent(),
          }) =>
              BillTypesCompanion(
            billTypeId: billTypeId,
            billType: billType,
            prefix: prefix,
            includeFinancialYear: includeFinancialYear,
            salesQuotation: salesQuotation,
          ),
          createCompanionCallback: ({
            Value<int> billTypeId = const Value.absent(),
            Value<String?> billType = const Value.absent(),
            Value<String?> prefix = const Value.absent(),
            Value<bool?> includeFinancialYear = const Value.absent(),
            Value<String?> salesQuotation = const Value.absent(),
          }) =>
              BillTypesCompanion.insert(
            billTypeId: billTypeId,
            billType: billType,
            prefix: prefix,
            includeFinancialYear: includeFinancialYear,
            salesQuotation: salesQuotation,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BillTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BillTypesTable,
    BillType,
    $$BillTypesTableFilterComposer,
    $$BillTypesTableOrderingComposer,
    $$BillTypesTableAnnotationComposer,
    $$BillTypesTableCreateCompanionBuilder,
    $$BillTypesTableUpdateCompanionBuilder,
    (BillType, BaseReferences<_$AppDatabase, $BillTypesTable, BillType>),
    BillType,
    PrefetchHooks Function()>;
typedef $$LocationsTableCreateCompanionBuilder = LocationsCompanion Function({
  Value<int> locationId,
  Value<String?> locationName,
  Value<int?> createdBy,
  Value<String?> createdOn,
  Value<int?> updatedBy,
  Value<String?> updatedOn,
  Value<String?> misc1,
  Value<String?> misc2,
  Value<String?> misc3,
  Value<String?> misc4,
  Value<String?> misc5,
  Value<int?> firmId,
  Value<String?> firmName,
});
typedef $$LocationsTableUpdateCompanionBuilder = LocationsCompanion Function({
  Value<int> locationId,
  Value<String?> locationName,
  Value<int?> createdBy,
  Value<String?> createdOn,
  Value<int?> updatedBy,
  Value<String?> updatedOn,
  Value<String?> misc1,
  Value<String?> misc2,
  Value<String?> misc3,
  Value<String?> misc4,
  Value<String?> misc5,
  Value<int?> firmId,
  Value<String?> firmName,
});

class $$LocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationName => $composableBuilder(
      column: $table.locationName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdOn => $composableBuilder(
      column: $table.createdOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedOn => $composableBuilder(
      column: $table.updatedOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get misc1 => $composableBuilder(
      column: $table.misc1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get misc2 => $composableBuilder(
      column: $table.misc2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get misc3 => $composableBuilder(
      column: $table.misc3, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get misc4 => $composableBuilder(
      column: $table.misc4, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get misc5 => $composableBuilder(
      column: $table.misc5, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get firmId => $composableBuilder(
      column: $table.firmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firmName => $composableBuilder(
      column: $table.firmName, builder: (column) => ColumnFilters(column));
}

class $$LocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationName => $composableBuilder(
      column: $table.locationName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdOn => $composableBuilder(
      column: $table.createdOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedOn => $composableBuilder(
      column: $table.updatedOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get misc1 => $composableBuilder(
      column: $table.misc1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get misc2 => $composableBuilder(
      column: $table.misc2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get misc3 => $composableBuilder(
      column: $table.misc3, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get misc4 => $composableBuilder(
      column: $table.misc4, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get misc5 => $composableBuilder(
      column: $table.misc5, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get firmId => $composableBuilder(
      column: $table.firmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firmName => $composableBuilder(
      column: $table.firmName, builder: (column) => ColumnOrderings(column));
}

class $$LocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => column);

  GeneratedColumn<String> get locationName => $composableBuilder(
      column: $table.locationName, builder: (column) => column);

  GeneratedColumn<int> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdOn =>
      $composableBuilder(column: $table.createdOn, builder: (column) => column);

  GeneratedColumn<int> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get updatedOn =>
      $composableBuilder(column: $table.updatedOn, builder: (column) => column);

  GeneratedColumn<String> get misc1 =>
      $composableBuilder(column: $table.misc1, builder: (column) => column);

  GeneratedColumn<String> get misc2 =>
      $composableBuilder(column: $table.misc2, builder: (column) => column);

  GeneratedColumn<String> get misc3 =>
      $composableBuilder(column: $table.misc3, builder: (column) => column);

  GeneratedColumn<String> get misc4 =>
      $composableBuilder(column: $table.misc4, builder: (column) => column);

  GeneratedColumn<String> get misc5 =>
      $composableBuilder(column: $table.misc5, builder: (column) => column);

  GeneratedColumn<int> get firmId =>
      $composableBuilder(column: $table.firmId, builder: (column) => column);

  GeneratedColumn<String> get firmName =>
      $composableBuilder(column: $table.firmName, builder: (column) => column);
}

class $$LocationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocationsTable,
    Location,
    $$LocationsTableFilterComposer,
    $$LocationsTableOrderingComposer,
    $$LocationsTableAnnotationComposer,
    $$LocationsTableCreateCompanionBuilder,
    $$LocationsTableUpdateCompanionBuilder,
    (Location, BaseReferences<_$AppDatabase, $LocationsTable, Location>),
    Location,
    PrefetchHooks Function()> {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> locationId = const Value.absent(),
            Value<String?> locationName = const Value.absent(),
            Value<int?> createdBy = const Value.absent(),
            Value<String?> createdOn = const Value.absent(),
            Value<int?> updatedBy = const Value.absent(),
            Value<String?> updatedOn = const Value.absent(),
            Value<String?> misc1 = const Value.absent(),
            Value<String?> misc2 = const Value.absent(),
            Value<String?> misc3 = const Value.absent(),
            Value<String?> misc4 = const Value.absent(),
            Value<String?> misc5 = const Value.absent(),
            Value<int?> firmId = const Value.absent(),
            Value<String?> firmName = const Value.absent(),
          }) =>
              LocationsCompanion(
            locationId: locationId,
            locationName: locationName,
            createdBy: createdBy,
            createdOn: createdOn,
            updatedBy: updatedBy,
            updatedOn: updatedOn,
            misc1: misc1,
            misc2: misc2,
            misc3: misc3,
            misc4: misc4,
            misc5: misc5,
            firmId: firmId,
            firmName: firmName,
          ),
          createCompanionCallback: ({
            Value<int> locationId = const Value.absent(),
            Value<String?> locationName = const Value.absent(),
            Value<int?> createdBy = const Value.absent(),
            Value<String?> createdOn = const Value.absent(),
            Value<int?> updatedBy = const Value.absent(),
            Value<String?> updatedOn = const Value.absent(),
            Value<String?> misc1 = const Value.absent(),
            Value<String?> misc2 = const Value.absent(),
            Value<String?> misc3 = const Value.absent(),
            Value<String?> misc4 = const Value.absent(),
            Value<String?> misc5 = const Value.absent(),
            Value<int?> firmId = const Value.absent(),
            Value<String?> firmName = const Value.absent(),
          }) =>
              LocationsCompanion.insert(
            locationId: locationId,
            locationName: locationName,
            createdBy: createdBy,
            createdOn: createdOn,
            updatedBy: updatedBy,
            updatedOn: updatedOn,
            misc1: misc1,
            misc2: misc2,
            misc3: misc3,
            misc4: misc4,
            misc5: misc5,
            firmId: firmId,
            firmName: firmName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocationsTable,
    Location,
    $$LocationsTableFilterComposer,
    $$LocationsTableOrderingComposer,
    $$LocationsTableAnnotationComposer,
    $$LocationsTableCreateCompanionBuilder,
    $$LocationsTableUpdateCompanionBuilder,
    (Location, BaseReferences<_$AppDatabase, $LocationsTable, Location>),
    Location,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> cateId,
  Value<String?> cateName,
  Value<String?> cateShortName,
  Value<bool?> isHardware,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> cateId,
  Value<String?> cateName,
  Value<String?> cateShortName,
  Value<bool?> isHardware,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get cateId => $composableBuilder(
      column: $table.cateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cateName => $composableBuilder(
      column: $table.cateName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cateShortName => $composableBuilder(
      column: $table.cateShortName, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isHardware => $composableBuilder(
      column: $table.isHardware, builder: (column) => ColumnFilters(column));
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
  ColumnOrderings<int> get cateId => $composableBuilder(
      column: $table.cateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cateName => $composableBuilder(
      column: $table.cateName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cateShortName => $composableBuilder(
      column: $table.cateShortName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isHardware => $composableBuilder(
      column: $table.isHardware, builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<int> get cateId =>
      $composableBuilder(column: $table.cateId, builder: (column) => column);

  GeneratedColumn<String> get cateName =>
      $composableBuilder(column: $table.cateName, builder: (column) => column);

  GeneratedColumn<String> get cateShortName => $composableBuilder(
      column: $table.cateShortName, builder: (column) => column);

  GeneratedColumn<bool> get isHardware => $composableBuilder(
      column: $table.isHardware, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> cateId = const Value.absent(),
            Value<String?> cateName = const Value.absent(),
            Value<String?> cateShortName = const Value.absent(),
            Value<bool?> isHardware = const Value.absent(),
          }) =>
              CategoriesCompanion(
            cateId: cateId,
            cateName: cateName,
            cateShortName: cateShortName,
            isHardware: isHardware,
          ),
          createCompanionCallback: ({
            Value<int> cateId = const Value.absent(),
            Value<String?> cateName = const Value.absent(),
            Value<String?> cateShortName = const Value.absent(),
            Value<bool?> isHardware = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            cateId: cateId,
            cateName: cateName,
            cateShortName: cateShortName,
            isHardware: isHardware,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$RateTypesTableTableManager get rateTypes =>
      $$RateTypesTableTableManager(_db, _db.rateTypes);
  $$BillTypesTableTableManager get billTypes =>
      $$BillTypesTableTableManager(_db, _db.billTypes);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
}
