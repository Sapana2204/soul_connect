import 'package:flutter/material.dart';
import '../model/sales_return_item_details_model.dart';
import '../model/sales_return_model.dart';
import '../model/sales_return_stock_item_model.dart';
import '../repository/sales_return_repository.dart';

class SalesReturnViewModel with ChangeNotifier {
  final _repo = SalesReturnRepository();

  bool _loading = false;
  bool get loading => _loading;

  List<SalesReturnModel> _salesReturnList = [];
  List<SalesReturnModel> _filteredList = [];
  List<SalesReturnModel> get salesReturnList => _filteredList;

  String? _error;
  String? get error => _error;

  List<SalesReturnStockItemModel> _items = [];
  List<SalesReturnStockItemModel> get items => _items;
  List<SalesReturnItemDetailsModel> itemDetails = [];


  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> fetchSalesReturn(String fromDate, String toDate) async {
    setLoading(true);
    try {
      final list = await _repo.fetchSalesReturnApi(fromDate, toDate);
      _salesReturnList = list;
      _filteredList = list;
    } catch (e) {
      debugPrint("ViewModel Error: $e");
    } finally {
      setLoading(false);
    }
  }

  void searchReturn(String query) {
    if (query.isEmpty) {
      _filteredList = _salesReturnList;
    } else {
      _filteredList = _salesReturnList.where((element) {
        return element.customerName!.toLowerCase().contains(query.toLowerCase()) ||
            element.returnId.toString().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<SalesReturnStockItemModel>>fetchStockItems({
    required String stockDate,
    required String locationId,
    required int customerId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repo.getStockItemsForSalesReturn(
        stockDate: stockDate,
        locationId: locationId,
        customerId: customerId,
      );
      _items = data;
      _error = null;
      return data;
    } catch (e) {
      _error = e.toString();
      _items = [];
      return [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearItems() {
    _items.clear();
    notifyListeners();
  }

  Future<void> fetchItemDetails({
    // required int itemId,
    required int locationId,
    required int customerId,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      itemDetails = await _repo.getItemDetailsForSalesReturn(
        // itemId: itemId,
        locationId: locationId,
        customerId: customerId,
      );
    } catch (e) {
      debugPrint("❌ Item details error: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    itemDetails = [];
    notifyListeners();
  }

  void clearItemDetails() {
    itemDetails = [];
   _loading = false;
    notifyListeners();
  }

  ///  ADD SALES RETURN
  Future<int?> addSalesReturn(
      BuildContext context, Map<String, dynamic> body) async {
    try {
      final response = await _repo.addSalesReturnApi(body);

      print('Add sales return response: $response');

      if (response != null && response > 0) {
        return response; // return new SalesReturnId
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  ///  UPDATE SALES RETURN
  Future<int?> updateSalesReturn(
      BuildContext context, Map<String, dynamic> body) async {
    try {
      final response = await _repo.updateSalesReturnApi(body);

      print('Update sales return response: $response');

      if (response != null && response > 0) {
        return response; // return new SalesReturnId
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

}