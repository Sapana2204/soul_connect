import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/sales_return_item_details_model.dart';
import '../model/sales_return_model.dart';
import '../model/sales_return_stock_item_model.dart';
import '../res/widgets/app_urls.dart';

class SalesReturnRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<SalesReturnModel>> fetchSalesReturnApi(String fromDate, String toDate) async {
    try {
      final String url = AppUrls.getSalesReturn(fromDate, toDate);
      final response = await _apiServices.getGetApiResponse(url);

      return (response as List)
          .map((e) => SalesReturnModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 Fetch item list for Sales Return (Customer-wise)
  /// 🔹 Fetch Stock Items for Sales Return
  Future<List<SalesReturnStockItemModel>> getStockItemsForSalesReturn({
    required String stockDate,
    required String locationId,
    required int customerId,
  }) async {
    try {
      final url = AppUrls.getStockPhItemsForSalesReturn(
        stockDate: stockDate,
        locationId: locationId,
        customerId: customerId,
      );

      final response = await _apiServices.getGetApiResponse(url);

      return (response as List)
          .map((e) => SalesReturnStockItemModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 Item details for Sales Return (after product select)
  Future<List<SalesReturnItemDetailsModel>> getItemDetailsForSalesReturn({
    // required int itemId,
    required int locationId,
    required int customerId,
  }) async {
    try {
      final url = AppUrls.getItemDetailsForSalesReturn(
        // itemId: itemId,
        locationId: locationId,
        customerId: customerId,
      );

      final response = await _apiServices.getGetApiResponse(url);

      return (response as List)
          .map((e) => SalesReturnItemDetailsModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// ADD SALES RETURN API
  Future<int?> addSalesReturnApi(Map<String, dynamic> body) async {
    try {
      final response = await _apiServices.getPostApiResponse(
        AppUrls.addSalesReturn,
        body,
      );

      print("Add Sales Return Raw Response: $response");

      // Case 1: API directly returns int
      if (response is int) {
        return response;
      }

      // Case 2: API returns string like "10106"
      if (response is String) {
        return int.tryParse(response);
      }

      // Case 3: API returns map (future-proof safety)
      if (response is Map && response["salesReturnId"] != null) {
        return response["salesReturnId"];
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// ADD SALES RETURN API
  Future<int?> updateSalesReturnApi(Map<String, dynamic> body) async {
    try {
      final response = await _apiServices.getPostApiResponse(
        AppUrls.updateSaleReturnUrl,
        body,
      );

      print("Update Sales Return Raw Response: $response");

      // Case 1: API directly returns int
      if (response is int) {
        return response;
      }

      // Case 2: API returns string like "10106"
      if (response is String) {
        return int.tryParse(response);
      }

      // Case 3: API returns map (future-proof safety)
      if (response is Map && response["salesReturnId"] != null) {
        return response["salesReturnId"];
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }
}