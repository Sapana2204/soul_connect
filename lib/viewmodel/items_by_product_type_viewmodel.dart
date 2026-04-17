import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/repository/items_by_product_type.dart';

import '../model/item_sales_details_model.dart';
import '../model/items_by_product_type.dart';
import '../model/stock_locations_model.dart';

class ItemsByProductTypeViewmodel with ChangeNotifier {
  final _itemRepo = ItemsByProductTypeRepository();

  bool _itemLoading = false;
  bool _itemDetailsLoading = false;
  bool _stockLocationsLoading = false;

  List<ItemsByProductTypeModel> _itemList = [];
  List<ItemSalesDetailsModel> _itemDetailsList = [];
  List<StockLocationsModel> _stockLocationsByUserList = [];
  List<StockLocationsModel> _stkLocationsList = [];

  bool get loading => _itemLoading;
  bool get detailsLoading => _itemDetailsLoading;
  bool get locationsLoading => _stockLocationsLoading;

  List<ItemsByProductTypeModel> get itemList => _itemList;
  List<ItemSalesDetailsModel> get itemDetailsList => _itemDetailsList;
  List<StockLocationsModel> get stockLocationsByUserList => _stockLocationsByUserList;
  List<StockLocationsModel> get stkLocationsList => _stkLocationsList;


  void setItems(bool value) {
    _itemLoading = value;
    notifyListeners();
  }

  void setItemDetails(bool value) {
    _itemDetailsLoading = value;
    notifyListeners();
  }

  void setStockLocations(bool value) {
    _stockLocationsLoading = value;
    notifyListeners();
  }

  Future<void> getItemsByProuctTypeApi(String stockDate, Map<String, String> params) async {
    setItems(true);
    try {
      List<ItemsByProductTypeModel> response = await _itemRepo.fetchItemsByProductType(stockDate, params);
      _itemList = response;
    } catch (error) {
      print("Error fetching items by product type: $error");
    } finally {
      setItems(false);
    }
  }

  void clearProductData() {
    itemList.clear();
    notifyListeners();
  }

  Future<List<StockLocationsModel>> getStockLocationsByUserApi() async {
    setStockLocations(true);
    try {
      List<StockLocationsModel> response = await _itemRepo.getStockLocationsByUser();
      _stockLocationsByUserList = response;
      return response;
    } catch (error) {
      print("Error fetching locations: $error");
      return [];
    } finally {
      setStockLocations(false);
    }
  }

  Future<List<StockLocationsModel>> getStkLocationsApi() async {
    setItemDetails(true);
    try {
      List<StockLocationsModel> response = await _itemRepo.getStkLocations();
      _stkLocationsList = response;
      return response; // <--- return the fetched list
    } catch (error) {
      print("Error fetching locations: $error");
      return []; // return empty list on error
    } finally {
      setStockLocations(false);
    }
  }

  Future<List<ItemSalesDetailsModel>> getItemSalesDetailsApi(int itemId, String date, String locationId) async {
    setItemDetails(true);
    try {
      List<ItemSalesDetailsModel> response = await _itemRepo.fetchItemSalesDetails(itemId, date, locationId);
      _itemDetailsList = response;
      return response; // <--- return the fetched list
    } catch (error) {
      print("Error fetching items: $error");
      return []; // return empty list on error
    } finally {
      setItemDetails(false);
    }
  }

}
