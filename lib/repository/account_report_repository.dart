import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/dayBookReport_model.dart';
import '../model/dayBookSummaryReport_model.dart';
import '../model/get_users_model.dart';
import '../model/ledger_bal_model.dart';
import '../model/ledger_report_request.dart';
import '../model/ledger_type_model.dart';
import '../model/outstanding_report_model.dart';
import '../model/profitLossReport_model.dart';

import '../res/widgets/app_urls.dart';

class AccountReportRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<LedgerTypeModel>> fetchLedgername() async {
    try {
      final String url = AppUrls.getAccLedgersByGroupId;
      print('Get ledgernames URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print('Get Ledgernames Response: $response');

      // Assuming response is a List of category master objects
      List<LedgerTypeModel> ledgernamesList =
      (response as List).map((data) => LedgerTypeModel.fromJson(data)).toList();

      return ledgernamesList;
    } catch (e) {
      print("Error fetching ledgernames: $e");
      rethrow;
    }
  }

  Future<dynamic> fetchLedgerReport(LedgerReportRequest request) async {
    try {
      final uri = Uri.parse("${AppUrls.baseUrl}/report/ledgerreport")
          .replace(queryParameters: request.toQueryParams());

      print("🔹 Fetching Ledger Report: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());
      print("Ledger Report Response: $response");

      return response;
    } catch (e) {
      print("❌ Error fetching Ledger Report: $e");
      rethrow;
    }
  }

  Future<LedgerBalModel> fetchOpeningClosingBalance({
    required int ledgerId,
    required String balanceAsOn,
    required String balanceType,
  }) async {
    try {
      final String url = AppUrls.getOpeningClosingBalance(
        ledgerId: ledgerId,
        balanceAsOn: balanceAsOn,
        balanceType: balanceType,
      );

      print("🔹 Ledger Balance URL: $url");

      final response = await _apiServices.getGetApiResponse(url);

      print("🔹 Ledger Balance Response: $response");

      return LedgerBalModel.fromJson(response);
    } catch (e) {
      print("❌ Error fetching ledger balance: $e");
      rethrow;
    }
  }

  // --- Live API Method (Swap with this for production) ---
  Future<List<OutstandingModel>> fetchOutstandingReport(String date, int groupId) async {
    try {
      final String url = AppUrls.getOutstandingReport(date, groupId);
      final response = await _apiServices.getGetApiResponse(url);

      return (response as List)
          .map((e) => OutstandingModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ProfitLossModel> fetchProfitLossReport({
    required String salesFromDate,
    required String salesToDate,
    int? customerId,
    String? salesType,
  }) async {
    try {
      final uri = Uri.parse(AppUrls.profitLossReport).replace(
        queryParameters: {
          "SalesFromDate": salesFromDate,
          "SalesToDate": salesToDate,
          if (customerId != null) "CustomerId": customerId.toString(),
          if (salesType != null && salesType.isNotEmpty) "SalesType": salesType,
        },
      );

      print("🔹 Profit Loss Report URL: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());

      print("🔹 Profit Loss Report Response: $response");

      return ProfitLossModel.fromJson(response);
    } catch (e) {
      print("❌ Error fetching Profit Loss Report: $e");
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

  Future<List<DayBookReportModel>> fetchDayBookReport({
    required String fromDate,
    required String toDate,
    required int userId,
  }) async {
    try {
      final uri = Uri.parse("${AppUrls.baseUrl}/report/daybookreport").replace(
        queryParameters: {
          "fromDate": fromDate,
          "toDate": toDate,
          "userId": userId.toString(),
        },
      );

      print("🔹 DayBook Report URL: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());

      print("🔹 DayBook Report Response: $response");

      return (response as List)
          .map((e) => DayBookReportModel.fromJson(e))
          .toList();
    } catch (e) {
      print("❌ Error fetching DayBook Report: $e");
      rethrow;
    }
  }

  Future<List<DayBookSummaryReportModel>> fetchDayBookSummaryReport({
    required String fromDate,
    required String toDate,
    required int userId,
  }) async {
    try {
      final uri =
      Uri.parse("${AppUrls.baseUrl}/report/daybooksummaryreport").replace(
        queryParameters: {
          "fromDate": fromDate,
          "toDate": toDate,
          "userId": userId.toString(),
        },
      );

      print("🔹 DayBook Summary URL: $uri");

      final response = await _apiServices.getGetApiResponse(uri.toString());

      print("🔹 DayBook Summary Response: $response");

      return (response as List)
          .map((e) => DayBookSummaryReportModel.fromJson(e))
          .toList();
    } catch (e) {
      print("❌ Error fetching DayBook Summary: $e");
      rethrow;
    }
  }




}