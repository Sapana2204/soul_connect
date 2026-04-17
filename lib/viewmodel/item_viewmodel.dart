import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/repository/item_repository.dart';

import '../model/item_rate_model.dart';
import '../model/item_sales_details_model.dart';
import '../model/item_unit_model.dart';
import '../model/items_model.dart';
import '../model/rate_type_model.dart';
import '../model/stock_locations_model.dart';

class ItemViewmodel with ChangeNotifier {
  final _itemRepo = ItemsRepository();

  bool _itemLoading = false;
  bool _itemDetailsLoading = false;
  bool _stockLocationsLoading = false;
  bool _unitLoading = false;

  List<ItemsModel> _itemList = [];
  List<ItemSalesDetailsModel> _itemDetailsList = [];
  List<StockLocationsModel> _stockLocationsList = [];

  bool get unitLloading => _unitLoading;
  bool get loading => _itemLoading;
  bool get detailsLoading => _itemDetailsLoading;
  bool get locationsLoading => _stockLocationsLoading;
  bool _isSyncing = false;   // ✅ ADD THIS
  bool _itemsLoaded = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<RateTypesModel> _rateTypes = [];
  List<RateTypesModel> get rateTypes => _rateTypes;

  RateTypesModel? _selectedRateType;
  RateTypesModel? get selectedRateType => _selectedRateType;
  List<ItemsModel> get itemList => _itemList;
  List<ItemSalesDetailsModel> get itemDetailsList => _itemDetailsList;
  List<StockLocationsModel> get stockLocationsList => _stockLocationsList;
  List<ItemUnitModel> unitList = [];
  ItemUnitModel? selectedUnit;

  ItemRateModel? _itemRate;
  bool _rateLoading = false;

  ItemRateModel? get itemRate => _itemRate;
  bool get rateLoading => _rateLoading;
  void setItems(bool value) {
    _itemLoading = value;
    notifyListeners();
  }

  void setItemDetails(bool value) {
    _itemDetailsLoading = value;
    notifyListeners();
  }

  void setStockLocations(bool value) {
    _stockLocationsLoading = value;
    notifyListeners();
  }

  /// ⭐ Master Data Loader (Offline First)
  Future<void> getItemsApi() async {

    itemList.clear();   // ⭐ IMPORTANT FIX
    notifyListeners();

    print("🚀 getItemsApi CALLED");

    /// ❗ ALWAYS try DB first (remove dependency on _itemList)
    final localData = await _itemRepo.getLocalItems();

    print("📦 LOCAL DB COUNT: ${localData.length}");

    if (localData.isNotEmpty) {
      _itemList = localData;
      _itemList.sort((a, b) =>
          (a.itemName ?? "").toLowerCase().compareTo((b.itemName ?? "").toLowerCase()));

      print("✅ ITEM LIST COUNT (FROM DB): ${_itemList.length}");

      notifyListeners();

      /// Background sync
      _refreshFromServer();
      return;
    }

    /// If DB empty → API
    print("🌐 DB EMPTY → CALLING API");

    setItems(true);

    try {
      final freshData = await _itemRepo.fetchItemsFromApi();

      _itemList = freshData;
      _itemList.sort((a, b) =>
          (a.itemName ?? "").toLowerCase().compareTo((b.itemName ?? "").toLowerCase()));

      print("🌐 ITEM LIST COUNT (FROM API): ${_itemList.length}");

      notifyListeners();
    } finally {
      setItems(false);
    }
  }

  // Future<void> getItemsApi() async {
  //   if (_itemLoading) return; // prevent multiple calls
  //
  //   _itemLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     final freshData = await _itemRepo.fetchItemsFromApi();
  //
  //     _itemList = freshData;
  //
  //   } catch (e) {
  //     debugPrint("Items API error: $e");
  //     _itemList = [];
  //   }
  //
  //   _itemLoading = false;
  //   notifyListeners();
  // }

  /// ⭐ Background Sync
  Future<void> _refreshFromServer() async {

    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final freshData = await _itemRepo.fetchItemsFromApi();

      _itemList = freshData;
      notifyListeners();

    } finally {
      _isSyncing = false;
    }
  }

  Future<void> clearLocalItems() async {
    await _itemRepo.clearItemsDb();
    _itemList.clear();
    _itemsLoaded = false;
    notifyListeners();
  }


  Future<List<StockLocationsModel>> getStockLocationsApi() async {
    setItemDetails(true);
    try {
      List<StockLocationsModel> response = await _itemRepo.getStockLocations();
      _stockLocationsList = response;
      return response; // <--- return the fetched list
    } catch (error) {
      print("Error fetching locations: $error");
      return []; // return empty list on error
    } finally {
      setStockLocations(false);
    }
  }

  Future<List<ItemSalesDetailsModel>> getItemSalesDetailsApi(int itemId, String date, String locationId) async {
    setItemDetails(true);
    try {
      List<ItemSalesDetailsModel> response = await _itemRepo.fetchItemSalesDetails(itemId, date, locationId);
      _itemDetailsList = response;
      return response; // <--- return the fetched list
    } catch (error) {
      print("Error fetching items: $error");
      return []; // return empty list on error
    } finally {
      setItemDetails(false);
    }
  }

  Future<void> getItemUnits(int itemId) async {
    _unitLoading = true;
    unitList = [];
    selectedUnit = null;
    notifyListeners();

    try {
      unitList = await _itemRepo.fetchItemUnits(itemId);

      if (unitList.isNotEmpty) {
        selectedUnit = unitList.first; // default selection
      }
    } catch (e) {
      debugPrint("Item Unit API error: $e");
    }

    _unitLoading = false;
    notifyListeners();
  }

  void setSelectedUnit(ItemUnitModel? unit) {
    selectedUnit = unit;
    notifyListeners();
  }

  Future<void> getItemRate({
    required int itemId,
    required String rateOn,
    required int rateTypeId,
    int? customerId,
    required int unitId,
  }) async {
    _rateLoading = true;
    notifyListeners();

    try {
      _itemRate = await _itemRepo.fetchItemRate(
        itemId: itemId,
        rateOn: rateOn,
        rateTypeId: rateTypeId,
        customerId: customerId,
        unitId: unitId,
      );
    } catch (e) {
      debugPrint("Get Item Rate error: $e");
    }

    _rateLoading = false;
    notifyListeners();
  }

  Future<void> getRateTypes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rateTypes = await _itemRepo.fetchRateTypes();

      // default selection (optional)
      if (_rateTypes.isNotEmpty) {
        _selectedRateType = _rateTypes.first;
      }
    } catch (e) {
      debugPrint("RateTypeViewModel Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedRateType(RateTypesModel value) {
    _selectedRateType = value;
    notifyListeners();
  }

}
