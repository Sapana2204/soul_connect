import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/add_vouchers_model.dart';
import '../model/ledger_type_model.dart';

import '../res/widgets/app_urls.dart';

class PaymentVoucherRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<LedgerTypeModel>> fetchAccLedgersByGroupId(int groupId) async {
    try {
      final String url = "${AppUrls.getAccLedgersByGroupId}?groupId=$groupId";
      print('Fetching ledgers with Group ID: $groupId | URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);
      print('Response: $response');

      return (response as List)
          .map((data) => LedgerTypeModel.fromJson(data))
          .toList();
    } catch (e) {
      print("Error fetching ledgers for groupId $groupId: $e");
      rethrow;
    }
  }

  Future<dynamic> addVoucher(AddVouchersModel model) async {
    try {
      final String url = AppUrls.addVouchersUrl;
      print('🔹 Hitting add vouchers API: $url');
      print('🔹 Request Body: ${model.toJson()}');

      dynamic response = await _apiServices.getPostApiResponse(url, model.toJson());
      print('API Response: $response');
      return response;
    } catch (e) {
      print('Error in addVoucher API: $e');
      rethrow;
    }
  }

  Future<dynamic> fetchAllVouchers(Map<String, dynamic> body) async {
    try {
      final String url = AppUrls.getVouchersUrl;

      print("🔹 Hitting GET ALL VOUCHERS API: $url");
      print("🔹 Request Body: $body");

      final response = await _apiServices.getPostApiResponse(url, body);
      print("✅ API Response: $response");

      return response;
    } catch (e) {
      print("❌ Error fetching all vouchers: $e");
      rethrow;
    }
  }

  Future<dynamic> updateVoucher(AddVouchersModel model) async {
    try {
      final String url = AppUrls.updateVouchersUrl;
      print('🔹 Hitting update vouchers API: $url');
      print('🔹 Request Body: ${model.toJson()}');

      dynamic response = await _apiServices.getPostApiResponse(url, model.toJson());
      print('API Response: $response');
      return response;
    } catch (e) {
      print('Error in addVoucher API: $e');
      rethrow;
    }
  }

  Future<bool> deleteVoucher(int vchId) async {
    final url = AppUrls.deleteVouchersUrl.replaceAll("{id}", vchId.toString());
    print("Calling DELETE Voucher API via NetworkApiServices: $url");

    try {
      final response = await _apiServices.getDeleteApiResponse(url);
      print("Delete response: $response");

      if (response is Map && response['message'] != null) {
        print("Server message: ${response['message']}");
      }

      return true;
    } catch (e) {
      print("Delete Voucher failed: $e");
      return false;
    }
  }
}
