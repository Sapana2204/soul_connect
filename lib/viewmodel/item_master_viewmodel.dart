import 'package:flutter/material.dart';

import '../model/item_master_model.dart';
import '../repository/item_master_repository.dart';

class ItemMasterViewmodel with ChangeNotifier {
  final _itemMasters = ItemMasterRepository();

  bool _itemMastersLoading = false;
  List<ItemMasterModel> _itemList = [];

  bool get loading => _itemMastersLoading;
  List<ItemMasterModel> get itemList => _itemList;

  void setitemMasters(bool value) {
    _itemMastersLoading = value;
    notifyListeners();
  }

  Future<void> itemMastersApi() async {
    setitemMasters(true);
    try {
      List<ItemMasterModel> response = await _itemMasters.fetchItemMasters();
      _itemList = response; // Now this will work because the response is a List<itemMasterModel>
    } catch (error) {
      print("Error fetching item masters: $error");
    } finally {
      setitemMasters(false);
    }
  }

  Future<void> saveItemMastersApi(Map<String, dynamic> data) async {
    setitemMasters(true);
    try {
      List<ItemMasterModel> response = await _itemMasters.saveItems(data);
      _itemList = response; // Update your list with the new data
    } catch (error) {
      print("Error saving item masters: $error");
    } finally {
      setitemMasters(false);
    }
  }

}
