import 'package:flutter/material.dart';

import '../model/category_master_model.dart';
import '../repository/category_master_repository.dart';


class CategoryMasterViewmodel with ChangeNotifier {
  final _categoryMasters = CategoryMasterRepository();

  bool _categoryMastersLoading = false;
  List<CategoryMasterModel> _categoryList = [];

  bool get loading => _categoryMastersLoading;
  List<CategoryMasterModel> get categoryList => _categoryList;

  void setCategoryMasters(bool value) {
    _categoryMastersLoading = value;
    notifyListeners();
  }

  Future<void> categoryMastersApi() async {
    setCategoryMasters(true);
    try {
      List<CategoryMasterModel> response = await _categoryMasters.fetchCategoryMasters();
      _categoryList = response; // Now this will work because the response is a List<CategoryMasterModel>
    } catch (error) {
      print("Error fetching category masters: $error");
    } finally {
      setCategoryMasters(false);
    }
  }
}
