
import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/delivery_challan_model.dart';

import '../model/get_item_unit_converted_model.dart';
import '../model/item_sales_details_model.dart';
import '../model/items_by_product_type.dart';
import '../res/widgets/app_urls.dart';

class DeliveryChallanDashboardRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  // ================= DASHBOARD =================

  Future<List<DeliveryChallanModel>> fetchDeliveryChallanDashboards({
    required String fromDate,
    required String toDate,
  }) async {
    final url =
        "${AppUrls.getDeliveryChallanDashboardUrl}?fromDate=$fromDate&toDate=$toDate";

    final response = await _apiServices.getGetApiResponse(url);

    if (response == null || response is! List) return [];

    return response
        .map((e) => DeliveryChallanModel.fromJson(e))
        .toList();
  }


  // ================= GET BY ID (EDIT) =================

  Future<DeliveryChallanModel> getDeliveryChallanById(int challanId) async {
    final url = "${AppUrls.getDeliveryChallanById}/$challanId";
    final response = await _apiServices.getGetApiResponse(url);
    return DeliveryChallanModel.fromJson(response);
  }


  // ================= ADD =================

  Future<dynamic> addDeliveryChallanApi(Map<String, dynamic> data) async {
    return await _apiServices.getPostApiResponse(
      AppUrls.addDeliveryChallan,
      data,
    );
  }

  // ================= UPDATE =================

  Future<dynamic> updateDeliveryChallan(Map<String, dynamic> data) async {
    return await _apiServices.getPostApiResponse(
      AppUrls.updateDeliveryChallan,
      data,
    );
  }

  // ================= DELETE =================

  Future<bool> deleteDeliveryChallan(int id) async {
    final url = AppUrls.deleteDeliveryChallan.replaceAll("{id}", id.toString());
    await _apiServices.getDeleteApiResponse(url);
    return true;
  }

  // ================= DROPDOWNS =================

  Future<List<ItemsByProductTypeModel>> fetchItemsByProductType(
      String stockDate, String locationId) async {
    final url = AppUrls.getItemsByProductTypeUrl
        .replaceAll('{stockDate}', stockDate) +
        '?locationId=$locationId';

    final response = await _apiServices.getGetApiResponse(url);

    return (response as List)
        .map((e) => ItemsByProductTypeModel.fromJson(e))
        .toList();
  }

  Future<List<ItemSalesDetailsModel>> fetchItemSalesDetails(
      int itemId,
      String date,
      String locationId,
      ) async {

    final url =
        "${AppUrls.getItemSalesDetailsUrl}"
        "?itemId=$itemId"
        "&stockDate=$date"
        "&locationId=$locationId";

    final response = await _apiServices.getGetApiResponse(url);

    return (response as List)
        .map((e) => ItemSalesDetailsModel.fromJson(e))
        .toList();
  }

  Future<List<GetItemUnitConvertedModel>> fetchItemUnitConverted(int itemId) async {
    final url = "${AppUrls.getItemUnitConvertedUrl}?itemId=$itemId";

    final response = await _apiServices.getGetApiResponse(url);

    return (response as List)
        .map((e) => GetItemUnitConvertedModel.fromJson(e))
        .toList();
  }
}
