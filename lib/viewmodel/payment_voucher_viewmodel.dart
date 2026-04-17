import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/repository/payment_voucher_repository.dart';
import '../model/add_vouchers_model.dart';
import '../model/ledger_type_model.dart';

import '../repository/ledger_type_repository.dart';

class PaymentVoucherViewmodel extends ChangeNotifier {
  final PaymentVoucherRepository _repo = PaymentVoucherRepository();

  List<LedgerTypeModel> _accLedgerList = [];
  // List<LedgerTypeModel> _cashAccounts = [];

  List<LedgerTypeModel> get accLedgerList => _accLedgerList;
  // List<LedgerTypeModel> get cashAccounts => _cashAccounts;

  bool loading = false;
  List<AddVouchersModel> vouchers = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<LedgerTypeModel> paidToLedgers = [];
  List<LedgerTypeModel> cashLedgers = [];
  List<LedgerTypeModel> bankLedgers = [];

  bool ledgersLoaded = false;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchAccLedgersByGrpId(int groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _accLedgerList = await _repo.fetchAccLedgersByGroupId(groupId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<bool> addVoucher(BuildContext context, AddVouchersModel model) async {
    setLoading(true);
    try {
      // perform API call
      final response = await _repo.addVoucher(model);
          setLoading(false);

      if (response != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Voucher added successfully')),
              );
              return true;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⚠️ Failed to add voucher')),
              );
              return false;
            }
    } catch (e) {
      setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('❌ Error: $e')),
              );      return false;
    }
  }

  Future<bool> updateVoucher(BuildContext context, AddVouchersModel model) async {
    setLoading(true);
    try {
      // perform API call
      final response = await _repo.updateVoucher(model);
      setLoading(false);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Voucher updated successfully')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Failed to update voucher')),
        );
        return false;
      }
    } catch (e) {
      setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );      return false;
    }
  }

  Future<void> getAllVouchers(Map<String, dynamic> requestBody) async {
    loading = true;
    notifyListeners();

    try {
      final response = await _repo.fetchAllVouchers(requestBody);

      if (response != null && response is List) {
        vouchers = response.map((item) => AddVouchersModel.fromJson(item)).toList();
      } else {
        vouchers = [];
      }
    } catch (e) {
      print("❌ Error fetching vouchers: $e");
      vouchers = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteVouchersApi(int vchId) async {
    setLoading(true);
    try {
      final result = await _repo.deleteVoucher(vchId);
      if (result) {
        vouchers.removeWhere((vouchers) => vouchers.voucherId == vchId);
        notifyListeners();
        return true;
      } else {
        setError("Failed to delete voucher.");
        return false;
      }
    } catch (e) {
      print("Delete voucher error: $e");
      setError("Error deleting voucher.");
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadAllLedgersOnce({required int groupId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      paidToLedgers = await _repo.fetchAccLedgersByGroupId(groupId);
      cashLedgers = await _repo.fetchAccLedgersByGroupId(11);
      bankLedgers = await _repo.fetchAccLedgersByGroupId(7);

      ledgersLoaded = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
