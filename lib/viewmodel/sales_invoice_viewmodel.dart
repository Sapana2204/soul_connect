import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/repository/sales_invoice_repository.dart';
import '../model/bill_types_model.dart';
import '../model/get_all_tax_group_model.dart';
import '../model/ledger_bal_model.dart';
import '../model/party_model.dart';
import '../model/rate_type_model.dart';
import '../utils/app_strings.dart';


class SalesInvoiceViewmodel with ChangeNotifier {
  final _salesInvoiceRepo = SalesInvoiceRepository();

  bool _salesInvoiceLoading = false;
  bool _rateTypeLoading = false;
  bool _billTypeLoading = false;
  bool _ledgerBalanceLoading = false;

  List<PartyModel> _partyList = [];
  List<RateTypesModel> _rateTypeList = [];
  List<BillTypesModel> _billTypeList = [];
  LedgerBalModel? _ledgerBalance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool get loading => _salesInvoiceLoading;
  bool get loadingRateType => _rateTypeLoading;
  bool get loadingBillType => _billTypeLoading;
  bool get ledgerBalanceLoading => _ledgerBalanceLoading;

  List<PartyModel> get partyList => _partyList;
  List<RateTypesModel> get rateTypeList => _rateTypeList;
  List<BillTypesModel> get billTypeList => _billTypeList;
  LedgerBalModel? get ledgerBalance => _ledgerBalance;
  List<TaxGroupPercentageModel> _taxGroupList = [];
  List<TaxGroupPercentageModel> get taxGroupList => _taxGroupList;


  String? selectedLocationId;
  String? selectedBillType;
  String? selectedRateType;
  String? selectedPayMode;
  String? selectedTaxType;

  String? selectedCustomer;
  String? selectedByHand;

  void setBillDetails({
    String? locationId,
    String? billType,
    String? rateType,
    String? payMode,
    String? taxType,
  }) {
    selectedLocationId = locationId;
    selectedBillType = billType;
    selectedRateType = rateType;
    selectedPayMode = payMode;
    selectedTaxType = taxType;
    notifyListeners();
  }

  void clearBillDetails() {
    selectedLocationId = null;
    selectedBillType = null;
    selectedRateType = null;
    selectedPayMode = null;
    selectedTaxType = null;

    notifyListeners();
  }

  void setCustomerDetails({
    String? customer,
    String? byHand,

  }) {
    selectedCustomer = customer;
    selectedByHand = byHand;

    notifyListeners();
  }

  void clearCustomerDetails() {
    selectedCustomer = null;
    selectedByHand = null;

    notifyListeners();
  }

  void clearLedger() {
    _ledgerBalance = null;
    notifyListeners();
  }

  void setParty(bool value) {
    _salesInvoiceLoading = value;
    notifyListeners();
  }

  void setRateType(bool value) {
    _rateTypeLoading = value;
    notifyListeners();
  }

  void setBillType(bool value) {
    _billTypeLoading = value;
    notifyListeners();
  }

  void setLedgerBalanceLoading(bool value) {
    _ledgerBalanceLoading = value;
    notifyListeners();
  }

  Future<void> getPartyApi() async {
    setParty(true);
    try {
      List<PartyModel> response = await _salesInvoiceRepo.fetchParty();
      _partyList = response;
    } catch (error) {
      print("${Strings.partyFetchError}: $error");    } finally {
      setParty(false);
    }
  }

  Future<void> getRateTypeApi() async {
    print("[RateType] ViewModel: getRateTypeApi() called");
    setRateType(true);
    try {
      List<RateTypesModel> response = await _salesInvoiceRepo.fetchRateType();
      _rateTypeList = response;
      print("[RateType] ViewModel: _rateTypeList set with ${_rateTypeList.length} items");
      for (var rt in _rateTypeList) {
        print("[RateType] ViewModel: -> id=${rt.rateTypeId}, rateType='${rt.rateType}', display='${rt.rateTypeDisplay}'");
      }
    } catch (error) {
      print("[RateType] ViewModel: ERROR caught: $error");
    } finally {
      setRateType(false);
      print("[RateType] ViewModel: setRateType(false) called, notifyListeners fired");
    }
  }

  Future<void> getBillTypeApi() async {
    setBillType(true);
    try {
      List<BillTypesModel> response = await _salesInvoiceRepo.fetchBillype();
      _billTypeList = response;
    } catch (error) {
      print("${Strings.billTypeFetchError}: $error");    } finally {
      setBillType(false);
    }
  }

  Future<void> getLedgerBalanceApi({
    required int ledgerId,
    required String balanceAsOn,
    required String balanceType,
  }) async {
    setLedgerBalanceLoading(true);
    try {
      final response = await _salesInvoiceRepo.fetchLedgerBalance(
        ledgerId: ledgerId,
        balanceAsOn: balanceAsOn,
        balanceType: balanceType,
      );
      _ledgerBalance = response;
    } catch (error) {
      print("${Strings.ledgerBalanceFetchError}: $error");    } finally {
      setLedgerBalanceLoading(false);
    }
  }

  Future<void> fetchTaxGroupPercentage() async {
    _isLoading = true;
    notifyListeners();

    try {
      _taxGroupList = await _salesInvoiceRepo.fetchTaxGroupPercentage();
    } catch (e) {
      print("${Strings.ledgerBalanceFetchError}: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
