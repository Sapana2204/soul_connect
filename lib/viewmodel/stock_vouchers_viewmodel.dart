import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/model/get_expiry_model.dart';
import 'package:flutter_soulconnect/model/issue_vch_request_model.dart';
import 'package:flutter_soulconnect/model/stock_inward_request_model.dart';
import 'package:flutter_soulconnect/repository/stock_vouchers_repository.dart';
import 'package:intl/intl.dart';
import '../model/expiring_item_model.dart';
import '../model/stock_inward_model.dart';
import '../model/stock_issue_Inward_model.dart';
import '../model/stock_issue_model.dart';

class StockVouchersViewmodel extends ChangeNotifier {

  final StockVouchersRepository _repository = StockVouchersRepository();

  List<StockIssueModel> _stockIssues = [];
  List<StockIssueModel> get stockIssues => _stockIssues;

  /// STOCK INWARD
  List<StockInwardModel> _stockInwards = [];
  List<StockInwardModel> get stockInwards => _stockInwards;

  List<ExpiryModel> _expiryVch = [];
  List<ExpiryModel> get expiryVch => _expiryVch;

  bool _loading = false;
  bool get loading => _loading;

  StockIssueModel? _selectedStockIssue;
  StockIssueModel? get selectedStockIssue => _selectedStockIssue;

  List<StockIssueForInwardModel> _issueForInwardList = [];
  List<StockIssueForInwardModel> get issueForInwardList => _issueForInwardList;

  List<ExpiringItemModel> _expiringItems = [];
  List<ExpiringItemModel> get expiringItems => _expiringItems;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// Fetch All Stock Issues
  Future<void> fetchStockIssues() async {
    try {
      _loading = true;
      notifyListeners();

      final data = await _repository.fetchStockIssues();
      _stockIssues = data;

    } catch (e) {
      debugPrint("Error fetching stock issues: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// ADD STOCK ISSUE
  Future<bool> addIssueVchApi(IssueVchRequestModel request) async {
    _loading = true;
    notifyListeners();

    try {
      await _repository.addIssueVch(request);
      return true;
    } catch (e) {
      debugPrint("Add Stock Issue Error: $e");
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// ADD STOCK ISSUE
  Future<bool> updateIssueVchApi(IssueVchRequestModel request) async {
    _loading = true;
    notifyListeners();

    try {
      await _repository.updateIssueVch(request);
      return true;
    } catch (e) {
      debugPrint("Update Stock Issue Error: $e");
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String> deleteStockIssue(int issueId) async {
    try {

      final message = await _repository.deleteStockIssue(issueId);

      _stockIssues.removeWhere((e) => e.issueId == issueId);

      notifyListeners();

      return message;

    } catch (e) {
      return "Delete failed";
    }
  }

  /// Fetch Stock Inwards
  Future<void> fetchStockInwards() async {
    _loading = true;
    notifyListeners();

    try {
      _stockInwards = await _repository.fetchStockInwards();
    } catch (e) {
      print("Stock Inward Error: $e");
    }

    _loading = false;
    notifyListeners();
  }

  /// Fetch Stock Issue For Inward
  Future<void> fetchStockIssueForInward(int locationId) async {

    setLoading(true);

    try {

      final data = await _repository.fetchStockIssueForInward(locationId);

      _issueForInwardList = data;

    } catch (e) {
      debugPrint("Error fetching issue for inward: $e");
    }

    setLoading(false);
  }

  Future<bool> addStockInwardApi(StockInwardRequestModel request) async {
    _loading = true;
    notifyListeners();

    try {
      await _repository.addStockInwardVch(request);
      return true;
    } catch (e) {
      debugPrint("Add Stock Inward Error: $e");
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String> deleteStockInward(int inwardId) async {
    try {

      final message = await _repository.deleteStockInward(inwardId);

      _stockInwards.removeWhere((e) => e.inwardId == inwardId);

      notifyListeners();

      return message;

    } catch (e) {
      return "Delete failed";
    }
  }

  Future<void> fetchExpiryVch() async {
    try {
      _loading = true;
      notifyListeners();

      final data = await _repository.fetchExpiryVch();
      _expiryVch = data;

    } catch (e) {
      debugPrint("Error fetching expiry vouchers: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String> deleteExpiryVch(int expiryId) async {
    try {

      final message = await _repository.deleteExpiryVch(expiryId);

      _expiryVch.removeWhere((e) => e.expiryId == expiryId);

      notifyListeners();

      return message;

    } catch (e) {
      return "Delete failed";
    }
  }

  Future<void> loadExpiringItems(String expDate) async {

    try {

      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final data = await _repository.fetchExpiringItems(
        stockFromDate: today,
        stockToDate: today,
        expDate: expDate,
      );

      _expiringItems = data;

      notifyListeners();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> updateExpiryVchApi(ExpiryModel request) async {
    _loading = true;
    notifyListeners();

    try {
      await _repository.updateExpiryVch(request);
      return true;
    } catch (e) {
      debugPrint("Update Expiry Vch Error: $e");
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpiryApi(ExpiryModel request) async {
    _loading = true;
    notifyListeners();

    try {
      final message = await _repository.addExpiryVch(request);

      print("Expiry API Success: $message");

      _loading = false;
      notifyListeners();

      return true;
    } catch (e) {
      print("Expiry API Error: $e");

      _loading = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> updateExpiryApi(ExpiryModel request) async {
    _loading = true;
    notifyListeners();

    try {
      await _repository.updateExpiryVch(request);
      return true;
    } catch (e) {
      debugPrint("Update Expiry Voucher Error: $e");
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}