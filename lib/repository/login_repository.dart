import 'dart:convert';
import 'package:http/http.dart' as http;
import '../res/widgets/app_urls.dart';

class LoginRepository {
  Future<dynamic> loginApi(String userName, String password, String customerCode) async {
    final uri = Uri.parse(AppUrls.loginEndPoint);

    final body = {
      "UserName": userName,
      "Password": password,
      "CustomerCode": customerCode,  // required field
    };

    try {
      print("Calling API at: $uri");
      print("Request Body: $body");

      final response = await http.post(
        uri,
        headers: {
          "accept": "*/*",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("API Success: ${response.body}");

        return {
          "message": response.body.trim(), // token
        };
      } else {
        print("API Error - Status: ${response.statusCode}");
        print("API Error - Body: ${response.body}");
        throw Exception("Failed with status code ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Network error: $e");
      throw Exception("API error: $e");
    }
  }
}
