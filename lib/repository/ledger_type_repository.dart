

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/ledger_type_model.dart';
import '../res/widgets/app_urls.dart';

class LedgerRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<LedgerTypeModel>> fetchBankAccounts() async {
    try {
      final String url = "${AppUrls.getLedgerTypeUrl}"; // 🔹 Define this in AppUrls
      print('Get Bank Accounts URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);
      print('Get Bank Accounts Response: $response');

      // Assuming response is a List of bank ledger objects
      List<LedgerTypeModel> bankList =
      (response as List).map((data) => LedgerTypeModel.fromJson(data)).toList();

      return bankList;
    } catch (e) {
      print("Error fetching Bank Accounts: $e");
      rethrow;
    }
  }

  Future<List<LedgerTypeModel>> getFreightPostageLedger() async {
    try {
      final String url = "${AppUrls.getFreightPostageLedgerUrl}"; // 🔹 Define this in AppUrls
      print('Get Freight & postage ledgers URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);
      print('Get Freight & postage ledgers Response: $response');

      // Assuming response is a List of bank ledger objects
      List<LedgerTypeModel> freightPostageLedgerList =
      (response as List).map((data) => LedgerTypeModel.fromJson(data)).toList();

      return freightPostageLedgerList;
    } catch (e) {
      print("Error fetching Bank Accounts: $e");
      rethrow;
    }
  }
}
