
import 'package:intl/intl.dart';

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/itemDetailsForPurchaseReturn_model.dart';
import '../model/purchaseReturnDashboard_model.dart';

import '../model/stockItemsForPurchaseReturn_model.dart';
import '../res/widgets/app_urls.dart';

class PurchaseReturnRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<PurchaseReturnDashboardModel>> fetchPurchaseReturn({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final String url =
      AppUrls.getPurchaseReturn(fromDate, toDate);

      print('Get PurchaseReturn URL: $url');

      final response = await _apiServices.getGetApiResponse(url);

      print('Get PurchaseReturn Response: $response');

      return (response as List)
          .map((e) => PurchaseReturnDashboardModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Error fetching purchaseReturn: $e");
      rethrow;
    }
  }

  Future<PurchaseReturnDashboardModel> getPurchaseReturnById(int id) async {
    try {
      final String url = "${AppUrls.getPurchaseReturnById}/$id";
      print('Fetching Purchase By id URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      // The API returns a list, take the first element
      if (response is List && response.isNotEmpty) {
        return PurchaseReturnDashboardModel.fromJson(response[0]);
      } else {
        throw Exception("No purchase return found for ID $id");
      }
    } catch (e) {
      print("Error fetching purchaseReturn by ID: $e");
      rethrow;
    }
  }



  Future<List<StockItemsForPurchaseReturnModel>> getStockItemsForPurchaseReturn({
    required int locationId,
    required int supplierId,
    DateTime? stockDate,
  }) async {
    try {
      final date = stockDate ?? DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final String url =
          "${AppUrls.getStockItemsForPurchaseReturn}"
          "?stockDate=$formattedDate&locationId=$locationId&supplierId=$supplierId";

      dynamic response = await _apiServices.getGetApiResponse(url);

      return (response as List)
          .map((e) => StockItemsForPurchaseReturnModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Error fetching StockItemsForPurchaseReturn : $e");
      rethrow;
    }
  }


  Future<List<ItemDetailsForPurchaseReturnModel>> getItemDetailsForPurchaseReturn({
    required int locationId,
    required int itemId,
    required int partyId,
    DateTime? stockDate,
  }) async {
    try {
      final date = stockDate ?? DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final String url =
          "${AppUrls.getItemDetailsForPurchaseReturn}"
          "?stockDate=$formattedDate"
          "&locationId=$locationId"
          "&supplierId=$partyId";

      print('Fetching getItemDetailsForPurchaseReturn URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      // ✅ response is List
      return (response as List)
          .map((e) => ItemDetailsForPurchaseReturnModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Error fetching getItemDetailsForPurchaseReturn : $e");
      rethrow;
    }
  }

  Future<dynamic> addPurchaseReturnApi(Map<String, dynamic> data) async {
    try {
      final String url = "${AppUrls.addPurchaseReturn}";
      print("Add Purchase Return API URL: $url");
      print("Request Body: $data");

      dynamic response = await _apiServices.getPostApiResponse(url, data);
      print("Add Purchase Return API Response: $response");

      return response;
    } catch (e) {
      print("Error in addPurchaseReturnApi: $e");
      rethrow;
    }
  }

  Future<bool> deletePurchaseReturn(int id) async {
    final url = AppUrls.deletePurchaseReturn.replaceAll("{id}", id.toString());

    print("📤 Calling DELETE API: $url");

    try {
      final response = await _apiServices.getDeleteApiResponse(url);

      print("📥 DELETE Response: $response");

      // The API may return a string or a JSON object with message
      if (response is Map && response["Message"] != null) {
        print("✅ ${response["Message"]}");
        return true;
      }

      return true; // fallback success for 200/204
    } catch (e) {
      print("🚫 Error calling deletePurchase API: $e");
      return false;
    }
  }

  // 🔹 Update purchase API call
  Future<dynamic> updatePurchaseReturn(Map<String, dynamic> requestData) async {
    try {
      final response = await _apiServices.getPostApiResponse(
        AppUrls.updatePurchaseReturn,
        requestData,
      );
      return response;
    } catch (e) {
      throw Exception("Update Purchase Return failed: $e");
    }
  }


}

