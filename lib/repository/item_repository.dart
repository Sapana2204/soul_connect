import 'package:drift/drift.dart';

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../database/app_database.dart';
import '../model/item_rate_model.dart';
import '../model/item_sales_details_model.dart';
import '../model/item_unit_model.dart';
import '../model/items_model.dart';
import '../model/rate_type_model.dart';
import '../model/stock_locations_model.dart';
import '../res/widgets/app_urls.dart';

class ItemsRepository {
  final BaseApiServices _apiServices = NetworkApiServices();
  // final AppDatabase _db = AppDatabase();
  final AppDatabase _db = AppDatabase.instance;

  // ✅ 1️⃣ Load only from DB
  Future<List<ItemsModel>> getLocalItems() async {
    final localItems = await _db.getAllItems();

    print("📦 Loaded from Drift DB");
    print("📦 Item Count: ${localItems.length}");

    return localItems.map((e) => ItemsModel(
      itemId: e.itemId,
      itemName: e.itemName,
      itemCode: e.itemCode,
      lastPurchaseRate: e.lastPurchaseRate,
      lASTMRP: e.lastMRP,
      taxPer: e.taxPer,
      unitId: e.unitId,
    )).toList();
  }

  // ✅ 2️⃣ Fetch only from API
  Future<List<ItemsModel>> fetchItemsFromApi() async {
    print("🔵 Calling ITEMS API");
    print("🔵 Endpoint: ${AppUrls.getItemsUrl}");

    final response =
    await _apiServices.getGetApiResponse(AppUrls.getItemsUrl);

    List<ItemsModel> itemList =
    (response as List)
        .map((data) => ItemsModel.fromJson(data))
        .toList();

    print("🟢 Items Count From API: ${itemList.length}");

    // Replace old data
    await _db.clearItems();
    await _db.insertItems(
      itemList.map((item) => ItemsCompanion(
        itemId: Value(item.itemId!),
        itemName: Value(item.itemName),
        itemCode: Value(item.itemCode),
        lastPurchaseRate: Value(item.lastPurchaseRate),
        lastMRP: Value(item.lASTMRP),
        taxPer: Value(item.taxPer),
        unitId: Value(item.unitId),
      )).toList(),
    );

    return itemList;
  }

  Future<void> clearItemsDb() async {
    await _db.clearItems();
  }

  Future<List<StockLocationsModel>> getStockLocations() async {
    try {
      final String url = AppUrls.getStockLocationsByUserUrl;
      dynamic response = await _apiServices.getGetApiResponse(url);

      List<StockLocationsModel> apiList =
      (response as List).map((e) => StockLocationsModel.fromJson(e)).toList();

      // Attempt to save to DB, but don't crash the whole function if DB is busy
      try {
        final driftList = apiList.map((e) => LocationsCompanion(
          locationId: Value(e.locationId ?? 0),
          locationName: Value(e.locationName),
          // ... rest of your mapping
        )).toList();

        await _db.clearLocations();
        await _db.insertLocations(driftList);
      } catch (dbError) {
        print("Database sync failed for Locations: $dbError");
      }

      return apiList; // Still return the data from API even if DB sync lagged
    } catch (e) {
      print("API failed, loading Locations from local DB");
      final localData = await _db.getAllLocations();
      return localData.map((e) => StockLocationsModel(
        locationId: e.locationId,
        locationName: e.locationName,
        // ... rest of your mapping
      )).toList();
    }
  }


  Future<List<ItemSalesDetailsModel>> fetchItemSalesDetails(int itemId, String date, String locationId) async {
    try {
      final String url = "${AppUrls.getItemSalesDetailsUrl}/$itemId/$date?locationId=$locationId";
      print('Get Item Sales Details URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print('Get Item Sales Details Response: $response');

      // Assuming response is a List of category master objects
      List<ItemSalesDetailsModel> itemDetailsList =
      (response as List).map((data) => ItemSalesDetailsModel.fromJson(data)).toList();

      return itemDetailsList;
    } catch (e) {
      print("Error fetching items sales details: $e");
      rethrow;
    }
  }

  Future<List<RateTypesModel>> fetchRateTypes() async {
    try {
      final String url = AppUrls.getRateTypesUrl;
      print('Get Rate Types URL: $url');

      final response = await _apiServices.getGetApiResponse(url);

      print('Get Rate Types Response: $response');

      List<RateTypesModel> rateTypeList =
      (response as List)
          .map((e) => RateTypesModel.fromJson(e))
          .toList();

      return rateTypeList;
    } catch (e) {
      print("Error fetching rate types: $e");
      rethrow;
    }
  }

  // 🔹 ITEM UNIT CONVERTED API
  Future<List<ItemUnitModel>> fetchItemUnits(int itemId) async {
    try {
      final String url =
          "${AppUrls.getItemUnitConvertedUrl}?itemId=$itemId";
      print("Get Item Unit URL: $url");

      dynamic response = await _apiServices.getGetApiResponse(url);
      print("Get Item Unit Response: $response");

      List<ItemUnitModel> unitList =
      (response as List).map((e) => ItemUnitModel.fromJson(e)).toList();

      return unitList;
    } catch (e) {
      print("Error fetching item units: $e");
      rethrow;
    }
  }

  Future<ItemRateModel?> fetchItemRate({
    required int itemId,
    required String rateOn,
    required int rateTypeId,
    int? customerId,
    required int unitId,
  }) async {
    try {
      final String url =
          "${AppUrls.baseUrl}/item/GetItemRate"
          "?itemId=$itemId"
          "&rateOn=$rateOn"
          "&rateTypeId=$rateTypeId"
          "&customerId=${customerId ?? ""}"
          "&unitId=$unitId";

      print("Get Item Rate URL: $url");

      final response = await _apiServices.getGetApiResponse(url);

      print("Get Item Rate Response: $response");

      if (response == null) return null;

      return ItemRateModel.fromJson(response);
    } catch (e) {
      print("Error fetching item rate: $e");
      rethrow;
    }
  }
}
