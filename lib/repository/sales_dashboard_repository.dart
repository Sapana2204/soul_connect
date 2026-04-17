

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/sales_dashboard_model.dart';
import '../res/widgets/app_urls.dart';
import 'package:http/http.dart' as http;

class SalesDashboardRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<SalesDashboardModel>> fetchSalesByDate({
    required String fromDate,
    required String toDate,
    required int userId,
  }) async {
    try {
      final String url = AppUrls.getSalesDashboardUrl(fromDate, toDate, userId);
      print('Fetching Sales By Date URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);
      print('Sales By Date Response: $response');

      // Assuming API returns a list of sales
      List<SalesDashboardModel> salesList =
      (response as List).map((data) => SalesDashboardModel.fromJson(data)).toList();

      return salesList;
    } catch (e) {
      print("Error fetching Sales By Date: $e");
      rethrow;
    }
  }

  Future<SalesDashboardModel> getSalesById(int id) async {
    try {
      final String url = "${AppUrls.getSalesById}/$id";
          print('Fetching Sales By id URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);
      // The API returns a single JSON object, not a list
      return SalesDashboardModel.fromJson(response);
    } catch (e) {
      print("Error fetching sale by ID: $e");
      rethrow;
    }
  }

  Future<bool> deleteSale(int salesId) async {
    final url = AppUrls.deleteSaleUrl.replaceAll("{salesId}", salesId.toString());
    print("Calling DELETE Sale API via NetworkApiServices: $url");

    try {
      final response = await _apiServices.getDeleteApiResponse(url);
      print("Delete response: $response");

      if (response is Map && response['message'] != null) {
        print("Server message: ${response['message']}");
      }

      return true;
    } catch (e) {
      print("Delete sale failed: $e");
      return false;
    }
  }

  Future<dynamic> getInvoicePrintData(int salesId) async {
    try {
      final String url = "${AppUrls.salesInvoicePrintUrl}?salesId=$salesId";
      print("Fetching Invoice Print Data from URL: $url");

      dynamic response = await _apiServices.getGetApiResponse(url);
      print("Invoice Print Response: $response");

      return response; // You can also parse this into a model if needed
    } catch (e) {
      print("Error fetching Invoice Print Data: $e");
      rethrow;
    }
  }

  /// Fetch sales using filter API
  Future<List<SalesDashboardModel>> fetchSalesByFilter({
    required int userId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final String url = "${AppUrls.getSalesByFilter}";

      Map<String, dynamic> payload = {
        "UserId": userId,
        "SalesDate": fromDate,
        "SalesToDate": toDate
      };

      print("Sales Filter URL: $url");
      print("Payload: $payload");

      dynamic response =
      await _apiServices.getPostApiResponse(url, payload);

      print("Sales Filter Response: $response");

      List<SalesDashboardModel> salesList =
      (response as List)
          .map((e) => SalesDashboardModel.fromJson(e))
          .toList();

      return salesList;
    } catch (e) {
      print("Error in fetchSalesByFilter: $e");
      rethrow;
    }
  }
}

