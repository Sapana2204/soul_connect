
import 'package:flutter/material.dart';


import '../model/purchaseItemDetails_model.dart';
import '../repository/purchaseItemDetails_repository.dart';

class PurchaseItemDetailsViewmodel with ChangeNotifier {
  final _purchaseItemDetailsRepo = PurchaseItemDetailsRepository();

  bool _purchaseItemDetailsLoading = false;

  List<PurchaseItemDetailsModel> _purchaseItemDetailsList = [];

  bool get purchaseItemDetailsLoading => _purchaseItemDetailsLoading;

  List<PurchaseItemDetailsModel> get purchaseItemDetailsList =>
      _purchaseItemDetailsList;

  void setPurchaseItemDetails(bool value) {
    _purchaseItemDetailsLoading = value;
    notifyListeners();
  }

  Future<List<PurchaseItemDetailsModel>> getPurchaseItemDetailsApi(
      int itemId) async {
    setPurchaseItemDetails(true);
    try {
      List<PurchaseItemDetailsModel> response =
          await _purchaseItemDetailsRepo.fetchPurchaseItemDetails(itemId);
      _purchaseItemDetailsList = response;
      return response; // <--- return the fetched list
    } catch (error) {
      print("Error fetching purchase items: $error");
      return []; // return empty list on error
    } finally {
      setPurchaseItemDetails(false);
    }
  }
}
