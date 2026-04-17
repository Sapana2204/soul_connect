import 'package:flutter/foundation.dart';

import '../model/sales_dashboard_model.dart';
import '../repository/sales_dashboard_repository.dart';


class SalesDashboardViewModel with ChangeNotifier {
  final _salesRepo = SalesDashboardRepository();

  bool _loading = false;
  String? _errorMessage;

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  List<SalesDashboardModel> _salesList = [];
  List<SalesDashboardModel> get salesList => _salesList;

  dynamic _invoiceData;
  dynamic get invoiceData => _invoiceData;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }


  Future<void> getSalesByDate({
    required String fromDate,
    required String toDate,
    required int userId,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _salesRepo.fetchSalesByDate(
        fromDate: fromDate,
        toDate: toDate,
        userId: userId,
      );

      _salesList = response;
    } catch (e) {
      print("Error in ViewModel: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<SalesDashboardModel?> getSalesById(int id) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _salesRepo.getSalesById(id);

      // You can store it or return it directly
      return response;
    } catch (e) {
      print("Error in getSalesById ViewModel: $e");
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Future<SalesDashboardModel?> getSalesById({required int id}) async {
  //   _loading = true;
  //   notifyListeners();
  //
  //   try {
  //     final response = await _salesRepo.getSalesById(id: id);
  //
  //     // If your repository returns a single object (not a list)
  //     SalesDashboardModel sale = response;
  //
  //     // Optionally store it for later use
  //     // _selectedSale = sale;
  //
  //     return sale;
  //   } catch (e) {
  //     print("Error in getSalesById ViewModel: $e");
  //     return null;
  //   } finally {
  //     _loading = false;
  //     notifyListeners();
  //   }
  // }


  Future<bool> deleteSaleApi(int salesId) async {
    setLoading(true);
    try {
      final result = await _salesRepo.deleteSale(salesId);
      if (result) {
        _salesList.removeWhere((sales) => sales.salesID == salesId);
        notifyListeners();
        return true;
      } else {
        setError("Failed to delete sale.");
        return false;
      }
    } catch (e) {
      print("Delete sale error: $e");
      setError("Error deleting sale.");
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchInvoicePrintData(int salesId) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _salesRepo.getInvoicePrintData(salesId);
      _invoiceData = response;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchSalesByFilter({
    required int userId,
    required String fromDate,
    required String toDate,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      _salesList = await _salesRepo.fetchSalesByFilter(
        userId: userId,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      print("Error fetching sales: $e");
    }

    _loading = false;
    notifyListeners();
  }
}
