import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../res/widgets/app_urls.dart';

class AddSaleRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> addSaleApi(Map<String, dynamic> data) async {
    try {
      final String url = "${AppUrls.addSaleUrl}";
      print("Add Sale API URL: $url");
      print("Request Body: $data");

      dynamic response = await _apiServices.getPostApiResponse(url, data);
      print("Add Sale API Response: $response");

      return response;
    } catch (e) {
      print("Error in addSaleApi: $e");
      rethrow;
    }
  }

  Future<dynamic> updateSaleApi(Map<String, dynamic> data) async {
    try {
      final String url = "${AppUrls.updateSaleUrl}";
      print("Update Sale API URL: $url");
      print("Request Body: $data");

      dynamic response = await _apiServices.getPostApiResponse(url, data);
      print("Update Sale API Response: $response");

      return response;
    } catch (e) {
      print("Error in Update Sale Api: $e");
      rethrow;
    }
  }
}
