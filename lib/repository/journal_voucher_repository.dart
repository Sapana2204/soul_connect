

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/add_vouchers_model.dart';
import '../model/ledger_type_model.dart';
import '../res/widgets/app_urls.dart';

class JournalVoucherRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  // ---------------- LEDGERS ----------------

  Future<List<LedgerTypeModel>> fetchAccLedgersByGroupId(
      int groupId) async {
    final url =
        "${AppUrls.getAccLedgersByGroupId}?groupId=$groupId";
    final response =
    await _apiServices.getGetApiResponse(url);

    return (response as List)
        .map((e) => LedgerTypeModel.fromJson(e))
        .toList();
  }

  // ---------------- GET ALL JOURNAL ----------------

  Future<dynamic> fetchAllJournalVouchers(
      Map<String, dynamic> body) async {
    return await _apiServices.getPostApiResponse(
        AppUrls.getVouchersUrl, body);
  }

  // ---------------- ADD ----------------

  Future<dynamic> addJournalVoucher(
      AddVouchersModel model) async {
    return await _apiServices.getPostApiResponse(
        AppUrls.addVouchersUrl, model.toJson());
  }

  // ---------------- UPDATE ----------------

  Future<dynamic> updateJournalVoucher(
      AddVouchersModel model) async {
    return await _apiServices.getPostApiResponse(
        AppUrls.updateVouchersUrl, model.toJson());
  }

  // ---------------- DELETE ----------------

  Future<bool> deleteJournalVoucher(int vchId) async {
    final url = AppUrls.deleteVouchersUrl
        .replaceAll("{id}", vchId.toString());

    try {
      await _apiServices.getDeleteApiResponse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ---------------- LEDGER TYPE ----------------

  Future<List<LedgerTypeModel>> fetchLedgerAccounts(
      String ledgerType) async {
    try {
      final String url =
      AppUrls.getLedgerType(ledgerType);

      final response =
      await _apiServices.getGetApiResponse(url);

      return (response as List)
          .map((e) => LedgerTypeModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
