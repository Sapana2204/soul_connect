import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/get_users_model.dart';
import '../model/receipt_model.dart';
import '../model/sales_itemwise_report_request.dart';
import '../model/sales_summary_by_user_model.dart';
import '../model/user_model.dart';
import '../res/widgets/app_urls.dart';

class SalesReportRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> fetchSalesItemwiseReport(SalesItemwiseReportRequest request) async {
    try {
      final uri = Uri.parse("${AppUrls.baseUrl}/report/phsalesdetailreport")
          .replace(queryParameters: request.toQueryParams());

      print("🔹 Fetching Sales Itemwise Report: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());
      print("Sales Itemwise Report Response: $response");

      return response;
    } catch (e) {
      print("❌ Error fetching Sales Itemwise Report: $e");
      rethrow;
    }
  }

  Future<dynamic> fetchSalesStmt(SalesItemwiseReportRequest request) async {
    try {
      final uri = Uri.parse("${AppUrls.baseUrl}/report/phsalessummaryreport")
          .replace(queryParameters: request.toQueryParams());

      print("🔹 Fetching Sales Itemwise Report: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());
      print("Sales Item Stmt Report Response: $response");

      return response;
    } catch (e) {
      print("❌ Error fetching Sales Itemwise Report: $e");
      rethrow;
    }
  }

  Future<dynamic> fetchCustomerForCustomerStatement({
    required String partyType,
    int? partyId,
  }) async {
    try {
      final base = "${AppUrls.baseUrl}/party/$partyType";

      final queryParams = {
        "partyType": partyType,   // 🔥 ADD THIS (IMPORTANT)
      };

      if (partyId != null) {
        queryParams["PartyId"] = partyId.toString();
      }

      final uri = Uri.parse(base).replace(queryParameters: queryParams);

      print("🔹 Fetching Customer List For Statement: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());
      print("✅ Customer List Response: $response");

      return response;
    } catch (e) {
      print("❌ Error fetching Customer List: $e");
      rethrow;
    }
  }

  Future<dynamic> fetchCustomerStatementSummary({
    required String fromDate,
    required String toDate,
    int? customerId,
    int? userId,
    String? customerName
  }) async {
    try {
      final uri = Uri.parse(AppUrls.customerStatementSummary).replace(
        queryParameters: {
          "fromDate": fromDate,
          "toDate": toDate,
          if (customerId != null) "customerId": customerId.toString(),
          if (userId != null) "userId": userId.toString(),
          if (customerName != null) "customerName": customerName,
        },
      );

      print("🔹 Fetching Customer Statement Summary: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());
      print("Customer Statement Summary Response: $response");

      return response;
    } catch (e) {
      print("Error fetching Customer Statement Summary: $e");
      rethrow;
    }
  }

  Future<List<ReceiptModel>> fetchReceipts({
    required String fromDate,
    required String toDate,
    required int ledgerId,
    required int userId,
  }) async {
    try {
      final String url = AppUrls.getReceiptReport;

      final body = {
        "FromDate": fromDate,
        "ToDate": toDate,
        "LedgerId": ledgerId,
        "UserId": userId,
      };

      print("🔹 Fetching Receipts (POST): $body");

      final response =
      await _apiServices.getPostApiResponse(url, body);

      return (response as List)
          .map((e) => ReceiptModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SalesSummaryModel>> fetchSalesSummaryByUser({
    required int userId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final uri = Uri.parse("${AppUrls.baseUrl}/report/getPhSalesSummaryByUserReport")
          .replace(queryParameters: {
        "userId": userId.toString(),
        "salesFromDate": fromDate,
        "salesToDate": toDate,
      });

      print("🔹 Fetching Sales Summary By User: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());

      print("Sales Summary Response: $response");

      return (response as List)
          .map((e) => SalesSummaryModel.fromJson(e))
          .toList();
    } catch (e) {
      print("❌ Error fetching Sales Summary: $e");
      rethrow;
    }
  }

  Future<List<GetUsersModel>> fetchUsers() async {
    try {
      final uri = Uri.parse("${AppUrls.baseUrl}/user/api/user");

      print("🔹 Fetching Users: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());

      print("✅ Users Response: $response");

      return (response as List)
          .map((e) => GetUsersModel.fromJson(e))
          .toList();
    } catch (e) {
      print("❌ Error fetching users: $e");
      rethrow;
    }
  }
}
