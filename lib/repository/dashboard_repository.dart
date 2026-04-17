import 'dart:async';
import 'package:intl/intl.dart';
import '../model/dashboard_model.dart';
import '../res/widgets/app_urls.dart';
import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';

class DashboardRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  // Helper to get formatted date
  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Main Dashboard Summary
  Future<Map<String, dynamic>> fetchFullDashboardData() async {
    try {
      final dynamic response = await _apiServices.getGetApiResponse(
        AppUrls.getDashboardUrl(_today),
      );

      if (response is List && response.isNotEmpty) {
        return response[0] as Map<String, dynamic>;
      } else if (response is Map<String, dynamic>) {
        return response;
      }
      throw Exception('Data format error');
    } catch (e) {
      rethrow;
    }
  }

  // Fetch Customers (Sundry Debtors - Group ID 26)
  Future<List<Party>> fetchCustomers() async {
    final dynamic response = await _apiServices.getGetApiResponse(
      AppUrls.getOutstandingReport(_today, 26),
    );

    if (response is List) {
      return response
          .map((item) => Party(
        name: item['LedgerName'] ?? 'N/A',
        outstanding: (item['Closing'] ?? 0).toDouble(),
        contact: item['Contact']?.toString(),
      ))
          .toList();
    }
    return [];
  }

  /*//Static Test Method
  Future<List<Party>> fetchCustomers() async {
    return [
      Party(
        name: 'Aditya',
        outstanding: 548,
        contact: null,
      ),
      Party(
        name: 'Aditya',
        outstanding: 548,
        contact: null,
      ),
      Party(
        name: 'Aditya',
        outstanding: 548,
        contact: null,
      ),
      Party(
        name: 'Aditya',
        outstanding: 548,
        contact: null,
      ),
      Party(
        name: 'Aditya',
        outstanding: 548,
        contact: null,
      ),
    ];
  }*/

  // Fetch Suppliers
  Future<List<Party>> fetchSuppliers() async {
    final dynamic response = await _apiServices.getGetApiResponse(
      AppUrls.getOutstandingReport(_today, 25),
    );

    if (response is List) {
      return response
          .map((item) => Party(
        name: item['LedgerName'] ?? 'Unknown',
        outstanding: (item['Closing'] ?? 0).toDouble(),
        contact: item['Contact']?.toString(),
      ))
          .toList();
    }
    return [];
  }

  //static test data
  /*Future<List<Party>> fetchSuppliers() async {
    return [Party(name: 'ADi', outstanding: 250, contact: null),
      Party(name: 'aditya', outstanding: 250, contact: null),
      Party(name: 'adi', outstanding: 2350, contact: null),
      Party(name: 'adi', outstanding: 150, contact: null),
      Party(name: '5yguyyu', outstanding: 849, contact: null),
      Party(name: 'gytguy', outstanding: 468, contact: null),
      Party(name: 'vtft', outstanding: 785, contact: null),];
  }*/

  // Fetch Products
  Future<List<Product>> fetchProducts() async {
    final dynamic response = await _apiServices.getGetApiResponse(
      AppUrls.getProductExpiryUrl(_today, _today),
    );

    if (response is List) {
      return response
          .map((item) => Product(
        productName: item['ItemName'] ?? 'N/A',
        hsnCode: item['HSNCode']?.toString() ?? 'N/A',
        batchNo: item['BatchNo']?.toString() ?? 'N/A',
        expiryDate: item['ExpDate'].toString().substring(0, 10),
      ))
          .toList();
    }
    return [];
  }

/*Future<List<Product>> fetchProducts() async{
    await Future.delayed(const Duration(seconds: 2));
    return [
      Product(productName: 'OMITE 100 ML', hsnCode: '4412', batchNo: 'BATCH123', expiryDate: '2026-01-01'),
      Product(productName: 'OMITE 100 ML', hsnCode: '4412', batchNo: 'BATCH123', expiryDate: '2026-01-01'),
      Product(productName: 'OMITE 100 ML', hsnCode: '4412', batchNo: 'BATCH123', expiryDate: '2026-01-28'),
      Product(productName: 'OMITE 100 ML', hsnCode: '4412', batchNo: 'BATCH123', expiryDate: '2026-01-01'),
      Product(productName: '5 th product 100 ML', hsnCode: '4412', batchNo: 'BATCH123', expiryDate: '2026-01-01'),
      Product(productName: 'OMITE 100 ML', hsnCode: '4412', batchNo: 'BATCH123', expiryDate: '2026-01-20'),
      Product(productName: 'OMITE 100 ML', hsnCode: '4412', batchNo: 'BATCH123', expiryDate: '2026-01-01'),
      Product(productName: 'OMITE 100 ML', hsnCode: '4412', batchNo: 'BATCH123', expiryDate: '2026-01-21'),
      Product(productName: 'OMITE 100 ML', hsnCode: '4412', batchNo: 'BATCH123', expiryDate: '2026-01-01'),
      Product(productName: 'OMITE 100 ML', hsnCode: '4412', batchNo: 'BATCH123', expiryDate: '2026-01-01'),
    ];
  }*/
}

