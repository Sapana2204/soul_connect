import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/viewModel/sales_invoice_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/category_master_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/item_viewmodel.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../model/login_model.dart';
import '../repository/login_repository.dart';
import '../utils/app_strings.dart';
import '../utils/routes/routes_names.dart';
import '../utils/routes/utils.dart';

class LoginViewModel with ChangeNotifier {
  final _loginRepository = LoginRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _roleName;
  String? get roleName => _roleName;

  String? _userName;
  String? get userName => _userName;

  String? _userFullName;
  String? get userFullName => _userFullName;

  String? _userId;
  String? get userId => _userId;

  String? _firmId;
  String? get firmId => _firmId;
  String? _firmName;
  String? get firmName => _firmName;

  String? _defaultPurchaseLocId;
  String? get defaultPurchaseLocId => _defaultPurchaseLocId;

  LoginModel? _userData;
  LoginModel? get userData => _userData;

  List<String> _accessiblePages = [];
  List<String> get accessiblePages => _accessiblePages;

  // login_viewmodel.dart

  bool get isAdmin =>
      roleName?.toLowerCase().contains('admin') ?? false;

  bool get isSalesman =>
      roleName?.toLowerCase().contains('sales') ?? false;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool canAccess(String page) {
    final normalizedPage = page.toLowerCase().trim();

    // ✅ 1. Backend permission FIRST
    if (_accessiblePages
        .any((e) => e.toLowerCase().trim() == normalizedPage)) {
      return true;
    }

    // ✅ 2. Role-based fallback
    if (isAdmin) return true;

    if (isSalesman) {
      const salesDefaults = [
        "dashboard",
        "salesdashboard",
        "addsales",
        "receiptvoucher",
        "salesreturn",
      ];

      return salesDefaults.contains(normalizedPage);
    }

    return false;
  }

  // bool hasAccess(String page) {
  //   final normalizedPage = page.toLowerCase().trim();
  //   return _accessiblePages
  //       .any((e) => e.toLowerCase().trim() == normalizedPage);
  // }

  void setUserData(LoginModel? user) {
    _userData = user;

    if (user?.token != null) {
      try {
        final decodedToken = JwtDecoder.decode(user!.token!);

        _roleName = decodedToken['RoleName']?.toString();
        _userName = decodedToken['UserName']?.toString();
        _userFullName = decodedToken['UserFullName']?.toString();
        _userId = decodedToken['UserId']?.toString();
        _firmId = decodedToken['FirmId']?.toString();
        _firmName = decodedToken['FirmName']?.toString();
        _defaultPurchaseLocId =
            decodedToken['DefaultPurchaseLocId']?.toString();

        final accessible = decodedToken['AccessiblePages'];

        if (accessible is List) {
          // ✅ Handle nested lists like [[...]]
          _accessiblePages = accessible
              .expand((e) => e is List ? e : [e])
              .map((e) => e.toString())
              .toList();
        } else if (accessible is String) {
          // ✅ Handle comma-separated string
          _accessiblePages = accessible
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else {
          _accessiblePages = [];
        }

        debugPrint('Decoded Token: $decodedToken');
        debugPrint('AccessiblePages: $_accessiblePages');
      } catch (e) {
        debugPrint('Error decoding token: $e');
        _accessiblePages = [];
      }
    } else {
      _accessiblePages = [];
    }

    notifyListeners();
  }
  // void setUserData(LoginModel? user) {
  //   _userData = user;
  //
  //   if (user?.token != null) {
  //     try {
  //       Map<String, dynamic> decodedToken = JwtDecoder.decode(user!.token!);
  //
  //       _roleName = decodedToken['RoleName'];
  //       _userName = decodedToken['UserName'];
  //       _userFullName = decodedToken['UserFullName'];
  //       _userId = decodedToken['UserId'];
  //       // ✅ ADD THESE
  //       _firmId = decodedToken['FirmId'];
  //       _firmName = decodedToken['FirmName'];
  //       _defaultPurchaseLocId = decodedToken['DefaultPurchaseLocId'];
  //       _accessiblePages = List<String>.from(decodedToken['AccessiblePages'] ?? []);
  //
  //       print("Decoded Token: $decodedToken");
  //       print("AccessiblePages: $_accessiblePages");
  //     } catch (e) {
  //       print("Error decoding role: $e");
  //     }
  //   }
  //
  //   notifyListeners();
  // }

  Future<void> saveUserData(LoginModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(user.toJson()));
  }

