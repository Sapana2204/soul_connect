import 'package:flutter/material.dart';

import '../model/ledger_type_model.dart';
import '../repository/ledger_type_repository.dart';


class LedgerTypeViewmodel extends ChangeNotifier {
  final LedgerRepository _repo = LedgerRepository();

  List<LedgerTypeModel> _bankAccounts = [];
  List<LedgerTypeModel> _freightPostageLedger = [];

  List<LedgerTypeModel> get bankAccounts => _bankAccounts;
  List<LedgerTypeModel> get freightPostageLedger => _freightPostageLedger;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadBankAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bankAccounts = await _repo.fetchBankAccounts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFreightPostageLedger() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _freightPostageLedger = await _repo.getFreightPostageLedger();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
