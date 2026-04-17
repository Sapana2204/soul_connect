
import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/item_master_model.dart';
import '../res/widgets/app_urls.dart';

class ItemMasterRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<ItemMasterModel>> fetchItemMasters() async {
    try {
      final String url = AppUrls.getItemMasterUrl;
      print('Item Masters URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print('Item Masters Response: $response');

      // Assuming response is a List of category master objects
      List<ItemMasterModel> itemMastersList =
      (response as List).map((data) => ItemMasterModel.fromJson(data)).toList();

      return itemMastersList;
    } catch (e) {
      print("Error fetching item masters: $e");
      rethrow;
    }
  }


  Future<List<ItemMasterModel>> saveItems(Map<String, dynamic> data) async {
    try {
      final String url = AppUrls.getItemMasterUrl;
      print('Save Item Masters URL: $url');
      print('Posting Data: $data');

      dynamic response = await _apiServices.getPostApiResponse(url, data);

      print('Item Masters Post Response: $response');

      // Check if the response is a Map with 'data' key or a List directly
      List<dynamic> itemsJson;
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        itemsJson = response['data'];
      } else if (response is List) {
        itemsJson = response;
      } else {
        throw Exception('Unexpected response format');
      }

      List<ItemMasterModel> itemMastersList = itemsJson
          .map((data) => ItemMasterModel.fromJson(data))
          .toList();

      return itemMastersList;
    } catch (e) {
      print("Error saving item masters: $e");
      rethrow;
    }
  }

}