  Future<LoginModel?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('userData');
    if (data != null) {
      return LoginModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<void> loginApi(
      String username,
      String password,
      String customerCode,
      BuildContext context, {
        required bool rememberMe, // ✅ ADD
      }) async {
    setLoading(true);

    try {
      final response =
      await _loginRepository.loginApi(username, password, customerCode);

      final loginModel = LoginModel.fromJson(response);

      if (loginModel.token != null && loginModel.token!.isNotEmpty) {

        setUserData(loginModel);
        await saveUserData(loginModel);

        /// ✅ SAVE LAST LOGIN (NEW CODE)
        final prefs = await SharedPreferences.getInstance();

        if (rememberMe) {
          // await prefs.setString('lastCustomerId', customerCode);
          await prefs.setString('lastUsername', username);
          await prefs.setString('lastPassword', password);
        } else {
          // await prefs.remove('lastCustomerId');
          await prefs.remove('lastUsername');
          await prefs.remove('lastPassword');
        }

        /// ✅ Store multiple usernames (for dropdown later)
        List<String> users = prefs.getStringList('users') ?? [];

        if (!users.contains(username)) {
          users.add(username);
          await prefs.setStringList('users', users);
        }

        Utils.toastMessage(Strings.loginSuccess);

        // ✅ Call Master APIs after login success
        final salesVM = Provider.of<SalesInvoiceViewmodel>(
          context,
          listen: false,
        );
        final itemVM = Provider.of<ItemViewmodel>(
          context,
          listen: false,
        );
        final categoryVM = Provider.of<CategoryMasterViewmodel>(
          context,
          listen: false,
        );

        await itemVM.getItemsApi();
        await itemVM.getStockLocationsApi();
        await categoryVM.categoryMastersApi();
        await salesVM.getBillTypeApi();
        await salesVM.getRateTypeApi();

        Navigator.pushNamed(context, RouteNames.home);

      } else {
        Utils.toastMessage("Unauthorized User");
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        Utils.toastMessage(Strings.unauthorizedUser);
      } else {
        Utils.toastMessage("${Strings.networkError}: $e");
      }
    } finally {
      setLoading(false);
    }
  }


  // Future<void> logout(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('userData');
  //
  //   /// ⭐ Clear all master data
  //   final itemVM = Provider.of<ItemViewmodel>(context, listen: false);
  //   await itemVM.clearLocalItems();
  //
  //   setUserData(null);
  //
  //   Utils.toastMessage("Session expired. Please login again.");
  //
  //   Navigator.pushNamedAndRemoveUntil(
  //     context,
  //     RouteNames.login,
  //         (route) => false,
  //   );
  // }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    /// ✅ Clear ALL prefs
    await prefs.clear();

    /// ✅ Clear FULL DATABASE
    final db = AppDatabase();
    await db.clearAllTables();

    /// ✅ Clear ViewModels (memory)
    final itemVM = Provider.of<ItemViewmodel>(context, listen: false);


    await itemVM.clearLocalItems();
        // ✅ required

    /// ✅ Reset user
    setUserData(null);

    Utils.toastMessage("Session expired. Please login again.");

    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.login,
          (route) => false,
    );
  }

  Future<void> loadUserFromPrefs(BuildContext context) async {
    if (_userData != null && _accessiblePages.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');

    if (data != null) {
      final user = LoginModel.fromJson(jsonDecode(data));
      setUserData(user);

      /// ✅ ADD THIS BLOCK
      final itemVM = Provider.of<ItemViewmodel>(context, listen: false);
      final categoryVM = Provider.of<CategoryMasterViewmodel>(context, listen: false);
      final salesVM = Provider.of<SalesInvoiceViewmodel>(context, listen: false);

      await itemVM.getItemsApi();   // ⭐ THIS IS MISSING
      await itemVM.getStockLocationsApi();
      await categoryVM.categoryMastersApi();
      await salesVM.getBillTypeApi();
      await salesVM.getRateTypeApi();
    }
  }
}
