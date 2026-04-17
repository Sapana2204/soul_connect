import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/model/Expiry_report_model.dart';
import 'package:flutter_soulconnect/viewmodel/category_master_viewmodel.dart';
import '../model/category_master_model.dart';
import '../model/itemLedgerReport_model.dart';
import '../model/items_model.dart';
import '../model/purchaseReportDetails_model.dart';
import '../model/salesReportDetails_model.dart';
import '../model/stock_locations_model.dart';
import '../model/stock_report_model.dart';
import '../repository/stock_report_repository.dart';
import '../repository/item_repository.dart';
import '../repository/category_master_repository.dart';
import 'package:flutter_soulconnect/viewmodel/item_viewmodel.dart';
import 'category_master_viewmodel.dart';


class StockViewModel with ChangeNotifier {
  final _stockRepo = StockRepository();
  final _itemRepo = ItemsRepository();
  final _categoryRepo = CategoryMasterRepository();

  bool _loading = false;
  bool get loading => _loading;
  bool _dropdownLoading = false;
  bool get dropdownLoading => _dropdownLoading;

  String? _error;
  String? get error => _error;

  List<StockReportModel> filteredReportList = [];
  List<ItemsModel> products = [];
  List<CategoryMasterModel> categories = [];
  List<StockLocationsModel> locations = [];

  bool itemLedgerLoading = false;
  List<ItemLedgerReportModel> itemLedgerList = [];

// Inside StockViewModel
  List<PurchaseReportDetailsModel> purchaseReportDetailsList = [];
  List<SalesDetailsReportModel> salesReportDetailsList = [];
  List<ExpiryReportModel> _expiringList = [];
  List<ExpiryReportModel> get expiringList => _expiringList;

  void clearReports() {
    purchaseReportDetailsList.clear();
    salesReportDetailsList.clear();
    notifyListeners();
  }

  void clearItemLedger() {
    itemLedgerList.clear();
    notifyListeners();
  }
  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  double totalPurVal = 0.0;
  double totalSalVal = 0.0;

  Future<void> fetchDropdownData(
      ItemViewmodel itemVM,
      CategoryMasterViewmodel categoryVm) async {

    _dropdownLoading = true;
    notifyListeners();

    try {

      // 🔹 Call all APIs
      await Future.wait([
        // itemVM.getItemsApi(),
        // categoryVm.categoryMastersApi(),
        // itemVM.getStockLocationsApi(),
      ]);

      // 🔹 Assign data
      products = itemVM.itemList;
      categories = categoryVm.categoryList;
      locations = itemVM.stockLocationsList;

    } catch (e) {
      debugPrint("Dropdown Fetch Error: $e");
    }

    _dropdownLoading = false;
    notifyListeners();
  }

  Future<void> fetchStockReport(String from, String to, {int? prodId, int? catId, int? locId}) async {
    _loading = true;
    notifyListeners();
    try {
      // API now returns already filtered data
      filteredReportList = await _stockRepo.fetchStockReportApi(
        fromDate: from,
        toDate: to,
        itemId: prodId,
        categoryId: catId,
        locationId: locId,
      );
      _calculateTotals();
    } catch (e) {
      debugPrint("API Error: $e");
      filteredReportList = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _calculateTotals() {
    totalPurVal = filteredReportList.fold(0, (sum, item) => sum + (item.purchaseValuation ?? 0));
    totalSalVal = filteredReportList.fold(0, (sum, item) => sum + (item.salesValuation ?? 0));
  }

  Future<void> fetchExpiryReport({
    required String fromDate,
    required String toDate,
    int? locationId, // ✅ optional
  }) async {
    setLoading(true);

    try {
      final data = await _stockRepo.fetchExpiryReport(
        fromDate: fromDate,
        toDate: toDate,
        locationId: locationId,
      );

      _expiringList = data;
    } catch (e) {
      print("Error: $e");
    } finally {
      setLoading(false);
    }
  }


  Future<void> fetchPurchaseDetailsReport({required int userId, required int locationId, required int itemId}) async {
    _loading = true;
    notifyListeners();
    try {
      purchaseReportDetailsList = await _stockRepo.fetchPurchaseDetailsReport(
        userId: userId,
        locationId: locationId,
        itemId: itemId,
      );
    } catch (e) {
      debugPrint("Purchase Details Report Error: $e");
      purchaseReportDetailsList = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSalesDetailsReport({required int userId, required int locationId, required int itemId}) async {
    _loading = true;
    notifyListeners();
    try {
      salesReportDetailsList = await _stockRepo.fetchSalesDetailsReport(
        userId: userId,
        locationId: locationId,
        itemId: itemId,
      );
    } catch (e) {
      debugPrint("Sales Details Report Error: $e");
      salesReportDetailsList = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchItemLedgerReport({
    required String fromDate,
    required String toDate,
    int? itemId,
  }) async {
    itemLedgerLoading = true;
    notifyListeners();

    try {
      itemLedgerList = await _stockRepo.fetchItemLedgerReportApi(
        stockFromDate: fromDate,
        stockToDate: toDate,
        itemId: itemId,
      );
    } catch (e) {
      debugPrint("❌ Item Ledger Fetch Error: $e");
      itemLedgerList = [];
    } finally {
      itemLedgerLoading = false;
      notifyListeners();
    }
  }


}