import 'dart:ffi';

import 'package:flutter/material.dart';

import 'package:flutter_soulconnect/repository/item_repository.dart';

import '../model/itemDetailsForPurchaseReturn_model.dart';
import '../model/purchaseReturnDashboard_model.dart';

import '../model/stockItemsForPurchaseReturn_model.dart';
import '../repository/purchaseReturn_repository.dart';

class PurchaseReturnViewmodel with ChangeNotifier {
  final _purchaseReturnRepo = PurchaseReturnRepository();

  bool _purchaseReturnLoading = false;

  List<PurchaseReturnDashboardModel> _purchaseReturnList = [];
  List<PurchaseReturnDashboardModel> _filteredPurchaseReturnList = []; // ✅ NEW

  bool get loading => _purchaseReturnLoading;
  bool _itemloading = false;
  bool get itemLoading => _itemloading;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _loading = false;
  bool get updatePurchaseLoading => _loading;

  // ✅ expose filtered list
  List<PurchaseReturnDashboardModel> get purchaseReturnList =>
      _filteredPurchaseReturnList;

  void setPurchaseReturn(bool value) {
    _purchaseReturnLoading = value;
    notifyListeners();
  }
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> getPurchaseReturnApi({
    required String fromDate,
    required String toDate,
  }) async {
    setPurchaseReturn(true);
    try {
      final response =
      await _purchaseReturnRepo.fetchPurchaseReturn(
        fromDate: fromDate,
        toDate: toDate,
      );

      _purchaseReturnList = response;
      _filteredPurchaseReturnList = List.from(_purchaseReturnList);
    } catch (error) {
      print("Error fetching purchase Return: $error");
    } finally {
      setPurchaseReturn(false);
    }
  }


  // 🔍 SEARCH LOGIC
  void filterPurchaseReturns(String query) {
    if (query.isEmpty) {
      _filteredPurchaseReturnList = List.from(_purchaseReturnList);
    } else {
      _filteredPurchaseReturnList =
          _purchaseReturnList.where((r) {
            final supplier = r.supplierName?.toLowerCase() ?? '';
            final returnNo = r.returnId?.toString() ?? '';

            return supplier.contains(query.toLowerCase()) ||
                returnNo.contains(query);
          }).toList();
    }
    notifyListeners();
  }

  Future<PurchaseReturnDashboardModel?> getPurchaseReturnById(int id) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _purchaseReturnRepo.getPurchaseReturnById(id);

      // You can store it or return it directly
      return response;
    } catch (e) {
      print("Error in getPurchaseReturnById ViewModel: $e");
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<StockItemsForPurchaseReturnModel>> getStockItemsForPurchaseReturn({
    required int locationId,
    required int supplierId,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _purchaseReturnRepo.getStockItemsForPurchaseReturn(
        locationId: locationId,
        supplierId: supplierId,
      );

      return response; // response is List
    } catch (e) {
      print("Error in getStockItemsForPurchaseReturn ViewModel: $e");
      return [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }


  Future<List<ItemDetailsForPurchaseReturnModel>> getItemDetailsForPurchaseReturn({
    required int locationId,
    required int partyId,
    required int itemId,
  }) async {
    _itemloading = true;
    notifyListeners();

    try {
      final response = await _purchaseReturnRepo.getItemDetailsForPurchaseReturn(
        locationId: locationId,
        partyId: partyId,
        itemId: itemId,
      );

      return response;
    } catch (e) {
      print("Error in getItemDetailsForPurchaseReturn ViewModel: $e");
      return [];
    } finally {
      _itemloading = false;
      notifyListeners();
    }
  }

  Future<bool> addPurchaseReturn(Map<String, dynamic> requestBody) async {
    setLoading(true);

    try {
      final response = await _purchaseReturnRepo.addPurchaseReturnApi(requestBody);
      setLoading(false);

      print("Add Purchase Response: $response");

      // SUCCESS
      return true;

    } catch (e) {
      setLoading(false);
      print("❌ Failed to add purchase: $e");

      // FAILURE
      return false;
    }
  }


  Future<bool> deletePurchaseReturn(int id) async {
    setPurchaseReturn(true);

    final result = await _purchaseReturnRepo.deletePurchaseReturn(id);

    if (result) {
      // ✅ remove from main list
      _purchaseReturnList.removeWhere((item) => item.returnId == id);

      // ✅ remove from filtered list also
      _filteredPurchaseReturnList.removeWhere((item) => item.returnId == id);

      notifyListeners();
    }

    setPurchaseReturn(false);
    return result;
  }


  Future<bool> updatePurchaseReturn(Map<String, dynamic> requestData) async {
    _loading = true;
    notifyListeners();

    try {
      final response =
      await _purchaseReturnRepo.updatePurchaseReturn(requestData);

      // ✅ Your API returns true/false
      final bool isSuccess =
          response == true || response.toString().toLowerCase() == "true";

      if (isSuccess) {
        // ✅ Refresh dashboard list (Start of month → Today)
        final now = DateTime.now();
        final from = DateTime(now.year, now.month, 1);
        final to = now;

        String formatDate(DateTime d) =>
            "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

        await getPurchaseReturnApi(
          fromDate: formatDate(from),
          toDate: formatDate(to),
        );

        _loading = false;
        notifyListeners();
        return true;
      }

      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _loading = false;
      notifyListeners();
      debugPrint("❌ Exception in updatePurchaseReturn: $e");
      return false;
    }
  }





}

