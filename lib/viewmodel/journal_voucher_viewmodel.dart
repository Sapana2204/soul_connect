import 'package:flutter/material.dart';

import '../model/add_vouchers_model.dart';
import '../model/ledger_type_model.dart';
import '../repository/journal_voucher_repository.dart';

class JournalVoucherViewModel extends ChangeNotifier {
  final JournalVoucherRepository _repo = JournalVoucherRepository();

  bool loading = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<LedgerTypeModel> _bankAccounts = [];
  List<LedgerTypeModel> get bankAccounts => _bankAccounts;

  List<AddVouchersModel> journalVouchers = [];
  List<LedgerTypeModel> accLedgerList = [];

  // 🔹 Cached dropdown ledgers
  List<LedgerTypeModel> creditLedgers = []; // BC
  List<LedgerTypeModel> debitLedgers = [];  // E

  bool _ledgersLoaded = false;
  bool get ledgersLoaded => _ledgersLoaded;


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

  // ---------------- GET ALL JOURNAL ----------------

  Future<void> getAllJournalVouchers(
      Map<String, dynamic> requestBody) async {
    loading = true;
    notifyListeners();

    try {
      final response =
      await _repo.fetchAllJournalVouchers(requestBody);

      if (response != null && response is List) {
        journalVouchers = response
            .map((e) => AddVouchersModel.fromJson(e))
            .toList()
            .reversed
            .toList();
      } else {
        journalVouchers = [];
      }
    } catch (e) {
      journalVouchers = [];
      setError("Failed to fetch journal vouchers");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ---------------- ADD ----------------
  Future<bool> addJournalVoucher(
      BuildContext context, AddVouchersModel model) async {
    setLoading(true);
    try {
      model.vchTypeId = 8; // ✅ Journal Voucher

      final response = await _repo.addJournalVoucher(model);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Journal voucher added successfully')),
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

  Future<bool> updateJournalVoucher(
      BuildContext context, AddVouchersModel model) async {
    setLoading(true);
    try {
      model.vchTypeId = 8; // ✅ Journal Voucher

      final response = await _repo.updateJournalVoucher(model);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Journal voucher updated successfully')),
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

  Future<bool> deleteJournalVoucher(int voucherId) async {
    setLoading(true);
    try {
      final result =
      await _repo.deleteJournalVoucher(voucherId);

      if (result) {
        journalVouchers
            .removeWhere((v) => v.voucherId == voucherId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError("Failed to delete journal voucher");
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ---------------- LEDGER TYPE ----------------

  Future<void> loadLedgerAccounts(String ledgerType) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bankAccounts =
      await _repo.fetchLedgerAccounts(ledgerType);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadJournalLedgersOnce() async {
    if (_ledgersLoaded) return; // ✅ prevent re-hit

    setLoading(true);

    try {
      // 🔹 Credit (CR - BC)
      _bankAccounts = await _repo.fetchLedgerAccounts("BC");
      creditLedgers = List.from(_bankAccounts);

      // 🔹 Debit (DR - E)
      _bankAccounts = await _repo.fetchLedgerAccounts("E");
      debitLedgers = List.from(_bankAccounts);

      _ledgersLoaded = true;
    } catch (e) {
      setError("Failed to load journal ledgers");
    } finally {
      setLoading(false);
    }
  }

}
