import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/add_vouchers_model.dart';
import '../model/ledger_type_model.dart';
import '../res/widgets/app_urls.dart';

class ContraVoucherRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<LedgerTypeModel>> fetchAccLedgersByGroupId(int groupId) async {
    final url = "${AppUrls.getAccLedgersByGroupId}?groupId=$groupId";
    final response = await _apiServices.getGetApiResponse(url);

    return (response as List)
        .map((e) => LedgerTypeModel.fromJson(e))
        .toList();
  }

  Future<dynamic> fetchAllContraVouchers(
      Map<String, dynamic> body) async {
    return await _apiServices.getPostApiResponse(
        AppUrls.getVouchersUrl, body);
  }

  Future<dynamic> addContraVoucher(AddVouchersModel model) async {
    return await _apiServices.getPostApiResponse(
        AppUrls.addVouchersUrl, model.toJson());
  }

  Future<dynamic> updateContraVoucher(AddVouchersModel model) async {
    return await _apiServices.getPostApiResponse(
        AppUrls.updateVouchersUrl, model.toJson());
  }

  Future<bool> deleteContraVoucher(int vchId) async {
    final url =
    AppUrls.deleteVouchersUrl.replaceAll("{id}", vchId.toString());

    try {
      await _apiServices.getDeleteApiResponse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<LedgerTypeModel>> fetchLedgerAccounts(String ledgerType) async {
    try {
      final String url = AppUrls.getLedgerType(ledgerType);
      print('Get Ledger Accounts URL: $url');

      final response = await _apiServices.getGetApiResponse(url);
      print('Get Ledger Accounts Response: $response');

      return (response as List)
          .map((e) => LedgerTypeModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Error fetching ledger accounts: $e");
      rethrow;
    }
  }

}
