import 'package:flutter/material.dart';
import '../model/add_vouchers_model.dart';
import '../model/ledger_type_model.dart';
import '../repository/contra_voucher_repository.dart';

class ContraVoucherViewModel extends ChangeNotifier {
  final ContraVoucherRepository _repo = ContraVoucherRepository();

  bool loading = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  List<LedgerTypeModel> _bankAccounts = [];

  List<LedgerTypeModel> get bankAccounts => _bankAccounts;
  List<AddVouchersModel> contraVouchers = [];
  List<LedgerTypeModel> accLedgerList = [];

  /// 🔹 Contra dropdown ledgers (BC)
  List<LedgerTypeModel> _contraLedgers = [];
  List<LedgerTypeModel> get contraLedgers => _contraLedgers;

  bool _ledgersLoaded = false; // ✅ CACHE FLAG

  // ---------------- LOADING ----------------

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ---------------- LEDGERS ----------------

  Future<void> fetchAccLedgersByGrpId(int groupId) async {
    setLoading(true);
    try {
      accLedgerList = await _repo.fetchAccLedgersByGroupId(groupId);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // ---------------- GET ALL CONTRA (BODY FROM SCREEN) ----------------

  Future<void> getAllContraVouchers(
      Map<String, dynamic> requestBody) async {
    loading = true;
    notifyListeners();

    try {
      final response =
      await _repo.fetchAllContraVouchers(requestBody);

      if (response != null && response is List) {
        contraVouchers = response
            .map((e) => AddVouchersModel.fromJson(e))
            .toList()
            .reversed
            .toList();

      } else {
        contraVouchers = [];
      }
    } catch (e) {
      contraVouchers = [];
      setError("Failed to fetch contra vouchers");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ---------------- ADD ----------------

  Future<bool> addContraVoucher(
      BuildContext context, AddVouchersModel model) async {
    setLoading(true);
    try {
      model.vchTypeId = 7; // ✅ Contra

      final response = await _repo.addContraVoucher(model);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Contra voucher added successfully')),
        );
        return true;
      }
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ---------------- UPDATE ----------------

  Future<bool> updateContraVoucher(
      BuildContext context, AddVouchersModel model) async {
    setLoading(true);
    try {
      model.vchTypeId = 7;

      final response = await _repo.updateContraVoucher(model);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Contra voucher updated successfully')),
        );
        return true;
      }
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ---------------- DELETE ----------------

  Future<bool> deleteContraVoucher(int voucherId) async {
    setLoading(true);
    try {
      final result =
      await _repo.deleteContraVoucher(voucherId);

      if (result) {
        contraVouchers.removeWhere(
                (v) => v.voucherId == voucherId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError("Failed to delete contra voucher");
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadLedgerAccounts(String ledgerType) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bankAccounts = await _repo.fetchLedgerAccounts(ledgerType);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> preloadContraDropdowns() async {
    if (_ledgersLoaded) {
      debugPrint("📦 [ContraVM] Dropdown data loaded from CACHE");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      debugPrint("🌐 [ContraVM] API HIT → fetchLedgerAccounts(BC)");

      final response = await _repo.fetchLedgerAccounts("BC");

      debugPrint(
        "📥 [ContraVM] Ledger Response (${response.length}): "
            "${response.map((e) => e.ledgerName).toList()}",
      );

      _contraLedgers = response;
      _ledgersLoaded = true;

      debugPrint("✅ [ContraVM] Contra dropdowns cached");
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ [ContraVM] Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }




}
