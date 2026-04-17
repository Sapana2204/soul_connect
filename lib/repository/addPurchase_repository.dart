

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';

import '../res/widgets/app_urls.dart';


class AddPurchaseRepository {
  final BaseApiServices _apiServices = NetworkApiServices();



  Future<dynamic> addPurchaseApi(Map<String, dynamic> data) async {
    try {
      final String url = "${AppUrls.addPurchase}";


      dynamic response = await _apiServices.getPostApiResponse(url, data);

      return response;
    } catch (e) {
      rethrow;
    }
  }



}
