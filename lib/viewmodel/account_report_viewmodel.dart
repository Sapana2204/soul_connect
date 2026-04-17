import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/repository/item_repository.dart';
import 'package:intl/intl.dart';

import '../model/dayBookReport_model.dart';
import '../model/dayBookSummaryReport_model.dart';
import '../model/get_users_model.dart';
import '../model/ledger_bal_model.dart';
import '../model/ledger_report_model.dart';
import '../model/ledger_report_request.dart';
import '../model/ledger_type_model.dart';

import '../model/outstanding_report_model.dart';
import '../model/profitLossReport_model.dart';
import '../repository/account_report_repository.dart';

class AccountReportViewmodel with ChangeNotifier {
  final _ledgerReportRepo = AccountReportRepository();

  bool _ledgernameLoading = false;
  bool _loading = false;
  List<LedgerReportModel> get ledgerList => _ledgerList;
  bool get isLoading => _loading;
  String? get error => _error;

  LedgerBalModel? _ledgerBalance;
  LedgerBalModel? get ledgerBalance => _ledgerBalance;

  List<LedgerTypeModel> _ledgernameList = [];
  List<LedgerReportModel> _ledgerList = [];

  bool get loading => _ledgernameLoading;
  String? _error;

  double? openingBalance;
  double? closingBalance;

  bool isBalanceLoading = false;

  List<LedgerTypeModel> get ledgernameList => _ledgernameList;

  void setLedgername(bool value) {
    _ledgernameLoading = value;
    notifyListeners();
  }
  bool _outreploading = false;
  bool get outrepLoading => _loading;

  List<OutstandingModel> _supplierList = [];
  List<OutstandingModel> _customerList = [];

  List<OutstandingModel> get supplierList => _supplierList;
  List<OutstandingModel> get customerList => _customerList;

  bool _profitLossLoading = false;
  bool get profitLossLoading => _profitLossLoading;

  ProfitLossModel? _profitLossData;
  ProfitLossModel? get profitLossData => _profitLossData;

  List<ProfitLossStatement> _profitLossList = [];
  List<ProfitLossStatement> get profitLossList => _profitLossList;

  bool _userLoading = false;
  bool get userLoading => _userLoading;

  List<GetUsersModel> _userList = [];
  List<GetUsersModel> get userList => _userList;

  ProfitLossTotals? _profitLossTotals;
  ProfitLossTotals? get profitLossTotals => _profitLossTotals;

  bool _dayBookLoading = false;
  bool get dayBookLoading => _dayBookLoading;

  List<DayBookReportModel> _dayBookList = [];
  List<DayBookReportModel> get dayBookList => _dayBookList;

  bool _dayBookSummaryLoading = false;
  bool get dayBookSummaryLoading => _dayBookSummaryLoading;

  List<DayBookSummaryReportModel> _dayBookSummaryList = [];
  List<DayBookSummaryReportModel> get dayBookSummaryList => _dayBookSummaryList;

  void setDayBookSummaryLoading(bool value) {
    _dayBookSummaryLoading = value;
    notifyListeners();
  }


  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setProfitLossLoading(bool value) {
    _profitLossLoading = value;
    notifyListeners();
  }

  void setDayBookLoading(bool value) {
    _dayBookLoading = value;
    notifyListeners();
  }

  Future<void> getLedgernameApi() async {
    setLedgername(true);
    try {
      List<LedgerTypeModel> response = await _ledgerReportRepo.fetchLedgername();
      _ledgernameList = response;
    } catch (error) {
      print("Error fetching ladgername: $error");
    } finally {
      setLedgername(false);
    }
  }

  Future<void> fetchLedgerReport(LedgerReportRequest request) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _ledgerReportRepo.fetchLedgerReport(request);

