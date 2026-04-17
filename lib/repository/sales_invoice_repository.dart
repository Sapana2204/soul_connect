import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../database/app_database.dart';
import '../model/bill_types_model.dart';
import '../model/get_all_tax_group_model.dart';
import '../model/ledger_bal_model.dart';
import '../model/party_model.dart';
import '../model/rate_type_model.dart';
import '../res/widgets/app_urls.dart';
import 'package:drift/drift.dart';

class SalesInvoiceRepository {
  final BaseApiServices _apiServices = NetworkApiServices();
  // final AppDatabase _db = AppDatabase();
  final AppDatabase _db = AppDatabase.instance;

  Future<List<PartyModel>> fetchParty() async {
    try {
      final String url = AppUrls.getPartyUrl;
      print('Get Party URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print('Get Party Response: $response');

      // Assuming response is a List of category master objects
      List<PartyModel> partyList =
      (response as List).map((data) => PartyModel.fromJson(data)).toList();

      return partyList;
    } catch (e) {
      print("Error fetching party: $e");
      rethrow;
    }
  }

  Future<List<RateTypesModel>> fetchRateType() async {
    List<RateTypesModel> apiList = [];

    try {
      // 1. Get Network Data
      final String url = AppUrls.getRateTypeUrl;
      print("[RateType] Repository: Calling API URL: $url");
      dynamic response = await _apiServices.getGetApiResponse(url);
      print("[RateType] Repository: Raw API response type: ${response.runtimeType}");
      print("[RateType] Repository: Raw API response: $response");
      apiList = (response as List).map((e) => RateTypesModel.fromJson(e)).toList();
      print("[RateType] Repository: Parsed ${apiList.length} rate types from API");
      for (var rt in apiList) {
        print("[RateType] Repository: -> id=${rt.rateTypeId}, rateType=${rt.rateType}, display=${rt.rateTypeDisplay}");
      }

      // 2. Try to sync with Local DB (wrapped in its own try-catch so it doesn't break the flow)
      try {
        final driftList = apiList.map((e) => RateTypesCompanion(
          rateTypeId: Value(e.rateTypeId ?? 0),
          rateType: Value(e.rateType),
          rateTypeDisplay: Value(e.rateTypeDisplay),
        )).toList();

        await _db.clearRateTypes();
        await _db.insertRateTypes(driftList);
        print("[RateType] Repository: DB sync successful");
      } catch (dbError) {
        print("[RateType] Repository: DB sync failed: $dbError");
      }

      print("[RateType] Repository: Returning ${apiList.length} rate types from API");
      return apiList;

    } catch (e) {
      print("[RateType] Repository: API FAILED with error: $e");
      print("[RateType] Repository: Falling back to local DB");
      // Only fetch from DB if the Network call itself failed
      final localData = await _db.getAllRateTypes();
      print("[RateType] Repository: Got ${localData.length} rate types from local DB");
      return localData.map((e) => RateTypesModel(
        rateTypeId: e.rateTypeId,
        rateType: e.rateType,
        rateTypeDisplay: e.rateTypeDisplay,
      )).toList();
    }
  }
  // Future<List<RateTypesModel>> fetchRateType() async {
  //   try {
  //     final String url = AppUrls.getRateTypeUrl;
  //     dynamic response = await _apiServices.getGetApiResponse(url);
  //
  //     List<RateTypesModel> apiList =
  //     (response as List).map((e) => RateTypesModel.fromJson(e)).toList();
  //
  //     // Convert to Drift Companion
  //     final driftList = apiList.map((e) {
  //       return RateTypesCompanion(
  //         rateTypeId: Value(e.rateTypeId ?? 0),
  //         rateType: Value(e.rateType),
  //         rateTypeDisplay: Value(e.rateTypeDisplay),
  //       );
  //     }).toList();
  //
  //     await _db.clearRateTypes();
  //     await _db.insertRateTypes(driftList);
  //
  //     return apiList;
  //   } catch (e) {
  //     print("API failed, loading from local DB");
  //
  //     final localData = await _db.getAllRateTypes();
  //
  //     return localData.map((e) {
  //       return RateTypesModel(
  //         rateTypeId: e.rateTypeId,
  //         rateType: e.rateType,
  //         rateTypeDisplay: e.rateTypeDisplay,
  //       );
  //     }).toList();
  //   }
  // }


  Future<List<BillTypesModel>> fetchBillype() async {
    try {
      final String url = AppUrls.getBillTypeUrl;
      dynamic response = await _apiServices.getGetApiResponse(url);

      List<BillTypesModel> apiList =
      (response as List).map((e) => BillTypesModel.fromJson(e)).toList();

      // Separate DB logic so a DB lock doesn't hide an API success
      try {
        final driftList = apiList.map((e) {
          return BillTypesCompanion(
            billTypeId: Value(e.billTypeId ?? 0),
            billType: Value(e.billType),
            prefix: Value(e.prefix),
            includeFinancialYear: Value(e.includeFinancialYear),
            salesQuotation: Value(e.salesQuotation),
          );
        }).toList();

        await _db.clearBillTypes();
        await _db.insertBillTypes(driftList);
      } catch (dbError) {
        print("API worked, but DB Sync failed: $dbError");
      }

      return apiList;
    } catch (e) {
      print("API failed, loading BillType from local DB");
      final localData = await _db.getAllBillTypes();

      return localData.map((e) {
        return BillTypesModel(
          billTypeId: e.billTypeId,
          billType: e.billType,
          prefix: e.prefix,
          includeFinancialYear: e.includeFinancialYear,
          salesQuotation: e.salesQuotation,
        );
      }).toList();
    }
  }
  // Future<List<BillTypesModel>> fetchBillype() async {
  //   try {
  //     final String url = AppUrls.getBillTypeUrl;
  //     dynamic response = await _apiServices.getGetApiResponse(url);
  //
  //     List<BillTypesModel> apiList =
  //     (response as List).map((e) => BillTypesModel.fromJson(e)).toList();
  //
  //     final driftList = apiList.map((e) {
  //       return BillTypesCompanion(
  //         billTypeId: Value(e.billTypeId ?? 0),
  //         billType: Value(e.billType),
  //         prefix: Value(e.prefix),
  //         includeFinancialYear: Value(e.includeFinancialYear),
  //         salesQuotation: Value(e.salesQuotation),
  //       );
  //     }).toList();
  //
  //     await _db.clearBillTypes();
  //     await _db.insertBillTypes(driftList);
  //
  //     return apiList;
  //   } catch (e) {
  //     print("API failed, loading BillType from local DB");
  //
  //     final localData = await _db.getAllBillTypes();
  //
  //     return localData.map((e) {
  //       return BillTypesModel(
  //         billTypeId: e.billTypeId,
  //         billType: e.billType,
  //         prefix: e.prefix,
  //         includeFinancialYear: e.includeFinancialYear,
  //         salesQuotation: e.salesQuotation,
  //       );
  //     }).toList();
  //   }
  // }

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
