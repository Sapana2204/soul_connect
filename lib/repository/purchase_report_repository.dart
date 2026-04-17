import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/purchase_itemwise_report_request.dart';
import '../res/widgets/app_urls.dart';

class PurchaseReportRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> fetchPurchaseItemwiseReport(PurchaseItemwiseReportRequest request) async {
    try {
      final uri = Uri.parse("${AppUrls.baseUrl}/report/phpurchasedetailsreport")
          .replace(queryParameters: request.toQueryParams());

      print("🔹 Fetching Purchase Itemwise Report: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());
      print("Purchase Itemwise Report Response: $response");

      return response;
    } catch (e) {
      print("❌ Error fetching Purchase Itemwise Report: $e");
      rethrow;
    }
  }

  Future<dynamic> fetchPurchaseStmt(PurchaseItemwiseReportRequest request) async {
    try {
      final uri = Uri.parse("${AppUrls.baseUrl}/report/phpurchasesummaryreport")
          .replace(queryParameters: request.toQueryParams());

      print("🔹 Fetching Purchase Summary Report: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());
      print("Purchase Summary Report Response: $response");

      return response;
    } catch (e) {
      print("❌ Error fetching Purchase Summary Report: $e");
      rethrow;
    }
  }

  Future<dynamic> fetchPurchaseReturnStmt({
    required String fromDate,
    required String toDate,
    int? locationId,
  }) async {
    try {
      final queryParams = {
        "purchaseFromDate": fromDate,
        "purchaseToDate": toDate,
        if (locationId != null) "locationId": locationId.toString(),
      };

      final uri = Uri.parse(
        "${AppUrls.baseUrl}/report/getPurchaseReturnSummaryReport",
      ).replace(queryParameters: queryParams);

      print("🔹 Fetching Purchase Return Statement Report: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());

      print("Purchase Return Statement Report Response: $response");

      return response;
    } catch (e) {
      print("❌ Error fetching Purchase Return Statement Report: $e");
      rethrow;
    }
  }

  Future<dynamic> fetchPurchaseReturnItemwise({
    required String fromDate,
    required String toDate,
    int? locationId,
  }) async {
    try {
      final queryParams = {
        "purchaseFromDate": fromDate,
        "purchaseToDate": toDate,
        if (locationId != null) "locationId": locationId.toString(),
      };

      final uri = Uri.parse(
        "${AppUrls.baseUrl}/report/getPurchaseReturnDetailsReport",
      ).replace(queryParameters: queryParams);

      print("🔹 Fetching Purchase Return Itemwise Report: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());

      print("Purchase Return Itemwise Report Response: $response");

      return response;
    } catch (e) {
      print("❌ Error fetching Purchase Return Itemwise Report: $e");
      rethrow;
    }
  }


}
