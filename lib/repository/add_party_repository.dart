
import '../res/widgets/app_urls.dart';
import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/states_model.dart';

class AddPartyRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<StatesModel>> fetchStates() async {
    try {
      final String url = "${AppUrls.getStatesUrl}";
      print("Fetching States from URL: $url");

      dynamic response = await _apiServices.getGetApiResponse(url);
      print("States API Response: $response");

      if (response is List) {
        return response.map((json) => StatesModel.fromJson(json)).toList();
      } else if (response['data'] is List) {
        // Sometimes APIs wrap the list inside a `data` key
        return (response['data'] as List)
            .map((json) => StatesModel.fromJson(json))
            .toList();
      } else {
        throw Exception("Invalid states API response format");
      }
    } catch (e) {
      print("Error in fetchStates: $e");
      rethrow;
    }
  }

  // Add Party API
  Future<dynamic> addParty(Map<String, dynamic> data) async {
    try {
      final String url = "${AppUrls.addPartyUrl}";
      print("Posting Party to URL: $url");
      print("Request Body: $data");

      dynamic response = await _apiServices.getPostApiResponse(url, data);
      print("Add Party Response: $response");
      return response;
    } catch (e) {
      print("Error in addParty: $e");
      rethrow;
    }
  }
}
