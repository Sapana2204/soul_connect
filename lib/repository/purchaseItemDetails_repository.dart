import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/purchaseItemDetails_model.dart';
import '../res/widgets/app_urls.dart';

class PurchaseItemDetailsRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<PurchaseItemDetailsModel>> fetchPurchaseItemDetails(int itemId) async {
    try {
      final String url = "${AppUrls.getPurchaseItemDetailsUrl}/$itemId";
      print('Get Purchase Item Details URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print('Get Purchase Item Details Response: $response');

      // Assuming response is a List of category master objects
      List<PurchaseItemDetailsModel> purchaseItemDetailsList =
      (response as List).map((data) => PurchaseItemDetailsModel.fromJson(data)).toList();

      return purchaseItemDetailsList;
    } catch (e) {
      print("Error fetching Purchase Item details: $e");
      rethrow;
    }
  }
}
