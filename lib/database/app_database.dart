import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Items extends Table {
  IntColumn get itemId => integer()();
  TextColumn get itemName => text().nullable()();
  TextColumn get itemCode => text().nullable()();
  RealColumn get lastPurchaseRate => real().nullable()();
  RealColumn get lastMRP => real().nullable()();
  TextColumn get taxPer => text().nullable()();
  IntColumn get unitId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {itemId};
}

class RateTypes extends Table {
  IntColumn get rateTypeId => integer()();
  TextColumn get rateType => text().nullable()();
  TextColumn get rateTypeDisplay => text().nullable()();

  @override
  Set<Column> get primaryKey => {rateTypeId};
}

class BillTypes extends Table {
  IntColumn get billTypeId => integer()();
  TextColumn get billType => text().nullable()();
  TextColumn get prefix => text().nullable()();
  BoolColumn get includeFinancialYear => boolean().nullable()();
  TextColumn get salesQuotation => text().nullable()();

  @override
  Set<Column> get primaryKey => {billTypeId};
}

class Locations extends Table {
  IntColumn get locationId => integer()();
  TextColumn get locationName => text().nullable()();
  IntColumn get createdBy => integer().nullable()();
  TextColumn get createdOn => text().nullable()();
  IntColumn get updatedBy => integer().nullable()();
  TextColumn get updatedOn => text().nullable()();
  TextColumn get misc1 => text().nullable()();
  TextColumn get misc2 => text().nullable()();
  TextColumn get misc3 => text().nullable()();
  TextColumn get misc4 => text().nullable()();
  TextColumn get misc5 => text().nullable()();
  IntColumn get firmId => integer().nullable()();
  TextColumn get firmName => text().nullable()();

  @override
  Set<Column> get primaryKey => {locationId};
}

class Categories extends Table {
  IntColumn get cateId => integer()();
  TextColumn get cateName => text().nullable()();
  TextColumn get cateShortName => text().nullable()();
  BoolColumn get isHardware => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {cateId};
}


@DriftDatabase(tables: [Items, RateTypes, BillTypes, Locations, Categories])
class AppDatabase extends _$AppDatabase {
  // 1. Private constructor
  AppDatabase._internal() : super(_openConnection());

  // 2. The single instance
  static final AppDatabase instance = AppDatabase._internal();

  // 3. Factory constructor to return the same instance
  factory AppDatabase() => instance;

  @override
  int get schemaVersion => 4;

  // Insert or replace all products
  Future<void> insertItems(List<ItemsCompanion> items) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(this.items, items);
    });
  }

  Future<List<Item>> getAllItems() async {
    return await select(items).get();
  }

  Future<void> clearItems() async {
    await delete(items).go();
  }

  Future<void> clearAllTables() async {
    await batch((batch) {
      batch.deleteAll(items);
      batch.deleteAll(rateTypes);
      batch.deleteAll(billTypes);
      batch.deleteAll(locations);
      batch.deleteAll(categories);
    });
  }

  Future<void> insertRateTypes(List<RateTypesCompanion> data) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(rateTypes, data);
    });
  }

  Future<List<RateType>> getAllRateTypes() async {
    return await select(rateTypes).get();
  }

  Future<void> clearRateTypes() async {
    await delete(rateTypes).go();
  }


  Future<void> insertBillTypes(List<BillTypesCompanion> data) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(billTypes, data);
    });
  }

  Future<List<BillType>> getAllBillTypes() async {
    return await select(billTypes).get();
  }

  Future<void> clearBillTypes() async {
    await delete(billTypes).go();
  }

  Future<void> insertLocations(List<LocationsCompanion> data) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(locations, data);
    });
  }

  Future<List<Location>> getAllLocations() async {
    return await select(locations).get();
  }

  Future<void> clearLocations() async {
    await delete(locations).go();
  }

  Future<void> insertCategories(List<CategoriesCompanion> data) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(categories, data);
    });
  }

  Future<List<Category>> getAllCategories() async {
    return await select(categories).get();
  }

  Future<void> clearCategories() async {
    await delete(categories).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return driftDatabase(name: 'app_database');
  });
}