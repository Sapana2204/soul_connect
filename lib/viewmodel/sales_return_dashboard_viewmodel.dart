import 'package:flutter/foundation.dart';
import 'package:flutter_soulconnect/repository/sales_return_dashboard_repository.dart';

import '../model/sales_return_dashboard_model.dart';
import '../repository/sales_dashboard_repository.dart';


class SalesReturnDashboardViewModel with ChangeNotifier {
  final _salesReturnRepo = SalesReturnDashboardRepository();

  bool _loading = false;
  String? _errorMessage;

  bool get loading => _loading;

  List<SalesReturnDashboardModel> _salesReturnList = [];
  List<SalesReturnDashboardModel> _filteredList = [];
  List<SalesReturnDashboardModel> get salesReturnList => _filteredList;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }


  Future<void> fetchSalesReturnByDate({ required String fromDate,
      required String toDate}) async {
    setLoading(true);
    try {
      final list = await _salesReturnRepo.fetchSalesReturnByDateApi(fromDate, toDate);
      _salesReturnList = list;
      _filteredList = list;
    } catch (e) {
      debugPrint("ViewModel Error: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<SalesReturnDashboardModel?> getSalesReturnById(int id) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _salesReturnRepo.getSalesReturnById(id);

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

  Future<bool> deleteSalesReturnApi(int salesId) async {
    setLoading(true);
    try {
      final result = await _salesReturnRepo.deleteSalesReturn(salesId);
      if (result) {
        _salesReturnList.removeWhere((sales) => sales.returnId == salesId);
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

  // Future<void> fetchInvoicePrintData(int salesId) async {
  //   _loading = true;
  //   _errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     final response = await _salesReturnRepo.getInvoicePrintData(salesId);
  //     _invoiceData = response;
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //   }
  //
  //   _loading = false;
  //   notifyListeners();
  // }

}
