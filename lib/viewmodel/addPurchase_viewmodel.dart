import 'package:flutter/material.dart';
import '../repository/addPurchase_repository.dart';

class AddPurchaseViewmodel with ChangeNotifier {
  final _addPurchaseRepo = AddPurchaseRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> addPurchase(Map<String, dynamic> requestBody) async {
    setLoading(true);

    try {
      final response = await _addPurchaseRepo.addPurchaseApi(requestBody);
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


}
