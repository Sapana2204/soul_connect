

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';

import '../model/sales_return_dashboard_model.dart';
import '../res/widgets/app_urls.dart';
import 'package:http/http.dart' as http;

class SalesReturnDashboardRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<SalesReturnDashboardModel>> fetchSalesReturnByDateApi(String fromDate, String toDate) async {
    try {
      final String url = AppUrls.getSalesReturn(fromDate, toDate);
      final response = await _apiServices.getGetApiResponse(url);

      return (response as List)
          .map((e) => SalesReturnDashboardModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<SalesReturnDashboardModel> getSalesReturnById(int id) async {
    try {
      final String url = "${AppUrls.getSalesReturnById}$id";
      print('Fetching Sales Returns By id URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print("Response runtimeType: ${response.runtimeType}");
      print("Response data: $response");

      // 🔴 FIX: API returns LIST
      if (response is List && response.isNotEmpty) {
        return SalesReturnDashboardModel.fromJson(response.first);
      } else {
        throw Exception("Invalid response format for SalesReturnById");
      }

    } catch (e) {
      print("Error fetching sale return by ID: $e");
      rethrow;
    }
  }


  Future<bool> deleteSalesReturn(int returnId) async {
    final url = AppUrls.deleteSalesReturnUrl.replaceAll("{id}", returnId.toString());
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
}

