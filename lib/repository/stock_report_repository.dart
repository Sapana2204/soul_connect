import 'package:flutter_soulconnect/model/Expiry_report_model.dart';

import 'package:flutter/cupertino.dart';

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/itemLedgerReport_model.dart';
import '../model/purchaseReportDetails_model.dart';
import '../model/salesReportDetails_model.dart';
import '../model/stock_report_model.dart';
import '../res/widgets/app_urls.dart';

class StockRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<StockReportModel>> fetchStockReportApi({
    required String fromDate,
    required String toDate,
    int? itemId,
    int? categoryId,
    int? locationId,
  }) async {
    try {
      String url = AppUrls.getstockReportUrl(fromDate, toDate);

      List<String> queryParams = [];
      if (itemId != null) queryParams.add("ItemId=$itemId");
      if (categoryId != null) queryParams.add("CategoryId=$categoryId");
      if (locationId != null) queryParams.add("locationId=$locationId");

      if (queryParams.isNotEmpty) {
        url += "?${queryParams.join("&")}";
      }

      print('Final Filtered URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      /// API response is MAP
      Map<String, dynamic> json = response;

      /// List is inside StockStatementDTO
      List list = json['StockStatementDTO'] ?? [];

      return list
          .map((data) => StockReportModel.fromJson(data))
          .toList();

    } catch (e) {
      rethrow;
    }
  }

  Future<List<ExpiryReportModel>> fetchExpiryReport({
    required String fromDate,
    required String toDate,
    int? locationId, // ✅ optional
  }) async {
    try {
      String url =
          "${AppUrls.baseUrl}/Dashboard/expiring?StockFromDate=$fromDate&StockToDate=$toDate";

      /// ✅ Add optional param
      if (locationId != null) {
        url += "&LocationId=$locationId";
      }

      print("Final Expiring URL: $url");

      dynamic response = await _apiServices.getGetApiResponse(url);

      /// ✅ Response is LIST
      List list = response;

      return list
          .map((e) => ExpiryReportModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PurchaseReportDetailsModel>> fetchPurchaseDetailsReport({
    required int userId,
    required int locationId,
    required int itemId,
  }) async {
    try {
      final queryParameters = {
        'userId': userId.toString(),
        'locationId': locationId.toString(),
        'ItemId': itemId.toString(),
      };

      final uri = Uri.parse(AppUrls.phPurchaseDetailsReport).replace(queryParameters: queryParameters);
      final response = await _apiServices.getGetApiResponse(uri.toString());

      if (response != null && response is List) {
        return response.map((e) => PurchaseReportDetailsModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Purchase Details Report API Error: $e");
      return [];
    }
  }

  Future<List<SalesDetailsReportModel>> fetchSalesDetailsReport({
    required int userId,
    required int locationId,
    required int itemId,
  }) async {
    try {
      final queryParameters = {
        'userId': userId.toString(),
        'locationId': locationId.toString(),
        'ItemId': itemId.toString(),
      };

      final uri = Uri.parse(AppUrls.phSalesDetailsReport).replace(queryParameters: queryParameters);
      final response = await _apiServices.getGetApiResponse(uri.toString());

      if (response != null && response is List) {
        return response.map((e) => SalesDetailsReportModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Sales Details Report API Error: $e");
      return [];
    }
  }

  Future<List<ItemLedgerReportModel>> fetchItemLedgerReportApi({
    required String stockFromDate,
    required String stockToDate,
    int? itemId,
  }) async {
    try {
      // Base URL
      String url = AppUrls.itemLedgerReport;

      // Query params
      final queryParams = <String>[];

      if (itemId != null) queryParams.add("itemId=$itemId");

      queryParams.add("stockFromDate=$stockFromDate");
      queryParams.add("stockToDate=$stockToDate");

      if (queryParams.isNotEmpty) {
        url += "?${queryParams.join("&")}";
      }

      debugPrint("📌 Item Ledger Final URL: $url");

      dynamic response = await _apiServices.getGetApiResponse(url);

      if (response != null && response is List) {
        return response
            .map((e) => ItemLedgerReportModel.fromJson(e))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint("❌ Item Ledger API Error: $e");
      rethrow;
    }
  }


}