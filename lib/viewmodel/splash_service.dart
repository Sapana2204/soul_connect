import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../model/login_model.dart';
import '../utils/routes/routes_names.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewmodel/item_viewmodel.dart';
import '../viewmodel/category_master_viewmodel.dart';
import '../viewModel/sales_invoice_viewmodel.dart';

class SplashService {
  static Future<void> checkAuthentication(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString("userData");

    print("🚀 Splash checkAuthentication START");

    /// ❌ No saved user
    if (userDataString == null || userDataString.isEmpty) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
      return;
    }

    final user = LoginModel.fromJson(jsonDecode(userDataString));
    final token = user.token;

    /// ❌ No token
    if (token == null || token.isEmpty || token == "null") {
      Navigator.pushReplacementNamed(context, RouteNames.login);
      return;
    }

    try {
      JwtDecoder.decode(token);
    } catch (e) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
      return;
    }

    /// ❌ Token expired
    if (JwtDecoder.isExpired(token)) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
      return;
    }

    /// ✅ RESTORE USER INTO VIEWMODEL
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    loginVM.setUserData(user);

    /// ✅ LOAD MASTER DATA (THIS WAS MISSING)
    final itemVM = Provider.of<ItemViewmodel>(context, listen: false);
    final categoryVM = Provider.of<CategoryMasterViewmodel>(context, listen: false);
    final salesVM = Provider.of<SalesInvoiceViewmodel>(context, listen: false);

    print("🔥 Splash calling getItemsApi()");

    await itemVM.getItemsApi();            // ⭐ FIX
    await itemVM.getStockLocationsApi();
    await categoryVM.categoryMastersApi();
    await salesVM.getBillTypeApi();
    await salesVM.getRateTypeApi();

    /// ✅ Navigate after everything ready
    Navigator.pushReplacementNamed(context, RouteNames.home);
  }
}