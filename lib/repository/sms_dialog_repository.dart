import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../res/widgets/app_urls.dart';

class SmsDialogRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<String> sendBillSMSAndWPNotification({
    required int salesId,
    required bool isSmsSent,
    required bool isWpSent,
  }) async {
    try {
      final uri = Uri.parse("${AppUrls.baseUrl}/SmsData/SendBillSMS_WPNotification");

      print("Send sms api call: $uri");

      final body = {
        "SalesId": salesId,
        "IsSMSSent": isSmsSent,
        "IsWPSent": isWpSent,
      };

      print("📤 Sending SMS/WP Notification request: $body");

      final response = await _apiServices.getPostApiResponse(uri.toString(), body);

      // Response is plain text (SMS body)
      final message = response.toString().trim();
      print("✅ API Response Message: $message");

      return message;
    } catch (e) {
      print("❌ Error sending SMS/WP Notification: $e");
      rethrow;
    }
  }
}
