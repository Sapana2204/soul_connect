

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/get_all_tax_group_model.dart';
import '../model/ledger_bal_model.dart';
import '../model/ledger_type_model.dart';
import '../model/party_model.dart';

import '../res/widgets/app_urls.dart';


class PurchaseInvoiceRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<PartyModel>> fetchPurchaseParty() async {
    try {
      final String url = AppUrls.getPurchasePartyUrl;
      print('Get Purchase Party URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print('Get Purchase Party Response: $response');

      // Assuming response is a List of category master objects
      List<PartyModel> partyList =
      (response as List).map((data) => PartyModel.fromJson(data)).toList();

      return partyList;
    } catch (e) {
      print("Error fetching purchase party: $e");
      rethrow;
    }
  }

  Future<LedgerBalModel> fetchLedgerBalance({
    required int ledgerId,
    required String balanceAsOn,
    required String balanceType,
  }) async {
    try {
      final String url =
          "${AppUrls.getLedgerBalanceUrl}/$ledgerId/$balanceAsOn?balanceType=T";
      print("Ledger Balance API URL: $url");

      dynamic response = await _apiServices.getGetApiResponse(url);

      print("Ledger Balance API Response: $response");

      return LedgerBalModel.fromJson(response);
    } catch (e) {
      print("Error fetching Ledger Balance: $e");
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

  Future<dynamic> addPurchaseApi(Map<String, dynamic> data) async {
    try {
      final String url = "${AppUrls.addPurchase}";
      print("Add Purchase API URL: $url");
      print("Request Body: $data");

      dynamic response = await _apiServices.getPostApiResponse(url, data);
      print("Add Purchase API Response: $response");

      return response;
    } catch (e) {
      print("Error in addPurchaseApi: $e");
      rethrow;
    }
  }

  Future<List<TaxGroupPercentageModel>> fetchTaxGroupPercentage() async {
    try {
      final String url = AppUrls.getAllTaxGroupPercentageUrl;
      print('Get Tax Group Percentage URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);
      print('Get Tax Group Percentage Response: $response');

      List<TaxGroupPercentageModel> taxGroupList = (response as List)
          .map((data) => TaxGroupPercentageModel.fromJson(data))
          .toList();

      return taxGroupList;
    } catch (e) {
      print("Error fetching Tax Group Percentage: $e");
      rethrow;
    }
  }


}