      if (response is List) {
        _ledgerList = response
            .map((e) => LedgerReportModel.fromJson(e))
            .toList();
      } else {
        _ledgerList = [];
      }
    } catch (e) {
      _error = e.toString();
      _ledgerList = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearLedgerReport() {
    _ledgerList.clear();
    openingBalance = null;
    closingBalance = null;
    _error = null;
    notifyListeners();
  }

  Future<void> fetchOpeningAndClosingBalance({
    required int ledgerId,
    required String fromDate,
    required String toDate,
  }) async {
    isBalanceLoading = true;
    notifyListeners();

    try {
      // 🔹 Opening
      final openingResponse = await _ledgerReportRepo.fetchOpeningClosingBalance(
        ledgerId: ledgerId,
        balanceAsOn: fromDate,
        balanceType: "O",
      );

      // 🔹 Closing
      final closingResponse = await _ledgerReportRepo.fetchOpeningClosingBalance(
        ledgerId: ledgerId,
        balanceAsOn: toDate,
        balanceType: "C",
      );

      openingBalance = openingResponse.balance;
      closingBalance = closingResponse.balance;
    } catch (e) {
      openingBalance = 0;
      closingBalance = 0;
    } finally {
      isBalanceLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllOutstanding(String date) async {
    setLoading(true);
    try {
      // Fetch both simultaneously: Group 25 (Supplier) and Group 26 (Customer)
      final results = await Future.wait([
        _ledgerReportRepo.fetchOutstandingReport(date, 25),
        _ledgerReportRepo.fetchOutstandingReport(date, 26),
      ]);

      _supplierList = results[0];
      _customerList = results[1];
    } catch (e) {
      debugPrint("ViewModel Error: $e");
    } finally {
      setLoading(false);
    }
  }



  Future<void> fetchProfitLossReport({
    String? fromDate,
    String? toDate,
    int? customerId,
    String? salesType,
  }) async {
    setProfitLossLoading(true);

    try {
      // ✅ Default Today date if not passed
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

      final String fDate = fromDate ?? today;
      final String tDate = toDate ?? today;

      final response = await _ledgerReportRepo.fetchProfitLossReport(
        salesFromDate: fDate,
        salesToDate: tDate,
        customerId: customerId,
        salesType: salesType,
      );

      _profitLossData = response;
      _profitLossList = response.profitLossStatement ?? [];
      _profitLossTotals = response.profitLossTotals;
    } catch (e) {
      debugPrint("❌ ViewModel Profit Loss Error: $e");
      _profitLossData = null;
      _profitLossList = [];
      _profitLossTotals = null;
    } finally {
      setProfitLossLoading(false);
    }
  }

  Future<void> fetchUsers() async {
    _userLoading = true;
    notifyListeners();

    try {
      _userList = await _ledgerReportRepo.fetchUsers();
    } catch (e) {
      _error = e.toString();
      print("❌ ViewModel Error: $e");
    }

    _userLoading = false;
    notifyListeners();
  }

  Future<void> fetchDayBookReport({
    String? fromDate,
    String? toDate,
    required int userId,
  }) async {
    setDayBookLoading(true);

    try {
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

      final String fDate = fromDate ?? today;
      final String tDate = toDate ?? today;

      final response = await _ledgerReportRepo.fetchDayBookReport(
        fromDate: fDate,
        toDate: tDate,
        userId: userId,
      );

      _dayBookList = response;
    } catch (e) {
      print("❌ ViewModel DayBook Error: $e");
      _dayBookList = [];
    } finally {
      setDayBookLoading(false);
    }
  }

  Future<void> fetchDayBookSummaryReport({
    String? fromDate,
    String? toDate,
    required int userId,
  }) async {
    setDayBookSummaryLoading(true);

    try {
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

      final String fDate = fromDate ?? today;
      final String tDate = toDate ?? today;

      final response =
      await _ledgerReportRepo.fetchDayBookSummaryReport(
        fromDate: fDate,
        toDate: tDate,
        userId: userId,
      );

      _dayBookSummaryList = response;
    } catch (e) {
      print("❌ ViewModel DayBook Summary Error: $e");
      _dayBookSummaryList = [];
    } finally {
      setDayBookSummaryLoading(false);
    }
  }


}
