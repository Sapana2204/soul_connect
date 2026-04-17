import 'package:flutter/material.dart';


import '../model/get_all_tax_group_model.dart';
import '../model/ledger_bal_model.dart';
import '../model/ledger_type_model.dart';
import '../model/party_model.dart';
import '../repository/purchase_invoice_repository.dart';


class PurchaseInvoiceViewmodel with ChangeNotifier {
  final _PurchaseInvoiceRepo = PurchaseInvoiceRepository();

  bool _purchaseInvoiceLoading = false;
  bool _ledgerBalanceLoading = false;
  bool _isLoading = false;


  List<PartyModel> _partyList = [];
  LedgerBalModel? _ledgerBalance; // ✅ Changed from bool to model
  List<LedgerTypeModel> _bankAccounts = [];
  List<LedgerTypeModel> _freightPostageLedger = [];
  List<TaxGroupPercentageModel> _taxGroupList = [];
  List<TaxGroupPercentageModel> get taxGroupList => _taxGroupList;


  bool get loading => _purchaseInvoiceLoading;
  bool get ledgerBalanceLoading => _ledgerBalanceLoading;
  bool get isLoading => _isLoading;

  List<PartyModel> get partyList => _partyList;
  LedgerBalModel? get ledgerBalance => _ledgerBalance; // ✅ Getter for balance
  List<LedgerTypeModel> get bankAccounts => _bankAccounts;
  List<LedgerTypeModel> get freightPostageLedger => _freightPostageLedger;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // -------------------------------
  // Setters
  // -------------------------------
  void setPartyLoading(bool value) {
    _purchaseInvoiceLoading = value;
    notifyListeners();
  }

  void setLedgerBalanceLoading(bool value) {
    _ledgerBalanceLoading = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // -------------------------------
  // Fetch Purchase Party
  // -------------------------------
  Future<void> getPurchasePartyApi() async {
    setPartyLoading(true);
    try {
      List<PartyModel> response = await _PurchaseInvoiceRepo.fetchPurchaseParty();
      _partyList = response;
    } catch (error) {
      print("Error fetching purchase party: $error");
    } finally {
      setPartyLoading(false);
    }
  }

  // -------------------------------
  // Fetch Ledger Balance
  // -------------------------------
  Future<void> getLedgerBalanceApi({
    required int ledgerId,
    required String balanceAsOn,
    required String balanceType,
  }) async {
    setLedgerBalanceLoading(true);
    try {
      final response = await _PurchaseInvoiceRepo.fetchLedgerBalance(
        ledgerId: ledgerId,
        balanceAsOn: balanceAsOn,
        balanceType: balanceType,
      );
      _ledgerBalance = response;
      notifyListeners(); // ✅ Notify UI to rebuild with new data
    } catch (error) {
      print("Error fetching ledger balance: $error");
    } finally {
      setLedgerBalanceLoading(false);
    }
  }

  Future<void> loadFreightPostageLedger() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _freightPostageLedger = await _PurchaseInvoiceRepo.getFreightPostageLedger();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<List<TaxGroupPercentageModel>> fetchTaxGroupPercentage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _PurchaseInvoiceRepo.fetchTaxGroupPercentage();
      _taxGroupList = result;
      print("✅ Tax Groups fetched from API: ${result.length}");
      return result; // ✅ return data to widget
    } catch (e) {
      print("❌ Error in ViewModel while fetching Tax Group Percentage: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }




}
