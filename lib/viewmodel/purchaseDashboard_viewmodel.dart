import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/model/purchase_challan_dashboard_model.dart';
import 'package:intl/intl.dart';
import '../model/purchaseDashboard_model.dart';
import '../repository/purchaseDashboard_repository.dart';

class PurchaseDashboardViewmodel with ChangeNotifier {
  final PurchaseDashboardRepository _purchaseDashboardRepo = PurchaseDashboardRepository();

  bool _purchaseDashboardsLoading = false;
  List<PurchaseDashboardModel> _purchaseDashboardList = [];

  bool get loading => _purchaseDashboardsLoading;
  List<PurchaseDashboardModel> get purchaseDashboardList => _purchaseDashboardList;

  List<PurchaseChallanDashboardModel> challanList = [];

  bool _loading = false;
  bool get updatePurchaseLoading => _loading;

  void setPurchaseDashboards(bool value) {
    _purchaseDashboardsLoading = value;
    notifyListeners();
  }

  setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  /// Default date = today's date only
  String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> purchaseDashboardsApi({
    String? fromDate,
    String? toDate,
    required int userId,
  }) async {
    setPurchaseDashboards(true);
    try {
      List<PurchaseDashboardModel> response =
      await _purchaseDashboardRepo.fetchPurchaseDashboards(
        fromDate: fromDate ?? todayDate,
        toDate: toDate ?? todayDate,
        userId: userId,
      );

      _purchaseDashboardList = response;
      notifyListeners();
    } catch (error) {
      print("Error fetching purchase dashboard: $error");
    } finally {
      setPurchaseDashboards(false);
    }
  }

  Future<bool> deletePurchase(int id) async {
    setPurchaseDashboards(true);
    final result = await _purchaseDashboardRepo.deletePurchase(id);
    if (result) {
      _purchaseDashboardList.removeWhere((item) => item.purchaseId == id);
      notifyListeners();
    }
    setPurchaseDashboards(false);
    return result;
  }

  Future<bool> updatePurchase(Map<String, dynamic> requestData) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _purchaseDashboardRepo.updatePurchase(requestData);

      _loading = false;
      notifyListeners();

      if (response != null && response["Message"] != null && response["Message"].toString().toLowerCase().contains("success")) {
        return true; // API returned success
      } else {
        debugPrint("❌ Update failed: $response");
        return false;
      }
    } catch (e) {
      _loading = false;
      notifyListeners();
      debugPrint("❌ Exception in updatePurchase: $e");
      return false;
    }
  }


  Future<PurchaseDashboardModel?> getPurchaseById(int id) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _purchaseDashboardRepo.getPurchaseById(id);

      // You can store it or return it directly
      return response;
    } catch (e) {
      print("Error in getPurchaseById ViewModel: $e");
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPurchaseChallans({
    required String fromDate,
    required String toDate,
  }) async {

    setLoading(true);

    try {

      final data = await _purchaseDashboardRepo.fetchPurchaseChallans(
        fromDate: fromDate,
        toDate: toDate,
      );

      challanList = data;

    } catch (e) {
      print("ViewModel Error: $e");
    }

    setLoading(false);
  }

  Future<void> fetchPurchasesByFilter({
    required String fromDate,
    required String toDate,
  }) async {

    _loading = true;
    notifyListeners();

    try {

      _purchaseDashboardList = await _purchaseDashboardRepo.fetchPurchasesByFilter(
        fromDate: fromDate,
        toDate: toDate,
      );

    } catch (e) {

      print("❌ Error in ViewModel: $e");

    }

    _loading = false;
    notifyListeners();
  }
}
