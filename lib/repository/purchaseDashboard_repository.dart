import 'package:flutter_soulconnect/model/purchase_challan_dashboard_model.dart';

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/purchaseDashboard_model.dart';
import '../res/widgets/app_urls.dart';

class PurchaseDashboardRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<PurchaseDashboardModel>> fetchPurchaseDashboards({
    required String fromDate,
    required String toDate,
    required int userId,
  }) async {
    try {
      // Replace path params
      String url = AppUrls.getPurchaseDashboardUrl
          .replaceFirst("{fromDate}", fromDate)
          .replaceFirst("{toDate}", toDate);

      // Add query param for UserId
      url = "$url?UserId=$userId";

      print('Purchase Dashboard URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print('Purchase Dashboard Response: $response');

      // Convert response list into models
      List<PurchaseDashboardModel> purchaseDashboardsList =
      (response as List).map((data) => PurchaseDashboardModel.fromJson(data)).toList();

      return purchaseDashboardsList;
    } catch (e) {
      print("Error fetching Purchase Dashboard: $e");
      rethrow;
    }
  }

  Future<bool> deletePurchase(int id) async {
    final url = AppUrls.deletePurchase.replaceAll("{id}", id.toString());

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
  Future<dynamic> updatePurchase(Map<String, dynamic> requestData) async {
    try {
      final response = await _apiServices.getPostApiResponse(
        AppUrls.updatePurchase,
        requestData,
      );
      return response;
    } catch (e) {
      throw Exception("Update Purchase failed: $e");
    }
  }


  Future<PurchaseDashboardModel> getPurchaseById(int id) async {
    try {
      final String url = "${AppUrls.getPurchaseById}/$id";
      print('Fetching Purchase By id URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);
      // The API returns a single JSON object, not a list
      return PurchaseDashboardModel.fromJson(response);
    } catch (e) {
      print("Error fetching purchase by ID: $e");
      rethrow;
    }
  }

  Future<List<PurchaseChallanDashboardModel>> fetchPurchaseChallans({
    required String fromDate,
    required String toDate,
  }) async {

    try {

      String url = AppUrls.getPurchaseChallans
          .replaceFirst("{fromDate}", fromDate)
          .replaceFirst("{toDate}", toDate);

      print("📤 Purchase Challan URL: $url");

      dynamic response = await _apiServices.getGetApiResponse(url);

      print("📥 Purchase Challan Response: $response");

      List<PurchaseChallanDashboardModel> challanList =
      (response as List)
          .map((data) => PurchaseChallanDashboardModel.fromJson(data))
          .toList();

      return challanList;

    } catch (e) {

      print("❌ Error fetching purchase challans: $e");
      rethrow;

    }
  }

  Future<List<PurchaseDashboardModel>> fetchPurchasesByFilter({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final String url =
          "${AppUrls.getAllPhPurchasesFilter}";

      final Map<String, dynamic> payload = {
        "FromDate": fromDate,
        "ToDate": toDate,
      };

      print("📤 Purchase Filter URL: $url");
      print("📦 Payload: $payload");

      dynamic response =
      await _apiServices.getPostApiResponse(url, payload);

      print("📥 Purchase Filter Response: $response");

      List<PurchaseDashboardModel> purchaseList =
      (response as List)
          .map((data) => PurchaseDashboardModel.fromJson(data))
          .toList();

      return purchaseList;
    } catch (e) {
      print("❌ Error fetching filtered purchases: $e");
      rethrow;
    }
  }
}


