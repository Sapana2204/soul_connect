import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/repository/sales_report_repository.dart';
import '../model/get_users_model.dart';
import '../model/customerForCustomerStatement_model.dart';
import '../model/customerStatement_model.dart';
import '../model/receipt_model.dart';
import '../model/sales_itemwise_report_request.dart';
import '../model/sales_summary_by_user_model.dart';

class SalesReportViewModel with ChangeNotifier {
  final _repo = SalesReportRepository();

  bool _loading = false;
  bool get loading => _loading;

  List<dynamic> _reportList = [];
  List<dynamic> get reportList => _reportList;
  bool _customerLoading = false;
  bool get customerLoading => _customerLoading;

  List<CustomerForCustomerStatementModel> _cashCustomerList = [];
  List<CustomerForCustomerStatementModel> get cashCustomerList => _cashCustomerList;

  List<CustomerForCustomerStatementModel> _creditCustomerList = [];
  List<CustomerForCustomerStatementModel> get creditCustomerList => _creditCustomerList;


  List<ReceiptModel> receiptList = [];

  List<GetUsersModel> _userList = [];
  List<GetUsersModel> get userList => _userList;


  String? _error;
  String? get error => _error;


  List<CustomerForCustomerStatementModel> _customerList = [];
  List<CustomerForCustomerStatementModel> get customerList => _customerList;

  bool _customerStatementLoading = false;
  bool get customerStatementLoading => _customerStatementLoading;

  List<CustomerStatementModel> _customerStatementList = [];
  List<CustomerStatementModel> get customerStatementList => _customerStatementList;

  List<SalesSummaryModel> _salesListByUser = [];
  List<SalesSummaryModel> get salesListByUser => _salesListByUser;

  void clearData() {
    customerStatementList.clear();
    receiptList.clear();
    notifyListeners();
  }

  // void clear() {
  //   itemDetails = [];
  //   notifyListeners();
  // }

  Future<void> fetchReport(SalesItemwiseReportRequest request) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repo.fetchSalesItemwiseReport(request);
      _reportList = response is List ? response : [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReportStmtReport(SalesItemwiseReportRequest request) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repo.fetchSalesStmt(request);
      _reportList = response is List ? response : [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCustomerForCustomerStatement({
    required String partyType,
    int? partyId,
  }) async {
    _customerLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repo.fetchCustomerForCustomerStatement(
        partyType: partyType,
        partyId: partyId,
      );

      if (response is List) {
        _customerList = response
            .map((e) => CustomerForCustomerStatementModel.fromJson(e))
            .toList();
      } else {
        _customerList = [];
      }
    } catch (e) {
      _error = e.toString();
      _customerList = [];
    } finally {
      _customerLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCustomerStatementSummary({
    required String fromDate,
    required String toDate,
    int? customerId,
    int? userId,
    String? customerName
  }) async {
    _customerStatementLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repo.fetchCustomerStatementSummary(
        fromDate: fromDate,
        toDate: toDate,
        customerId: customerId,
        userId: userId,
        customerName: customerName,
      );

      // if (response is List) {
      //   _customerStatementList =
      //       response.map((e) => CustomerStatementModel.fromJson(e)).toList();
      // }
      if (response is List) {
        _customerStatementList =
            response.map((e) {
              print("RAW JSON: $e"); // ✅ check actual data
              return CustomerStatementModel.fromJson(e);
            }).toList();

        print("PARSED COUNT: ${_customerStatementList.length}");
      }
      else {
        _customerStatementList = [];
      }
    } catch (e) {
      _error = e.toString();
      _customerStatementList = [];
    } finally {
      _customerStatementLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCashCustomers() async {
    try {
      _customerLoading = true;
      notifyListeners();

      final response = await _repo.fetchCustomerForCustomerStatement(
        partyType: "C",
        partyId: 1,
      );

      print("RESPONSE TYPE: ${response.runtimeType}");
      print("RESPONSE DATA: $response");

      if (response is List) {
        print("Response length: ${response.length}");

        _cashCustomerList = response
            .map((e) => CustomerForCustomerStatementModel.fromJson(e))
            .toList();

        print("Stored cash list count: ${_cashCustomerList.length}");
      } else {
        print("Response is NOT a List");
        _cashCustomerList = [];
      }
    } catch (e) {
      print("ERROR: $e");
      _cashCustomerList = [];
    } finally {
      _customerLoading = false;
      notifyListeners();
    }
  }

  // 🔥 Load CREDIT customers
  Future<void> fetchCreditCustomers() async {
    try {
      _customerLoading = true;
      notifyListeners();

      final response = await _repo.fetchCustomerForCustomerStatement(
        partyType: "C",
      );

      if (response is List) {
        _creditCustomerList =
            response.map((e) => CustomerForCustomerStatementModel.fromJson(e)).toList();
      }
    } catch (e) {
      _creditCustomerList = [];
    } finally {
      _customerLoading = false;
      notifyListeners();
    }
  }

  Future<void> getReceipts({
    required String fromDate,
    required String toDate,
    required int ledgerId,
    required int userId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repo.fetchReceipts(
        fromDate: fromDate,
        toDate: toDate,
        ledgerId: ledgerId,
        userId: userId,
      );

      receiptList = data;
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchSalesSummary({
    required int userId,
    required String fromDate,
    required String toDate,
  }) async {

    _loading = true;
    notifyListeners();

    try {

      _salesListByUser = await _repo.fetchSalesSummaryByUser(
        userId: userId,
        fromDate: fromDate,
        toDate: toDate,
      );

    }catch (e) {
      _error = e.toString();
      print("❌ ViewModel Error: $e");
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchUsers() async {

    _loading = true;
    notifyListeners();

    try {

      _userList = await _repo.fetchUsers();

    } catch (e) {
      _error = e.toString();
      print("❌ ViewModel Error: $e");
    }

    _loading = false;
    notifyListeners();
  }
}


