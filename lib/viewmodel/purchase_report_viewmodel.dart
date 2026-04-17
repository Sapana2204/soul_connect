import 'package:flutter/material.dart';

import '../model/purchase_itemwise_report_request.dart';
import '../repository/purchase_report_repository.dart';


class PurchaseReportViewModel with ChangeNotifier {
  final _repo = PurchaseReportRepository();

  bool _loading = false;
  bool get loading => _loading;

  List<dynamic> _reportList = [];
  List<dynamic> get reportList => _reportList;

  String? _error;
  String? get error => _error;

  Future<void> fetchReport(PurchaseItemwiseReportRequest request) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repo.fetchPurchaseItemwiseReport(request);
      _reportList = response is List ? response : [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReportStmtReport(PurchaseItemwiseReportRequest request) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repo.fetchPurchaseStmt(request);
      _reportList = response is List ? response : [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReportReturnStmtReport({
    required String fromDate,
    required String toDate,
    int? locationId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repo.fetchPurchaseReturnStmt(
        fromDate: fromDate,
        toDate: toDate,
        locationId: locationId,
      );

      _reportList = response is List ? response : [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReportReturnItemwise({
    required String fromDate,
    required String toDate,
    int? locationId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repo.fetchPurchaseReturnItemwise(
        fromDate: fromDate,
        toDate: toDate,
        locationId: locationId,
      );

      _reportList = response is List ? response : [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
