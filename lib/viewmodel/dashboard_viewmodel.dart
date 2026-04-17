import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/dashboard_model.dart';
import '../repository/dashboard_repository.dart';


class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repo = DashboardRepository();

  bool _loading = false;
  bool get loading => _loading;

  String _error = '';
  String get error => _error;

  // Initialized with empty/zero states
  SalesSummary salesSummary = SalesSummary(total: 0, cash: 0, credit: 0, bank: 0);
  PurchaseSummary purchaseSummary = PurchaseSummary(total: 0, cash: 0, credit: 0, bank: 0);
  String stockCount = '0';

  List<Party> customers = [];
  List<Party> suppliers = [];
  List<Product> products = [];

  double get totalCustomerOutstanding => customers.fold(0.0, (sum, item) => sum + item.outstanding);
  double get totalSupplierOutstanding => suppliers.fold(0.0, (sum, item) => sum + item.outstanding);

  int get criticalProductCount {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return products.where((p) {
      try {
        return formatter.parse(p.expiryDate).isBefore(now);
      } catch (_) { return false; }
    }).length;
  }

  Future<void> fetchDashboardData() async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      await Future.wait([
        _loadSummary(),
        _loadCustomers(),
        _loadSuppliers(),
        _loadProducts(),
      ]);
    } catch (e) {
      _error = "Failed to load some dashboard data.";
      debugPrint("Dashboard Fetch Error: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSummary() async {
    try {
      final data = await _repo.fetchFullDashboardData();

      salesSummary = SalesSummary(
        total: (data['TotalSales'] ?? 0).toDouble(),
        cash: (data['CashSales'] ?? 0).toDouble(),
        credit: (data['CreditSales'] ?? 0).toDouble(),
        bank: (data['BankSales'] ?? 0).toDouble(),
      );

      purchaseSummary = PurchaseSummary(
        total: (data['TotalPurchase'] ?? 0).toDouble(),
        cash: (data['CashPurchase'] ?? 0).toDouble(),
        credit: (data['CreditPurchase'] ?? 0).toDouble(),
        bank: (data['BankPayment'] ?? 0).toDouble(),
      );

      stockCount = data['TotalStockQuantity']?.toString() ?? '0';
    } catch (e) {
      debugPrint("Summary Error: $e");
    }
  }

  Future<void> _loadCustomers() async {
    try {
      customers = await _repo.fetchCustomers();
    } catch (e) {
      debugPrint("Customers Error: $e");
      customers = [];
    }
  }

  Future<void> _loadSuppliers() async {
    try {
      suppliers = await _repo.fetchSuppliers();
    } catch (e) {
      debugPrint("Suppliers Error: $e");
      suppliers = [];
    }
  }

  Future<void> _loadProducts() async {
    try {
      products = await _repo.fetchProducts();
    } catch (e) {
      debugPrint("Products Error: $e");
      products = [];
    }
  }
}