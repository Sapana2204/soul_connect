import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/item_sales_details_model.dart';
import '../model/items_by_product_type.dart';
import '../model/stock_locations_model.dart';
import '../res/widgets/app_urls.dart';

class ItemsByProductTypeRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<ItemsByProductTypeModel>> fetchItemsByProductType(
      String stockDate, Map<String, String> params) async {
    try {
      String url = AppUrls.getItemsByProductTypeUrl
          .replaceAll('{stockDate}', stockDate);

      if (params.isNotEmpty) {
        url += '?${params.entries.map((e) => "${e.key}=${e.value}").join("&")}';
      }

      print('Get Items by product type URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print('Get Items By Product Type Response: $response');

      // Assuming response is a List of category master objects
      List<ItemsByProductTypeModel> itemsByProductTypeList =
      (response as List).map((data) => ItemsByProductTypeModel.fromJson(data)).toList();

      return itemsByProductTypeList;
    } catch (e) {
      print("Error fetching items by product type: $e");
      rethrow;
    }
  }

  Future<List<StockLocationsModel>> getStockLocationsByUser() async {
    try {
      final String url = "${AppUrls.getStockLocationsByUserUrl}";
      print('Get Stock Locations By User URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print('Get Stock Locations By User Response: $response');

      // Assuming response is a List of category master objects
      List<StockLocationsModel> stockLocationsByUserList =
      (response as List).map((data) => StockLocationsModel.fromJson(data)).toList();

      return stockLocationsByUserList;
    } catch (e) {
      print("Error fetching stock locations by user: $e");
      rethrow;
    }
  }

  Future<List<StockLocationsModel>> getStkLocations() async {
    try {
      final String url = "${AppUrls.getStkLocationsUrl}";
      print('Get Stock Locations URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print('Get Stock Locations Response: $response');

      // Assuming response is a List of category master objects
      List<StockLocationsModel> stockLocationsList =
      (response as List).map((data) => StockLocationsModel.fromJson(data)).toList();

      return stockLocationsList;
    } catch (e) {
      print("Error fetching stock locations: $e");
      rethrow;
    }
  }

  Future<List<ItemSalesDetailsModel>> fetchItemSalesDetails(int itemId, String date, String locationId) async {
    try {
      final String url = "${AppUrls.getItemSalesDetailsUrl}?itemId=$itemId&stockDate=$date&locationId=$locationId";
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
}
