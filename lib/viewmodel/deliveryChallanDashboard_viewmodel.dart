import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/delivery_challan_model.dart';
import '../model/get_item_unit_converted_model.dart';
import '../model/item_sales_details_model.dart';
import '../model/items_by_product_type.dart';
import '../repository/deliveryChallanDashboard_repository.dart';




class DeliveryChallanDashboardViewmodel with ChangeNotifier {
  final DeliveryChallanDashboardRepository _repo =
  DeliveryChallanDashboardRepository();

  // ================= LOADING FLAGS =================
  String? _currentLocationId;

  bool _dashboardLoading = false;
  bool _dropdownLoading = false;
  bool _itemDetailsLoading = false;
  bool _unitLoading = false;
  bool _addLoading = false;
  bool _updateLoading = false;

  bool get dashboardLoading => _dashboardLoading;
  bool get dropdownLoading => _dropdownLoading;
  bool get itemDetailsLoading => _itemDetailsLoading;
  bool get unitLoading => _unitLoading;
  bool get addLoading => _addLoading;
  bool get updateLoading => _updateLoading;

  // ================= DATA =================

  List<DeliveryChallanModel> _dashboardList = [];
  List<ItemsByProductTypeModel> _itemList = [];
  List<ItemSalesDetailsModel> _itemDetailsList = [];

  final Map<int, List<GetItemUnitConvertedModel>> _unitCache = {};

  DeliveryChallanModel? _editingChallan;

  List<DeliveryChallanModel> get dashboardList => _dashboardList;
  List<ItemsByProductTypeModel> get itemList => _itemList;
  List<ItemSalesDetailsModel> get itemDetailsList => _itemDetailsList;
  DeliveryChallanModel? get editingChallan => _editingChallan;

  // ================= CACHE FLAG =================

  bool _dropdownsLoaded = false;

  // ================= HELPERS =================

  void _setLoading(Function setter, bool value) {
    setter(value);
    notifyListeners();
  }

  String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // ================= DASHBOARD =================

  Future<void> fetchDeliveryChallanDashboards({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    _setLoading((v) => _dashboardLoading = v, true);

    try {
      final df = DateFormat('yyyy-MM-dd');
      _dashboardList = await _repo.fetchDeliveryChallanDashboards(
        fromDate: df.format(fromDate ?? DateTime.now()),
        toDate: df.format(toDate ?? DateTime.now()),
      );
    } finally {
      _setLoading((v) => _dashboardLoading = v, false);
    }
  }

  // ================= PRELOAD DROPDOWNS (ONCE) =================

  Future<void> preloadDropdowns({
    required String stockDate,
    required String locationId,
  }) async {
    _setLoading((v) => _dropdownLoading = v, true);

    try {
      await _loadItems(stockDate, locationId);
    } finally {
      _setLoading((v) => _dropdownLoading = v, false);
    }
  }

  // ================= LOCATION CHANGE =================

  void clearItemsForLocationChange() {
    _itemList.clear();
    _itemDetailsList.clear(); // 🔥 also clear batches (important)
    _unitCache.clear();       // 🔥 clear unit cache
    _currentLocationId = null;
    notifyListeners();
  }

  Future<void> fetchItemsByProductType(
      String stockDate,
      String locationId,
      ) async {
    await preloadDropdowns(
      stockDate: stockDate,
      locationId: locationId,
    );
  }

  Future<void> _loadItems(String stockDate, String locationId) async {
    if (_itemList.isNotEmpty) return;
    _itemList = await _repo.fetchItemsByProductType(stockDate, locationId);
  }

  // ================= ITEM DETAILS =================

  Future<List<ItemSalesDetailsModel>> fetchItemSalesDetails(
      int itemId, String date, String locationId) async {
    _setLoading((v) => _itemDetailsLoading = v, true);

    try {
      _itemDetailsList =
      await _repo.fetchItemSalesDetails(itemId, date, locationId);
      return _itemDetailsList;
    } finally {
      _setLoading((v) => _itemDetailsLoading = v, false);
    }
  }

  // ================= UNIT CONVERTED (CACHED) =================

  Future<List<GetItemUnitConvertedModel>> fetchItemUnitConverted(
      int itemId) async {
    if (_unitCache.containsKey(itemId)) {
      return _unitCache[itemId]!;
    }

    _setLoading((v) => _unitLoading = v, true);

    try {
      final data = await _repo.fetchItemUnitConverted(itemId);
      _unitCache[itemId] = data;
      return data;
    } finally {
      _setLoading((v) => _unitLoading = v, false);
    }
  }

  // ================= ADD =================

  Future<bool> addDeliveryChallan(Map<String, dynamic> body) async {
    _setLoading((v) => _addLoading = v, true);

    try {
      await _repo.addDeliveryChallanApi(body);
      return true;
    } catch (_) {
      return false;
    } finally {
      _setLoading((v) => _addLoading = v, false);
    }
  }

  // ================= UPDATE =================

  Future<bool> updateDeliveryChallan(Map<String, dynamic> body) async {
    _setLoading((v) => _updateLoading = v, true);

    try {
      await _repo.updateDeliveryChallan(body);
      return true;
    } catch (_) {
      return false;
    } finally {
      _setLoading((v) => _updateLoading = v, false);
    }
  }

  // ================= EDIT LOAD =================

  Future<void> loadChallanForEdit({
    required int challanId,
    required String stockDate,
    required String locationId,
  }) async {
    _setLoading((v) => _dashboardLoading = v, true);

    try {
      await preloadDropdowns(
        stockDate: stockDate,
        locationId: locationId,
      );

      _editingChallan = await _repo.getDeliveryChallanById(challanId);
    } finally {
      _setLoading((v) => _dashboardLoading = v, false);
    }
  }

  // ================= DELETE =================

  Future<bool> deleteDeliveryChallan(int challanId) async {
    try {
      await _repo.deleteDeliveryChallan(challanId);
      _dashboardList.removeWhere((e) => e.challanId == challanId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
