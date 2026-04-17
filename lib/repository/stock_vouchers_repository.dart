import 'package:flutter_soulconnect/model/get_expiry_model.dart';
import 'package:flutter_soulconnect/model/issue_vch_request_model.dart';

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/expiring_item_model.dart';
import '../model/stock_inward_model.dart';
import '../model/stock_inward_request_model.dart';
import '../model/stock_issue_Inward_model.dart';
import '../model/stock_issue_model.dart';
import '../res/widgets/app_urls.dart';

class StockVouchersRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  /// Get all stock issues
  Future<List<StockIssueModel>> fetchStockIssues() async {
    try {
      final String url = AppUrls.getStockIssue; // create this url
      final response = await _apiServices.getGetApiResponse(url);

      return (response as List)
          .map((e) => StockIssueModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addIssueVch(IssueVchRequestModel request) async {
    try {
      final String url = AppUrls.addStockIssue;

      final response = await _apiServices.getPostApiResponse(
        url,
        request.toJson(),
      );

      return response["message"] ?? "Stock Issue Created";
    } catch (e) {
      rethrow;
    }
  }

  Future<String> updateIssueVch(IssueVchRequestModel request) async {
    try {
      final String url = AppUrls.updateStockIssue;

      final response = await _apiServices.getPostApiResponse(
        url,
        request.toJson(),
      );

      return response["message"] ?? "Stock Issue Created";
    } catch (e) {
      rethrow;
    }
  }

  Future<String> deleteStockIssue(int issueId) async {
    try {
      final url = "${AppUrls.deleteStockIssue}?issueId=$issueId";

      final response = await _apiServices.getDeleteApiResponse(url);

      return response["message"];

    } catch (e) {
      rethrow;
    }
  }

  /// Get Stock Inwards
  Future<List<StockInwardModel>> fetchStockInwards() async {
    try {
      final String url = AppUrls.getStockInward;
      final response = await _apiServices.getGetApiResponse(url);

      return (response as List)
          .map((e) => StockInwardModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get Stock Issue For Inward by LocationId
  Future<List<StockIssueForInwardModel>> fetchStockIssueForInward(int locationId) async {
    try {

      final String url =
          "${AppUrls.getStockIssueForInward}?locationId=$locationId";

      final response = await _apiServices.getGetApiResponse(url);

      return (response as List)
          .map((e) => StockIssueForInwardModel.fromJson(e))
          .toList();

    } catch (e) {
      rethrow;
    }
  }

  Future<String> addStockInwardVch(StockInwardRequestModel request) async {
    try {
      final String url = AppUrls.addStockInward;

      final response = await _apiServices.getPostApiResponse(
        url,
        request.toJson(),
      );

      return response["message"] ?? "Stock Inward Created";
    } catch (e) {
      rethrow;
    }
  }

  Future<String> deleteStockInward(int inwardId) async {
    try {
      final url = "${AppUrls.deleteStockInward}?inwardId=$inwardId";

      final response = await _apiServices.getDeleteApiResponse(url);

      return response["message"];

    } catch (e) {
      rethrow;
    }
  }

  Future<List<ExpiryModel>> fetchExpiryVch() async {
    try {
      final String url = AppUrls.getExpiryVoucher; // create this url
      final response = await _apiServices.getPostApiResponse(url,"");

      return (response as List)
          .map((e) => ExpiryModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> deleteExpiryVch(int expiryId) async {
    try {
      final url = "${AppUrls.deleteExpiryVoucher}?expiryId=$expiryId";

      final response = await _apiServices.getPostApiResponse(url, "");

      if (response == true) {
        return "Deleted successfully";
      } else {
        return "Delete failed";
      }

    } catch (e) {
      throw Exception("Delete failed");
    }
  }

  Future<List<ExpiringItemModel>> fetchExpiringItems({
    required String stockFromDate,
    required String stockToDate,
    required String expDate,
  }) async {
    try {

      final String url =
          "${AppUrls.getExpiringDashboard}?StockFromDate=$stockFromDate&StockToDate=$stockToDate&ExpDate=$expDate";

      print("Expiring Items URL: $url");
      final response = await _apiServices.getGetApiResponse(url);

      return (response as List)
          .map((e) => ExpiringItemModel.fromJson(e))
          .toList();

    } catch (e) {
      rethrow;
    }
  }

  Future<String> addExpiryVch(ExpiryModel request) async {
    try {
      final String url = AppUrls.addExpiryVoucher; // create this URL

      final response = await _apiServices.getPostApiResponse(
        url,
        request.toJson(),
      );

      return response["Message"] ?? "Expiry Created Successfully";
    } catch (e) {
      rethrow;
    }
  }

  Future<String> updateExpiryVch(ExpiryModel request) async {
    try {
      final String url = AppUrls.updateExpiryVch;

      final response = await _apiServices.getPostApiResponse(
        url,
        request.toJson(),
      );

      return response["message"] ?? "Expiry Voucher Updated";
    } catch (e) {
      rethrow;
    }
  }
}